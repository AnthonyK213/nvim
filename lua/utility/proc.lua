local uv = vim.loop
local lib = require("utility.lib")

---@class Process
---@field path string
---@field option table
---@field on_exit function<Process, integer, integer>
---@field hanle userdata
---@field id integer
---@field has_exited boolean
---@field extra_cb function[]
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
---@param option table?
---@param on_exit function?
---@return Process
function Process.new(path, option, on_exit)
    local o = {
        path = path,
        option = option or {},
        on_exit = on_exit,
        handle = nil,
        id = -1,
        has_exited = false,
        extra_cb = {},
        stdin = uv.new_pipe(false),
        stdout = uv.new_pipe(false),
        stderr = uv.new_pipe(false),
        standard_input = {},
        standard_output = {},
        standard_error = {},
    }
    setmetatable(o, Process)
    return o
end

---Clone a process.
---@return Process
function Process:clone()
    return Process.new(self.path, vim.deepcopy(self.option), self.on_exit)
end

---Run the process.
function Process:start()
    if self.has_exited then return end
    self.standard_output = {}
    self.standard_error = {}
    local on_read = function (err, data)
        if err then
            table.insert(self.standard_error, err)
            lib.notify_err(err)
        elseif data then
            table.insert(self.standard_output, data)
        end
    end
    local opt = { stdio = { self.stdin, self.stdout, self.stderr } }
    opt = vim.tbl_extend("keep", opt, self.option)
    self.handle, self.id = uv.spawn(self.path, opt, vim.schedule_wrap(
    function (code, signal)
        self.stdout:read_stop()
        self.stderr:read_stop()
        self.stdout:close()
        self.stderr:close()
        self.handle:close()
        self.has_exited = true
        if self.on_exit then
            self.on_exit(self, code, signal)
        end
        for _, f in ipairs(self.extra_cb) do
            f(self, code, signal)
        end
    end))
    self.stdout:read_start(vim.schedule_wrap(on_read))
    self.stderr:read_start(vim.schedule_wrap(on_read))
end

---Append callback function.
---@param cb function<Process, integer, integer> Callback function.
function Process:append_cb(cb)
    table.insert(self.extra_cb, cb)
end

---Continue with a process.
---@param process Process
function Process:continue_with(process)
    self:append_cb(function (_, code, _)
        if code == 0 then
            process:start()
        end
    end)
end


return Process
