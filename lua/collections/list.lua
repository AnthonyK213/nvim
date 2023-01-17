---Boundary check.
---@param list collections.List
---@param index integer
---@param min? integer
---@param max? integer
local function boundary_check(list, index, min, max)
    if math.floor(index) ~= index then
        error("Index must be an integer")
    end
    if index < (min or 1) or index > (max or list:count()) then
        error("Index out of bounds")
    end
end

---@class collections.List Represents a list of objects that can be accessed by index. Provides methods to search, sort, and manipulate lists.
---@field private data any[]
---@field private length integer
local List = {}

List.__index = function(o, key)
    if type(key) == "number" then
        boundary_check(o, key)
        return o.data[key]
    elseif List[key] then
        return List[key]
    end
end

---Constructor.
---@param ... any List elements.
---@return collections.List
function List.new(...)
    local data = {}
    local length = select("#", ...)
    for i = 1, length, 1 do
        local v = select(i, ...)
        data[i] = v
    end
    local list = {
        data = data,
        length = length,
    }
    setmetatable(list, List)
    return list
end

---Set the element at the specified index of the `List`.
---@param index integer
---@param value any
function List:__newindex(index, value)
    boundary_check(self, index)
    self.data[index] = value
end

---Gets the number of elements contained in the `List`.
---@return integer
function List:count()
    return self.length
end

---Adds an object to the end of the `List`.
---@param item any The object to be added to the end of the `List`.
function List:add(item)
    self.length = self.length + 1
    self.data[self.length] = item
end

---Determines whether an element is in the `List`.
---@param item any The object to locate in the `List`.
---@return boolean result `true` if `item` is found in the `List`; otherwise, `false`.
function List:contains(item)
    return vim.tbl_contains(self.data, item)
end

---Inserts an element into the `List` at the specified index.
---@param index integer The one-based index at which item should be inserted.
---@param item any The object to insert.
function List:insert(index, item)
    boundary_check(self, index, 1, self.length + 1)
    for i = self.length, index, -1 do
        self.data[i + 1] = self.data[i]
    end
    self.data[index] = item
    self.length = self.length + 1
end

---Removes the element at the specified index of the `List`.
---@param index integer The one-based index of the element to remove.
function List:remove_at(index)
    boundary_check(self, index)
    for i = index, self.length - 1, 1 do
        self.data[i] = self.data[i + 1]
    end
    self.data[self.length] = nil
    self.length = self.length - 1
end

---Performs the specified action on each element of the `List`.
---@param action fun(item:any) The action to perform on each element of the `List`.
function List:for_each(action)
    for i = 1, self.length, 1 do
        action(self.data[i])
    end
end

---Projects each element of a `List` into a new form.
---@param selector fun(item:any, index?:integer):any Transform function.
---@return collections.List
function List:select(selector)
    local result = List.new()
    for i = 1, self.length, 1 do
        result:add(selector(self.data[i], i))
    end
    return result
end

---Removes all elements from the `List`.
function List:clear()
    for i = 1, self.length, 1 do
        self.data[i] = nil
    end
    self.length = 0
end

---Returns the elements from the given `List`.
---@param i? integer
---@param j? integer
---@return ...
function List:unpack(i, j)
    return unpack(self.data, i or 1, j or self.length)
end

---Returns a string that represents the current object.
---@return string
function List:__tostring()
    local result = "List { "
    for i = 1, self.length - 1, 1 do
        result = result .. tostring(self.data[i]) .. ", "
    end
    if self.length > 0 then
        result = result .. tostring(self.data[self.length])
    end
    result = result .. " }"
    return result
end

return List
