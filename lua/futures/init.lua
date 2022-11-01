local M = {}
local lib = require("utility.lib")
local util = require("futures.util")
local try = util.try_call

---Check `fut_list` for `futures.join` & `futures.select`.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
---@return boolean
local function check_fut_list(fut_list)
    if not vim.tbl_islist(fut_list) or vim.tbl_isempty(fut_list) then
        lib.notify_err("`fut_list` should be a list-like table which is not empty.")
        return false
    end
    return true
end

---Start an async block.
---@param async_block function Async block to run.
function M.async(async_block)
    local _co = coroutine.create(async_block)
    coroutine.resume(_co)
end

---Execute the futrues one by one.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
function M.queue(fut_list)
    if not check_fut_list(fut_list) then return end
    for i = 1, #fut_list - 1, 1 do
        fut_list[i]:continue_with(fut_list[i + 1])
    end
    fut_list[1]:start()
end

---Polls multiple futures simultaneously.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
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
            fut.no_callbacks = true
            fut.callback = function(...)
                result[i] = { ... }
                count = count + 1
                if count == fut_count then
                    util.try_resume(_co)
                end
            end
            fut:start()
        end
        if count ~= fut_count then
            if timeout then
                local timer = vim.loop.new_timer()
                timer:start(timeout, 0, vim.schedule_wrap(function()
                    timer:stop()
                    timer:close()
                    if coroutine.status(_co) == "suspended" then
                        if count ~= fut_count then
                            print("Time out")
                        end
                        util.try_resume(_co)
                    end
                end))
            end
            coroutine.yield(_co)
        end
    else
        for i, fut in ipairs(fut_list) do
            fut.no_callbacks = true
            fut.callback = function(...)
                result[i] = { ... }
                count = count + 1
            end
            fut:start()
        end
        if not timeout then
            timeout = 100000000
        end
        local ok, code = vim.wait(timeout, function()
            return count == fut_count
        end, 10)
        if not ok then
            if code == -1 then
                print("Time out.")
            else
                print("Interruped.")
            end
        end
    end
    return unpack(result)
end

---Polls multiple futures simultaneously,
---returns once the first future is complete.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
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
                    result = { ... }
                    done = true
                    util.try_resume(_co)
                end
            end
            fut:start()
        end
        if not done then
            coroutine.yield(_co)
        end
    else
        for _, fut in ipairs(fut_list) do
            fut.no_callbacks = true
            fut.callback = function(...)
                if not done then
                    result = { ... }
                    done = true
                end
            end
            fut:start()
        end
        local ok, code = vim.wait(100000000, function() return done end, 10)
        if not ok then
            if code == -1 then
                print("Time out.")
            else
                print("Interruped.")
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
        return M.Task.new(vim.ui.input, {
            is_async = true,
            args = { opts }
        }):await()
    end,
    ---Prompts the user to pick a single item from a collection of entries.
    ---@param items table Arbitrary items.
    ---@param opts table Additional options.
    ---@return any? item The chosen item.
    ---@return integer? idx The 1-based index of `item` within `items`.
    select = function(items, opts)
        return M.Task.new(vim.ui.select, {
            is_async = true,
            args = { items, opts }
        }):await()
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

M.fs = {
    ---Opens a text file, reads all the text in the file into a string,
    ---and then closes the file.
    ---@param path string The file to open for reading.
    ---@return string? content A string containing all the text in the file.
    read_all_text = function(path)
        local fd = try(M.uv.fs_open, path, "r", 438)
        local stat = try(M.uv.fs_fstat, fd)
        local data = try(M.uv.fs_read, fd, stat.size, 0)
        try(M.uv.fs_close, fd)
        return data
    end
}

return M
