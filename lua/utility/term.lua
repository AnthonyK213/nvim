local lib = require("utility.lib")

---@class TermProc
---@field cmd string[]
---@field option table
---@field on_exit function<TermProc, integer, integer, string>
---@field id integer
---@field is_valid boolean
---@field has_exited boolean
---@field extra_cb function[]
local TermProc = {}

TermProc.__index = TermProc

---Constructor.
---@param cmd string[]
---@param option? table
---@param on_exit? function
---@return TermProc
function TermProc.new(cmd, option, on_exit)
    local term_proc = {
        cmd = cmd,
        option = option or {},
        on_exit = on_exit,
        id = -1,
        has_exited = false,
        is_valid = true,
        extra_cb = {},
    }
    setmetatable(term_proc, TermProc)
    return term_proc
end

---Clone a terminal process.
---@return TermProc
function TermProc:clone()
    return TermProc.new(self.cmd, vim.deepcopy(self.option), self.on_exit)
end

---Run the terminal process.
function TermProc:start()
    if self.has_exited or not self.is_valid then return end
    local opt = vim.deepcopy(self.option)
    if not opt.split_pos or vim.tbl_contains({
        "aboveleft, belowright, topleft, botright"
    }, opt.split_pos) then
        opt.split_pos = "belowright"
    end
    if not opt.split_size or opt.split_size <= 0 or opt.split_size >= 1 then
        opt.split_size = 0.382
    end
    if opt.split_pos == "aboveleft" or opt.split_pos == "belowright" then
        local h = math.floor(vim.api.nvim_win_get_height(0) * opt.split_size)
        vim.cmd.new { mods = { split = opt.split_pos } }
        vim.api.nvim_win_set_height(0, h)
    else
        local w = math.floor(vim.api.nvim_win_get_width(0) * opt.split_size)
        vim.cmd.new { mods = { split = opt.split_pos } }
        vim.api.nvim_win_set_width(0, w)
    end
    opt.on_exit = function (job_id, data, event)
        self.has_exited = true
        if self.on_exit then
            self.on_exit(self, job_id, data, event)
        end
        for _, f in ipairs(self.extra_cb) do
            f(self, job_id, data, event)
        end
    end
    self.id = vim.fn.termopen(self.cmd, opt)
    if self.id == 0 then
        self.is_valid = false
        lib.notify_err("Invalid arguments.")
    elseif self.id == -1 then
        self.is_valid = false
        lib.notify_err("Invalid executable.")
    end
end

---Append callback function.
---@param callback function Callback function.
function TermProc:append_cb(callback)
    table.insert(self.extra_cb, callback)
end

---Continue with a terimal process.
---@param term_proc TermProc
function TermProc:continue_with(term_proc)
    self:append_cb(function(_, _, data, event)
        if data == 0 and event == "exit" then
            term_proc:start()
        end
    end)
end

---Await the task.
---@return integer data
---@return string event
function TermProc:await()
    local _d, _e
    local _co = coroutine.running()
    if not _co then
        error("Process must await in an async block.")
    end
    self:append_cb(function(_, _, data, event)
        _d = data
        _e = event
        coroutine.resume(_co)
    end)
    self:start()
    coroutine.yield()
    return _d, _e
end

return TermProc
