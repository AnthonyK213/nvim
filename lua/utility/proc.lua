local uv = vim.loop

---@class Process
---@field path string
---@field option table
---@field on_exit function
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
---@param option table
---@param on_exit function
---@return Process
function Process.new(path, option, on_exit)
    local o = {
        path = path,
        option = option,
        on_exit = on_exit,
        stdin = uv.new_pipe(false),
        stdout = uv.new_pipe(false),
        stderr = uv.new_pipe(false),
        standard_input = {},
        standard_output = {},
        standard_error = {},
        handle = -1,
        id = -1,
        has_exited = false,
    }
    setmetatable(o, Process)
    return o
end

---Clone a process.
---@return Process
function Process:clone()
    return Process.new(self.path, vim.deepcopy(self.option), self.on_exit)
end

function Process:on_read(err, data)
    if err then
        table.insert(self.standard_error, err)
    elseif data then
        table.insert(self.standard_output, data)
    end
end

---Run the process.
function Process:start()
    self.standard_output = {}
    self.standard_error = {}
    self.handle, self.id = uv.spawn(self.path, self.option, vim.schedule_wrap(
    function (code, signal)
        self.stdout:read_stop()
        self.stderr:read_stop()
        self.stdout:close()
        self.stderr:close()
        self.handle:close()
        self.has_exited = true
        self.on_exit(code, signal)
    end))
    self.stdout:read_start(vim.schedule_wrap(self.on_read))
    self.stderr:read_start(vim.schedule_wrap(self.on_read))
end

---Continue with a process.
---@param process Process
function Process:continue_with(process)
    local on_exit = self.on_exit
    self.on_exit = function (code, signal)
        on_exit(code, signal)
        if code == 0 then
            process:start()
        end
    end
end


return Process
