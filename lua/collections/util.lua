local M = {}

---Get iterator of a collection.
---@param collection any
---@return fun(collection:any):fun():integer,any
function M.get_iter(collection)
    if vim.tbl_islist(collection) then
        return ipairs
    elseif type(collection.iter) == "function" then
        return collection.iter
    else
        error("Failed to get the iterator")
    end
end

return M
