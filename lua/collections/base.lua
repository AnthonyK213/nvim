---@class collections.Iterable
local Iterable = {}

---Determines whether an element is in the collection.
---@param item any
---@return boolean
function Iterable:contains(item)
    error("Not implemented")
end

---Gets the number of elements contained in the collection.
---@return integer
function Iterable:count()
    error("Not implemented")
end

---Get the iterator of the collection.
---@return fun():integer?, any iterator
function Iterable:iter()
    error("Not implemented")
end
