local Iterator = require("collections.iter")

---@class collections.HashSet
---@field private length integer
---@field private data table
---@operator call:collections.HashSet
local HashSet = {}

---@private
HashSet.__index = HashSet

setmetatable(HashSet, { __call = function(o) return o.new() end })

---Constructor.
---@return collections.HashSet
function HashSet.new()
    local hash_set = {
        length = 0,
        data = {},
    }
    setmetatable(hash_set, HashSet)
    return hash_set
end

---Adds the specified element to a set.
---@param item any The element to add to the set.
---@return boolean ok `true` if the element is added to the `HashSet`; false if the element is already present.
function HashSet:add(item)
    if item == nil or self.data[item] ~= nil then
        return false
    end
    self.data[item] = true
    self.length = self.length + 1
    return true
end

---Removes all elements from a `HashSet`.
function HashSet:clear()
    for k, _ in pairs(self.data) do
        self[k] = nil
    end
    self.length = 0
end

---Determines whether a `HashSet` contains the specified element.
---@param item any The element to locate in the `HashSet`.
---@return boolean exists `true` if the HashSet contains the specified element; otherwise, false.
function HashSet:contains(item)
    if item == nil then
        return false
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
            return index, keys[index]
        end
    end
end

---Modifies the current `HashSet` to contain only elements that are present in
---that object and in the specified collection.
---@param iterable any The collection to compare to the current `HashSet`.
function HashSet:intersect_with(iterable)
    local contains
    if vim.tbl_islist(iterable) then
        contains = vim.tbl_contains
    else
        contains = iterable.contains
    end
    if not vim.is_callable(contains) then
        return
    end
    for k, _ in pairs(self.data) do
        if not contains(iterable, k) then
            self.data[k] = nil
            self.length = self.length - 1
        end
    end
end

function HashSet:is_proper_subset_of(iterable)

end

function HashSet:is_proper_superset_of(iterable)

end

function HashSet:is_subset_of(iterable)

end

function HashSet:is_superset_of(iterable)

end

---Determines whether a `HashSet` and the specified collection contain the same elements.
---@param iterable any The collection to compare to the current `HashSet`.
---@return boolean is_equal `true` if the HashSet is equal to other; otherwise, false.
function HashSet:set_equals(iterable)
    local count
    if vim.tbl_islist(iterable) then
        count = #iterable
    elseif vim.is_callable(iterable.count) then
        count = iterable:count()
    else
        return false
    end
    if self:count() ~= count then
        return false
    end
    for _, v in Iterator(iterable):consume() do
        if not self:contains(v) then
            return false
        end
    end
    return true
end

function HashSet:overlaps(iterable)

end

---Removes the specified element from a `HashSet`.
---@param item any The element to remove.
---@return boolean ok `true` if the element is successfully found and removed; otherwise, `false`. This method returns false if item is not found in the `HashSet`.
function HashSet:remove(item)
    if item == nil or self.data[item] == nil then
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
    for k, _ in pairs(self.data) do
        if match(k) then
            count = count + 1
            self.data[k] = nil
            self.length = self.length - 1
        end
    end
    return count
end

function HashSet:symmetric_except_with(iterable)

end

function HashSet:union_with(iterable)

end

---@private
---Returns a string that represents the current object.
function HashSet:__tostring()
    return require("collections.util").iter_inspect(self, HashSet, "HashSet")
end

return HashSet
