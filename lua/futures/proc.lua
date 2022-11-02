local uv = vim.loop
local lib = require("utility.lib")
local util = require("futures.util")

---@class Process
---@field path string
---@field option table
---@field callback? function
---@field hanle userdata
---@field id integer
---@field is_valid boolean
---@field has_exited boolean
---@field callbacks function[]
---@field no_callbacks boolean
---@field on_stdin function?
---@field on_stdout function?
---@field on_stderr function?
---@field stdin uv_pipe_t
---@field stdout uv_pipe_t
---@field stderr uv_pipe_t
---@field stdin_buf string[]
---@field stdout_buf string[]
---@field stderr_buf string[]
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
        stdin_buf = {},
        stdout_buf = {},
        stderr_buf = {},
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
    self.stdout_buf = {}
    self.stderr_buf = {}
    local opt = { stdio = { self.stdin, self.stdout, self.stderr } }
    opt = vim.tbl_extend("keep", opt, self.option)
    self.handle, self.id = uv.spawn(self.path, opt, vim.schedule_wrap(
        function(code, signal)
            uv.shutdown(self.stdin)
            self.stdout:read_stop()
            self.stderr:read_stop()
            self.stdin:close()
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
    self.stdout:read_start(vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            table.insert(self.stdout_buf, data)
            if type(self.on_stdout) == "function" then
                self.on_stdout(data)
            end
        end
    end))
    self.stderr:read_start(vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            table.insert(self.stderr_buf, data)
            if type(self.on_stderr) == "function" then
                self.on_stderr(data)
            end
        end
    end))
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

---Print `stderr`.
function Process:notify_err()
    if not vim.tbl_isempty(self.stderr_buf) then
        lib.notify_err(table.concat(self.stderr_buf))
    end
end

return Process
