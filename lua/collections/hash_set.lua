local Iterator = require("collections.iter")
local util = require("collections.util")

-- For key in Lua table cannot be `nil`.
if not _G.NULL then
    _G.NULL = {}
end

---@class collections.HashSet
---@field private length integer
---@field private data table
---@operator call:collections.HashSet
local HashSet = {}

---@private
HashSet.__index = HashSet

setmetatable(HashSet, { __call = function(o, ...) return o.new(...) end })

---Constructor.
---@return collections.HashSet
function HashSet.new(...)
    local hash_set = {
        length = 0,
        data = {},
    }
    setmetatable(hash_set, HashSet)
    for i = 1, select("#", ...), 1 do
        local item = select(i, ...)
        hash_set:add(item)
    end
    return hash_set
end

---Adds the specified element to a set.
---@param item any The element to add to the set.
---@return boolean ok `true` if the element is added to the `HashSet`; false if the element is already present.
function HashSet:add(item)
    if item == nil then
        item = NULL
    end
    if self.data[item] ~= nil then
        return false
    end
    self.data[item] = true
    self.length = self.length + 1
    return true
end

---Removes all elements from a `HashSet`.
function HashSet:clear()
    for v, _ in pairs(self.data) do
        self[v] = nil
    end
    self.length = 0
end

---Determines whether a `HashSet` contains the specified element.
---@param item any The element to locate in the `HashSet`.
---@return boolean exists `true` if the HashSet contains the specified element; otherwise, false.
function HashSet:contains(item)
    if item == nil then
        item = NULL
    end
    return self.data[item] ~= nil
end

---Gets the number of elements that are contained in a set.
---@return integer
function HashSet:count()
    return self.length
end

---Removes all elements in the specified collection from the current `HashSet`.
---@param iterable any The collection of items to remove from the `HashSet`.
function HashSet:except_with(iterable)
    for _, v in Iterator(iterable):consume() do
        self:remove(v)
    end
end

---Get the iterator of the `HashSet`.
---@return fun():integer?, any iterator
function HashSet:iter()
    local keys = vim.tbl_keys(self.data)
    local index = 0
    return function()
        index = index + 1
        if index <= self.length then
            if keys[index] == NULL then
                return index, nil
            else
                return index, keys[index]
            end
        end
    end
end

---Modifies the current `HashSet` to contain only elements that are present in
---that object and in the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
function HashSet:intersect_with(iterable)
    local contains = util.get_contains(iterable)
    if not contains then
        return
    end
    for v, _ in pairs(self.data) do
        local u
        if v == NULL then
            u = nil
        else
            u = v
        end
        if not contains(iterable, u) then
            self.data[v] = nil
            self.length = self.length - 1
        end
    end
end

---@private
---Determines whether a `HashSet` is a [proper] subset of the specified collection.
---@param iterable any
---@param proper boolean
---@return boolean
function HashSet:_is_subset_of(iterable, proper)
    local count = util.get_count(iterable)
    local comparer = proper and function(a, b)
            return a >= b
        end or function(a, b)
            return a > b
        end
    if not count or comparer(self:count(), count(iterable)) then
        return false
    end
    local contains = util.get_contains(iterable)
    if not contains then
        return false
    end
    for v, _ in pairs(self.data) do
        local u
        if v == NULL then
            u = nil
        else
            u = v
        end
        if not contains(iterable, u) then
            return false
        end
    end
    return true
end

---@private
---Determines whether a `HashSet` is a [proper] superset of the specified collection.
---@param iterable any
---@param proper boolean
---@return boolean
function HashSet:_is_superset_of(iterable, proper)
    local count = util.get_count(iterable)
    local comparer = proper and function(a, b)
            return a <= b
        end or function(a, b)
            return a < b
        end
    if not count or comparer(self:count(), count(iterable)) then
        return false
    end
    for _, v in Iterator(iterable):consume() do
        if not self:contains(v) then
            return false
        end
    end
    return true
end

---Determines whether a `HashSet` is a proper subset of the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean result `true` if the `HashSet` is a proper subset of other; otherwise, `false`.
function HashSet:is_proper_subset_of(iterable)
    return self:_is_subset_of(iterable, true)
end

---Determines whether a `HashSet` is a proper superset of the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean result `true` if the `HashSet` is a proper superset of other; otherwise, `false`.
function HashSet:is_proper_superset_of(iterable)
    return self:_is_superset_of(iterable, true)
end

---Determines whether a `HashSet` is a subset of the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean result `true` if the `HashSet` is a subset of other; otherwise, `false`.
function HashSet:is_subset_of(iterable)
    return self:_is_subset_of(iterable, false)
end

---Determines whether a `HashSet` is a superset of the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean result `true` if the `HashSet` is a superset of other; otherwise, `false`.
function HashSet:is_superset_of(iterable)
    return self:_is_superset_of(iterable, false)
end

---Determines whether a `HashSet` and the specified collection contain the same elements.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean is_equal `true` if the HashSet is equal to other; otherwise, false.
function HashSet:set_equals(iterable)
    local count = util.get_count(iterable)
    if not count or self:count() ~= count(iterable) then
        return false
    end
    for _, v in Iterator(iterable):consume() do
        if not self:contains(v) then
            return false
        end
    end
    return true
end

---Determines whether the current `HashSet` and a specified collection share common elements.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean overlapped `true` if the `HashSet` and other share at least one common element; otherwise, `false`.
function HashSet:overlaps(iterable)
    for _, v in Iterator(iterable):consume() do
        if self:contains(v) then
            return true
        end
    end
    return false
end

---Removes the specified element from a `HashSet`.
---@param item any The element to remove.
---@return boolean ok `true` if the element is successfully found and removed; otherwise, `false`. This method returns false if item is not found in the `HashSet`.
function HashSet:remove(item)
    if item == nil then
        item = NULL
    end
    if self.data[item] == nil then
        return false
    end
    self.data[item] = nil
    self.length = self.length - 1
    return true
end

---Removes all elements that match the conditions defined by the specified
---predicate from a `HashSet`.
---@param match fun(item: any):boolean The predicate that defines the conditions of the elements to remove.
---@return integer count The number of elements that were removed from the `HashSet`.
function HashSet:remove_where(match)
    local count = 0
    for v, _ in pairs(self.data) do
        local u
        if v == NULL then
            u = nil
        else
            u = v
        end
        if match(u) then
            count = count + 1
            self.data[v] = nil
            self.length = self.length - 1
        end
    end
    return count
end

---Modifies the current `HashSet` to contain only elements that are present either in that object or in the specified collection, but not both.
---@param iterable any The collection to compare to the current `HashSet`.
function HashSet:symmetric_except_with(iterable)
    for _, v in Iterator(iterable):consume() do
        if self:contains(v) then
            self:remove(v)
        else
            self:add(v)
        end
    end
end

---Modifies the current `HashSet` to contain all elements that are present in itself, the specified collection, or both.
---@param iterable any The collection to compare to the current `HashSet`.
function HashSet:union_with(iterable)
    for _, v in Iterator(iterable):consume() do
        self:add(v)
    end
end

---@private
---Returns a string that represents the current object.
function HashSet:__tostring()
    return require("collections.util").iter_inspect(self, HashSet, "HashSet")
end

return HashSet
