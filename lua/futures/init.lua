local M = {}
local lib = require("utility.lib")

---@class futures.Future Represents an operation which will produce values in the future.
---@field private action function Function that represents the code to execute.
---@field private varargs table Arguments for `action`.
---@field private result any[] Result of the `Future`, stored in a list.
local Future = {}

---@private
Future.__index = Future

---@private
---Constructor.
---@param action function Function that represents the code to execute.
---@param ... any Arguments for `action`.
---@return futures.Future
function Future.new(action, ...)
  local future = {
    action = action,
    varargs = lib.tbl_pack(...)
  }
  setmetatable(future, Future)
  return future
end

---Poll the future.
function Future:await()
  self.result = lib.tbl_pack(self.action(lib.tbl_unpack(self.varargs)))
  return lib.tbl_unpack(self.result)
end

---@class futures.JoinHandle
---@field private co thread
local JoinHandle = {}

---@private
JoinHandle.__index = JoinHandle

---@private
---Constructor.
---@param co thread
---@return futures.JoinHandle
function JoinHandle.new(co)
  local handle = {
    co = co,
  }
  setmetatable(handle, JoinHandle)
  return handle
end

---Wait for the associated thread to finish.
function JoinHandle:join()
  if not coroutine.running() then
    vim.wait(1e8, function()
      return coroutine.status(self.co) == "dead"
    end)
    self.co = nil
  else
    self:await()
  end
end

---@private
---Await the spawned task.
function JoinHandle:await()
  if not coroutine.running() then
    vim.notify("Not in any asynchronous block", vim.log.levels.WARN)
    return
  end
  while coroutine.status(self.co) ~= "dead" do
    coroutine.yield()
  end
  self.co = nil
end

---Check `fut_list` for `futures.join` & `futures.select`.
---@param fut_list futures.Process[]|futures.Task[]|futures.Terminal[] List of futrues.
---@return boolean
local function check_fut_list(fut_list)
  if not vim.islist(fut_list) or vim.tbl_isempty(fut_list) then
    lib.notify_err("`fut_list` should be a list-like table which is not empty.")
    return false
  end
  return true
end

---Wrap a function into an asynchronous function.
---@param func function Funtion to wrap.
---@return fun(...):futures.Future async_func Wrapped asynchronous function.
function M.async(func)
  return function(...)
    return Future.new(func, ...)
  end
end

---Await an asynchronous method or an awaitable object.
---@param obj any Object to await.
---@return any
function M.await(obj)
  return obj:await()
end

---Spawns a new asynchronous task.
---@param task function|futures.Future
function M.spawn(task)
  ---@type function
  local _f
  local _type = type(task)
  local _context = coroutine.running()

  if _type == "function" then
    if _context then
      _f = function()
        task()
        vim.uv.new_async(function()
          coroutine.resume(_context)
        end):send()
      end
    else
      _f = task
    end
  elseif getmetatable(task) == Future then
    if _context then
      _f = function()
        M.await(task)
        vim.uv.new_async(function()
          coroutine.resume(_context)
        end):send()
      end
    else
      _f = function() M.await(task) end
    end
  else
    error("`task` is invalid.")
  end

  local _co = coroutine.create(_f)
  coroutine.resume(_co)

  return JoinHandle.new(_co)
end

---Execute the futrues one by one.
---@param fut_list futures.Process[]|futures.Task[]|futures.Terminal[] List of futrues.
function M.queue(fut_list)
  if not check_fut_list(fut_list) then return end
  for i = 1, #fut_list - 1, 1 do
    fut_list[i]:continue_with(fut_list[i + 1]:to_callback())
  end
  fut_list[1]:start()
end

