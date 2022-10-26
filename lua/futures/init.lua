local M = {}

---Start an async block.
---@param async_block function Async block to run.
function M.async(async_block)
    local _co = coroutine.create(async_block)
    coroutine.resume(_co)
end

---Execute the process one by one in `proc_list`.
---@param proc_list Process[]|TermProc[]
function M.proc_queue(proc_list)
    if vim.tbl_islist(proc_list) and #proc_list > 0 then
        for i = 1, #proc_list - 1, 1 do
            proc_list[i]:continue_with(proc_list[i + 1])
        end
        proc_list[1]:start()
    end
end

M.Task = require("futures.task")

M.Process = require("futures.proc")

M.Terminal = require("futures.term")

return M
