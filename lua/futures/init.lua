local M = {}
local lib = require("utility.lib")

---Start an async block.
---@param async_block function Async block to run.
function M.async(async_block)
    local _co = coroutine.create(async_block)
    coroutine.resume(_co)
end

---Execute the futrues one by one.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
function M.queue(fut_list)
    if not vim.tbl_islist(fut_list) or vim.tbl_isempty(fut_list) then
        lib.notify_err("`fut_list` should be a list-like table which is not empty.")
        return
    end
    for i = 1, #fut_list - 1, 1 do
        fut_list[i]:continue_with(fut_list[i + 1])
    end
    fut_list[1]:start()
end

---Polls multiple futures simultaneously.
---@param fut_list Process[]|Task[]|TermProc[] List of futrues.
---@param timeout? integer Number of milliseconds to wait, default -1(no timeout).
---@return table result List of results once complete.
function M.join(fut_list, timeout)
    local result = {}
    local count = 0
    local fut_count = #fut_list
    timeout = timeout or 10000
    if not vim.tbl_islist(fut_list) then
        lib.notify_err("`fut_list` should be a list-like table.")
        return result
    end
    local _co = coroutine.running()
    if _co and coroutine.status(_co) ~= "dead" then
        for i, fut in ipairs(fut_list) do
            fut:append_cb(function(...)
                result[i] = { ... }
                count = count + 1
                if count == fut_count then
                    coroutine.resume(_co)
                end
            end)
            fut:start()
        end
        if count ~= fut_count then
            if timeout < 0 then
                local timer = vim.loop.new_timer()
                timer:start(timeout, 0, vim.schedule_wrap(function()
                    if coroutine.status(_co) == "suspended" then
                        if count ~= fut_count then
                            print("Time out")
                        end
                        coroutine.resume(_co)
                    end
                end))
            end
            coroutine.yield(_co)
        end
    else
        for i, fut in ipairs(fut_list) do
            fut:append_cb(function(...)
                result[i] = { ... }
                count = count + 1
            end)
            fut:start()
        end
        if timeout < 0 then
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
    return result
end

M.Process = require("futures.proc")

M.Task = require("futures.task")

M.Terminal = require("futures.term")

return M