---Polls multiple futures simultaneously.
---@param fut_list futures.Process[]|futures.Task[]|futures.Terminal[] List of futrues.
---@param timeout? integer Number of milliseconds to wait, default no timeout.
---@return table result List of results once complete.
function M.join(fut_list, timeout)
  local result = {}
  local count = 0
  if not check_fut_list(fut_list) then return result end
  if type(timeout) == "number" and timeout < 0 then
    lib.notify_err("Invalid `timeout`.")
    return result
  end
  local fut_count = #fut_list
  local _co = coroutine.running()
  if _co and coroutine.status(_co) ~= "dead" then
    for i, fut in ipairs(fut_list) do
      fut.callback = function(...)
        result[i] = lib.tbl_pack(...)
        count = count + 1
        if count == fut_count then
          assert(coroutine.resume(_co))
        end
      end
      fut:start()
    end
    if count ~= fut_count then
      if timeout then
        local timer = vim.uv.new_timer()
        timer:start(timeout, 0, vim.schedule_wrap(function()
          timer:stop()
          timer:close()
          if coroutine.status(_co) == "suspended" then
            if count ~= fut_count then
              print("Time out")
            end
            assert(coroutine.resume(_co))
          end
        end))
      end
      coroutine.yield()
    end
  else
    for i, fut in ipairs(fut_list) do
      fut.callback = function(...)
        result[i] = lib.tbl_pack(...)
        count = count + 1
      end
      fut:start()
    end
    local ok, code = vim.wait(timeout or 1e8, function()
      return count == fut_count
    end, 10)
    if not ok then
      if code == -1 then
        print("Time out.")
      else
        print("Interrupted.")
      end
    end
  end
  return lib.tbl_unpack(result)
end

---Polls multiple futures simultaneously,
---returns once the first future is complete.
---Callbacks of each future will be ignored.
---@param fut_list futures.Process[]|futures.Task[]|futures.Terminal[] List of futrues.
function M.select(fut_list)
  local result
  if not check_fut_list(fut_list) then return result end
  local done = false
  local _co = coroutine.running()
  if _co and coroutine.status(_co) ~= "dead" then
    for _, fut in ipairs(fut_list) do
      fut.no_callbacks = true
      fut.callback = function(...)
        if not done then
          result = lib.tbl_pack(...)
          done = true
          assert(coroutine.resume(_co))
        end
      end
      fut:start()
    end
    if not done then
      coroutine.yield()
    end
  else
    for _, fut in ipairs(fut_list) do
      fut.no_callbacks = true
      fut.callback = function(...)
        if not done then
          result = lib.tbl_pack(...)
          done = true
        end
      end
      fut:start()
    end
    local ok, code = vim.wait(1e8, function() return done end, 10)
    if not ok then
      if code == -1 then
        print("Time out.")
      else
        print("Interrupted.")
      end
    end
  end
  return result
end

---Wrapper of lua module `vim.ui`.
M.ui = {
  ---Prompts the user for input.
  ---@param opts table Additional options. See `input()`.
  ---@return string? input Content the user typed.
  input = function(opts)
    return M.Task.new(vim.ui.input, opts):set_async(true):await()
  end,
  ---Prompts the user to pick a single item from a collection of entries.
  ---@param items table Arbitrary items.
  ---@param opts table Additional options. See `select()`.
  ---@return any? item The chosen item.
  ---@return integer? idx The 1-based index of `item` within `items`.
  select = function(items, opts)
    return M.Task.new(vim.ui.select, items, opts):set_async(true):await()
  end,
}

---@type table<string, function>
M.uv = {}

setmetatable(M.uv, {
  __index = function(_, k)
    return function(...)
      return M.Task.from_uv(k, ...):await()
    end
  end
})

M.Process = require("futures.proc")

M.Task = require("futures.task")

M.Terminal = require("futures.term")

M.Terminal2 = require("futures.term2")

M.fs = {
  ---Opens a text file, reads all the text in the file into a string,
  ---and then closes the file.
  ---@param path string The file to open for reading.
  ---@return string? content A string containing all the text in the file.
  read_all_text = function(path)
    local err, fd, stat, data
    err, fd = M.uv.fs_open(path, "r", 438)
    assert(not err, err)
    lib.try(function()
      err, stat = M.uv.fs_fstat(fd)
      assert(not err, err)
      err, data = M.uv.fs_read(fd, stat.size, 0)
      assert(not err, err)
    end).catch(function(ex)
      print(ex)
    end).finally(function()
      M.uv.fs_close(fd)
    end)
    return data
  end
}

return M
