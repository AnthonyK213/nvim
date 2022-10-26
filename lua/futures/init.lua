local M = {}

---Start an async block.
---@param async_block function Async block to run.
function M.async(async_block)
    local _co = coroutine.create(async_block)
    coroutine.resume(_co)
end

---Execute the processes|tasks one by one in `fut_list`.
---@param fut_list Process[]|Task[]|TermProc[]
function M.queue(fut_list)
    if vim.tbl_islist(fut_list) and #fut_list > 0 then
        for i = 1, #fut_list - 1, 1 do
            fut_list[i]:continue_with(fut_list[i + 1])
        end
        fut_list[1]:start()
    end
end

M.Process = require("futures.proc")

M.Task = require("futures.task")

M.Terminal = require("futures.term")

return M
