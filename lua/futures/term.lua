local lib = require("utility.lib")
local util = require("futures.util")

---@class TermProc
---@field cmd string[]
---@field option table
---@field on_exit function<TermProc, integer, integer, string>
---@field id integer
---@field is_valid boolean
---@field has_exited boolean
---@field extra_cb function[]
---@field winnr integer
---@field bunnr integer
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
        winnr = -1,
        bufnr = -1,
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
---@return boolean ok True if terminal started successfully.
---@return integer winnr Window number of the terminal, -1 on failure.
---@return integer bufnr Buffer number of the terminal, -1 on failure.
function TermProc:start()
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
        if self.on_exit then
            self.on_exit(self, job_id, data, event)
        end
        for _, f in ipairs(self.extra_cb) do
            f(self, job_id, data, event)
        end
    end)
    self.id = vim.fn.termopen(self.cmd, self.option)
    if self.id == 0 then
        self.is_valid = false
        lib.notify_err("Invalid arguments.")
        return false, winnr, bufnr
    elseif self.id == -1 then
        self.is_valid = false
        lib.notify_err("Invalid executable.")
        return false, winnr, bufnr
    end
    self.winnr, self.bunnr = winnr, bufnr
    return true, winnr, bufnr
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

---Await the terminal process.
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
        util.try_resume(_co)
    end)
    self:start()
    coroutine.yield()
    return _d, _e
end

return TermProc
