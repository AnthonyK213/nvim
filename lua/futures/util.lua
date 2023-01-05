local lib = require("utility.lib")

local M = {}

---Try resume the coroutine `co`, if not successful, print the error.
---Useful in callback functions.
---@param co thread Coroutine to resume.
function M.try_resume(co)
    local ok, err = coroutine.resume(co)
    if not ok then print(err) end
end

---Call `action`, whose first return value stands for `error`.
---Throw the error or return the rest of return values.
---@param action function
---@param ... any
---@return any
function M.try_call(action, ...)
    local result = lib.tbl_pack(action(...))
    assert(not result[1], result[1])
    return lib.tbl_unpack(result, 2)
end

return M
