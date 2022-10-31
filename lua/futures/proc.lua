local uv = vim.loop
local lib = require("utility.lib")
local util = require("futures.util")

---@class Process
---@field path string
---@field option table
---@field callback function
---@field hanle userdata
---@field id integer
---@field is_valid boolean
---@field has_exited boolean
---@field callbacks function[]
---@field no_callbacks boolean
---@field stdin uv_pipe_t
---@field stdout uv_pipe_t
---@field stderr uv_pipe_t
---@field standard_input string[]
---@field standard_output string[]
---@field standard_error string[]
local Process = {}

Process.__index = Process

---Constructor.
---@param path string
---@param option? table
---@param on_exit? function
---@return Process
function Process.new(path, option, on_exit)
    local process = {
        path = path,
        option = option or {},
        handle = nil,
        id = -1,
        has_exited = false,
        is_valid = true,
        callbacks = type(on_exit) == "function" and { on_exit } or {},
        no_callbacks = false,
        stdin = uv.new_pipe(false),
        stdout = uv.new_pipe(false),
        stderr = uv.new_pipe(false),
        standard_input = {},
        standard_output = {},
        standard_error = {},
    }
    setmetatable(process, Process)
    return process
end

---Clone a process.
---@return Process
function Process:clone()
    local proc = Process.new(self.path, vim.deepcopy(self.option))
    proc.callbacks = vim.deepcopy(self.callbacks)
    return proc
end

---Run the process.
function Process:start()
    if not lib.executable(self.path) then self.is_valid = false end
    if self.has_exited or not self.is_valid then return end
    self.standard_output = {}
    self.standard_error = {}
    local on_read = function(err, data)
        if err then
            table.insert(self.standard_error, err)
            print(err)
        elseif data then
            table.insert(self.standard_output, data)
        end
    end
    local opt = { stdio = { self.stdin, self.stdout, self.stderr } }
    opt = vim.tbl_extend("keep", opt, self.option)
    self.handle, self.id = uv.spawn(self.path, opt, vim.schedule_wrap(
        function(code, signal)
            self.stdout:read_stop()
            self.stderr:read_stop()
            self.stdout:close()
            self.stderr:close()
            self.handle:close()
            self.has_exited = true
            if not self.no_callbacks then
                for _, f in ipairs(self.callbacks) do
                    if type(f) == "function" then
                        f(self, code, signal)
                    end
                end
            end
            if type(self.callback) == "function" then
                self.callback(self, code, signal)
            end
        end))
    self.stdout:read_start(vim.schedule_wrap(on_read))
    self.stderr:read_start(vim.schedule_wrap(on_read))
end

---Append callback function.
---@param callback function Callback function.
function Process:append_cb(callback)
    table.insert(self.callbacks, callback)
end

---Continue with a process.
---@param process Process
function Process:continue_with(process)
    self:append_cb(function(_, code, _)
        if code == 0 then
            process:start()
        end
    end)
end

---Await the process.
---@return integer code
---@return integer signal
function Process:await()
    local _c, _s
    local _co = coroutine.running()
    if not _co then
        error("Process must await in an async block.")
    end
    self.callback = function(_, code, signal)
        _c = code
        _s = signal
        util.try_resume(_co)
    end
    self:start()
    coroutine.yield()
    return _c, _s
end

return Process
