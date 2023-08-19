local lib = require("utility.lib")

---@type futures.ProcessHandle[]
local handles = {}
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        for _, handle in ipairs(handles) do
            if not handle:kill() then
                handle:kill(vim.uv.constants.SIGKILL)
            end
        end
    end
})

---@class futures.ProcessHandle
---@field private _data userdata uv_process_t.
---@field private _pid integer Process ID.
---@field private _exited boolean
local ProcessHandle = {}

---@private
ProcessHandle.__index = ProcessHandle

---Constructor.
---@param data userdata uv_process_t.
---@param pid integer Process ID.
---@return futures.ProcessHandle
function ProcessHandle.new(data, pid)
    local handle = {
        _data = data,
        _pid = pid,
        _exited = false,
    }
    setmetatable(handle, ProcessHandle)
    return handle
end

---`pid` getter.
function ProcessHandle:pid()
    return self._pid
end

---`exited` getter.
function ProcessHandle:exited()
    return self._exited
end

function ProcessHandle:close()
    self._data:close()
    self._exited = true
end

---Sends te specified signal to the process and kill it.
---@param signum? integer|string Signal, default `SIGTERM`.
---@return integer ok 0 or fail.
function ProcessHandle:kill(signum)
    if self._exited then
        return 0
    end
    local code = self._data:kill(signum or vim.uv.constants.SIGTERM)
    if code then
        self:close()
    end
    return code
end

---@class futures.Process Provides access and control to local processes.
---@field path string Path to the system local executable.
---@field option table See `vim.uv.spawn()`.
---@field callback? fun(proc: futures.Process, code: integer, signal: integer) Callback invoked when the process exits.
---@field protected handle? futures.ProcessHandle Process handle.
---@field is_valid boolean True if the process is valid.
---@field protected callbacks fun(proc: futures.Process, code: integer, signal: integer)[]
---@field no_callbacks boolean Mark the process that its `callbacks` will not be executed.
---@field on_stdin? fun(data: string) Callback on standard input.
---@field on_stdout? fun(data: string) Callback on standard output.
---@field on_stderr? fun(data: string) Callbakc on standard error.
---@field protected stdin userdata Standard input handle.
---@field protected stdout userdata Standard output handle.
---@field protected stderr userdata Standard error handle.
---@field stdin_buf string[] Standard input buffer.
---@field stdout_buf string[] Standard output buffer.
---@field stderr_buf string[] Standard error buffer.
---@field record boolean If true, `stdout` and `stderr` will be recorded into the buffer.
local Process = {}

---@private
Process.__index = Process

---Constructor.
---@param path string Path to the system local executable.
---@param option? table See `vim.uv.spawn()`.
---@param on_exit? fun(proc: futures.Process, code: integer, signal: integer) Callback invoked when the process exits (discouraged, use `continue_with` instead).
---@return futures.Process
function Process.new(path, option, on_exit)
    local process = {
        path = path,
        option = option or {},
        handle = nil,
        is_valid = true,
        callbacks = type(on_exit) == "function" and { on_exit } or {},
        no_callbacks = false,
        stdin = vim.uv.new_pipe(false),
        stdout = vim.uv.new_pipe(false),
        stderr = vim.uv.new_pipe(false),
        stdin_buf = {},
        stdout_buf = {},
        stderr_buf = {},
        record = false,
    }
    setmetatable(process, Process)
    return process
end

---Clone a process.
---@return futures.Process
function Process:clone()
    local proc = Process.new(self.path, vim.deepcopy(self.option))
    proc.callbacks = vim.deepcopy(self.callbacks)
    return proc
end

---Run the process.
---@return boolean ok True if process starts successfully.
function Process:start()
    if not lib.executable(self.path) then self.is_valid = false end
    if self:has_exited() or not self.is_valid then return false end

    self.stdout_buf = {}
    self.stderr_buf = {}
    local opt = { stdio = { self.stdin, self.stdout, self.stderr } }
    opt = vim.tbl_extend("keep", opt, self.option)

    local handle, pid = vim.uv.spawn(self.path, opt, vim.schedule_wrap(function(code, signal)
        vim.uv.shutdown(self.stdin)
        self.stdout:read_stop()
        self.stderr:read_stop()
        self.stdin:close()
        self.stdout:close()
        self.stderr:close()
        self.handle:close()
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

    if not handle then return false end

    self.handle = ProcessHandle.new(handle, pid)
    table.insert(handles, self.handle)

    self.stdout:read_start(vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            if self.record then
                table.insert(self.stdout_buf, data)
            end
            if type(self.on_stdout) == "function" then
                self.on_stdout(data)
            end
        end
    end))

    self.stderr:read_start(vim.schedule_wrap(function(err, data)
        assert(not err, err)
        if data then
            if self.record then
                table.insert(self.stderr_buf, data)
            end
            if type(self.on_stderr) == "function" then
                self.on_stderr(data)
            end
        end
    end))

    return true
end

---Wrap a process into a callback function which will start automatically.
---@return fun(proc: futures.Process, code: integer, signal: integer)
function Process:to_callback()
    return function(_, code, _)
        if code == 0 then
            self:start()
        end
    end
end

---Continue with a callback function `next`.
---The process will not start automatically.
---@param next fun(proc: futures.Process, code: integer, signal: integer)
---@return futures.Process self
function Process:continue_with(next)
    table.insert(self.callbacks, next)
    return self
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
        assert(coroutine.resume(_co))
    end
    if self:start() and not self:has_exited() then
        coroutine.yield()
    end
    return _c, _s
end

---Print `stderr`.
function Process:notify_err()
    if self.record and not vim.tbl_isempty(self.stderr_buf) then
        lib.notify_err(table.concat(self.stderr_buf))
    end
end

---Write to standard input.
---@param data string|string[] Data to write.
---@return boolean is_writable True if `stdin` is writable.
function Process:write(data)
    if vim.uv.is_writable(self.stdin) then
        vim.uv.write(self.stdin, data)
        return true
    end
    return false
end

---Write to standard input and wait for the response.
---@param data string|string[] Data to write.
---@return string? err Error message.
function Process:write_and_wait(data)
    local task = require("futures.task").from_uv("write", self.stdin, data)
    if coroutine.running() then
        return task:await()
    else
        return task:wait()
    end
end

---Whether process has exited.
---@return boolean
function Process:has_exited()
    if self.handle then
        return self.handle:exited()
    end
    return false
end

---Sends te specified signal to the process and kill it.
---@param signum? integer|string Signal, default `SIGTERM`.
---@return integer? ok 0 or fail.
function Process:kill(signum)
    if self.handle then
        return self.handle:kill(signum)
    end
end

return Process
