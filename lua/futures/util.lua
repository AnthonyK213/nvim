local M = {}

---Try resume the coroutine `co`, if not successful, print the error.
---Useful in callback functions.
---@param co thread Coroutine to resume.
function M.try_resume(co)
    local ok, err = coroutine.resume(co)
    if not ok then print(err) end
end

return M
