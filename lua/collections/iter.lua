---@class collections.Iterator
---@field move_next fun():integer?, any
---@operator call:collections.Iterator
local Iterator = {}

---@private
Iterator.__index = Iterator

setmetatable(Iterator, { __call = function(o, iterable) return o.get(iterable) end })

---Get iterator of a iteralble collection.
---@param iterable any An iteralble collection.
---@return collections.Iterator
function Iterator.get(iterable)
    local iter = {}
    if vim.tbl_islist(iterable) then
        local index = 0
        iter.move_next = function()
            index = index + 1
            if index <= #iterable then
                return index, iterable[index]
            end
        end
    elseif type(iterable.iter) == "function" then
        iter.move_next = iterable:iter()
    else
        error("Failed to get the iterator")
    end
    setmetatable(iter, Iterator)
    return iter
end

---Consume the iterator.
---@return unknown
function Iterator:consume()
    return self.move_next
end

---Applies a specified function to the corresponding elements of two sequences,
---producing a sequence of the results.
---@param iterator collections.Iterator
---@param selector? fun(a: any, b: any):any
---@return collections.Iterator
function Iterator:zip(iterator, selector)
    local index = 0
    local iter = {
        move_next = function()
            index = index + 1
            local i, v1 = self.move_next()
            local j, v2 = iterator.move_next()
            if not (i or j) then return end
            return index, selector and selector(v1, v2) or { v1, v2 }
        end
    }
    setmetatable(iter, Iterator)
    return iter
end

return Iterator
