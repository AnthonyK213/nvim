local lib = require("utility.lib")

---@class collections.Iterator
---@field private args table
local Iterator = {}

---@private
Iterator.__index = Iterator

---Get iterator of a iteralble collection.
---@param iterable any An iteralble collection.
---@return collections.Iterator
function Iterator.get(iterable)
    local iter = {}
    if vim.tbl_islist(iterable) then
        iter.args = lib.tbl_pack(ipairs(iterable))
    elseif type(iterable.iter) == "function" then
        iter.args = lib.tbl_pack(iterable:iter())
    else
        error("Failed to get the iterator")
    end
    setmetatable(iter, Iterator)
    return iter
end

---@private
---Consume the iterator.
---@return unknown
function Iterator:__call()
    return lib.tbl_unpack(self.args)
end

return Iterator
