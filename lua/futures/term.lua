local lib = require("utility.lib")

---@class futures.Terminal Represents a neovim terminal.
---@field cmd string[] Command with arguments.
---@field option table See `jobstart()`.
---@field callback? fun(term: futures.Terminal, job_id: integer, data: integer, event: string) Callback invoked when the terminal process exits.
---@field id integer `channel-id`
---@field is_valid boolean True if the terminal process is valid.
---@field has_exited boolean True if the terminal process has already exited.
---@field protected callbacks fun(term: futures.Terminal, job_id: integer, data: integer, event:string)[]
---@field no_callbacks boolean Mark the terminal process that its `callbacks` will not be executed.
---@field winnr integer Window number.
---@field bunnr integer Buffer number.
local Terminal = {}

---@private
Terminal.__index = Terminal

---Constructor.
---@param cmd string[] Command with arguments.
---@param option? table See `jobstart()`.
---@param on_exit? fun(term: futures.Terminal, job_id: integer, data: integer, event: string) Callback invoked when the terminal process exits (discouraged, use `continue_with` instead).
---@return futures.Terminal
function Terminal.new(cmd, option, on_exit)
  local terminal = {
    cmd = cmd,
    option = option and vim.deepcopy(option) or {}, -- Annoying API changes...
    id = -1,
    has_exited = false,
    is_valid = true,
    callbacks = type(on_exit) == "function" and { on_exit } or {},
    no_callbacks = false,
    winnr = -1,
    bufnr = -1,
  }
  terminal.option.term = true
  setmetatable(terminal, Terminal)
  return terminal
end

---Clone a terminal process.
---@return futures.Terminal
function Terminal:clone()
  local terminal = Terminal.new(self.cmd, vim.deepcopy(self.option))
  terminal.callbacks = vim.deepcopy(self.callbacks)
  return terminal
end

---Run the terminal process.
---@return boolean ok True if terminal started successfully.
---@return integer winnr Window number of the terminal, -1 on failure.
---@return integer bufnr Buffer number of the terminal, -1 on failure.
function Terminal:start()
  if not lib.executable(self.cmd[1], true) then self.is_valid = false end
  if self.has_exited or not self.is_valid then return false, -1, -1 end
  local ok, winnr, bufnr = lib.new_split(self.option.split_pos or "belowright", {
    split_size = self.option.split_size,
    ratio_max = self.option.ratio_max,
    vertical = self.option.vertical,
    hide_number = true,
  })
  if not ok then
    return false, winnr, bufnr
  end
  self.option.on_exit = vim.schedule_wrap(function(job_id, data, event)
    self.has_exited = true
    if not self.no_callbacks then
      for _, f in ipairs(self.callbacks) do
        if type(f) == "function" then
          f(self, job_id, data, event)
        end
      end
    end
    if type(self.callback) == "function" then
      self.callback(self, job_id, data, event)
    end
  end)
  self.id = vim.fn.jobstart(self.cmd, self.option)
  if self.id == 0 then
    self.is_valid = false
    lib.warn("Invalid arguments.")
    return false, winnr, bufnr
  elseif self.id == -1 then
    self.is_valid = false
    lib.warn("Invalid executable.")
    return false, winnr, bufnr
  end
  self.winnr, self.bunnr = winnr, bufnr
  return true, winnr, bufnr
end

---Wrap a terminal process into a callback function which will start automatically.
---@return fun(term: futures.Terminal, job_id: integer, data: integer, event: string)
function Terminal:to_callback()
  return function(_, _, data, event)
    if data == 0 and event == "exit" then
      self:start()
    end
  end
end

---Continue with a callback function `next`.
---The terminal process will not start automatically.
---@param next fun(term: futures.Terminal, job_id: integer, data: integer, event: string)
---@return futures.Terminal self
function Terminal:continue_with(next)
  table.insert(self.callbacks, next)
  return self
end

---Await the terminal process.
---@return integer data
---@return string event
function Terminal:await()
  local _d, _e
  local _co = coroutine.running()
  if not _co then
    error("Process must await in an async block.")
  end
  self.callback = function(_, _, data, event)
    _d = data
    _e = event
    assert(coroutine.resume(_co))
  end
  if self:start() and not self.has_exited then
    coroutine.yield()
  end
  return _d, _e
end

return Terminal
