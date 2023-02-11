---Boundary check.
---@param list collections.List
---@param index integer
---@param count? integer
---@param min? integer
---@param max? integer
---@param backward? boolean
local function boundary_check(list, index, count, min, max, backward)
    if math.floor(index) ~= index then
        error("Index must be an integer")
    end
    if count then
        if math.floor(count) ~= count then
            error("Count must be an integer")
        elseif count < 0
            or (backward and index < count or index + count > list:count() + 1) then
            error("Count out of bounds")
        end
    end
    if index < (min or 1) or index > (max or list:count()) then
        error("Index out of bounds")
    end
end

---Get iterator of a collection.
---@param collection any
---@return fun(collection:any):fun():integer,any
local function get_iter(collection)
    if vim.tbl_islist(collection) then
        return ipairs
    elseif type(collection.iter) == "function" then
        return collection.iter
    else
        error("Failed to get the iterator")
    end
end

---@class collections.List Represents a list of objects that can be accessed by index. Provides methods to search, sort, and manipulate lists.
---@field private data any[]
---@field private length integer
---@operator call:collections.List
---@operator add(any[]|collections.List):collections.List
local List = {}

---@private
List.__index = function(o, key)
    if type(key) == "number" then
        boundary_check(o, key)
        return o.data[key]
    elseif List[key] then
        return List[key]
    end
end

setmetatable(List, { __call = function(o, ...) return o.new(...) end })

---Constructor.
---@param ... any List elements.
---@return collections.List
function List.new(...)
    local list = {
        data = { ... },
        length = select("#", ...),
    }
    setmetatable(list, List)
    return list
end

---Create `List` from a list-like table or another `List`.
---@param list any[]|collections.List
---@param count? integer
---@return collections.List
function List.from(list, count)
    vim.validate { list = { list, "table" } }

    local function new(source, length)
        local data = {}
        for i = 1, length, 1 do
            data[i] = source[i]
        end
        local o = {
            data = data,
            length = length,
        }
        setmetatable(o, List)
        return o
    end

    if vim.tbl_islist(list) then
        if not count then
            vim.notify("It's better to specify the count of list", vim.log.levels.WARN)
        end
        return new(list, count or #list)
    elseif getmetatable(list) == List then
        return new(list.data, list.length)
    end

    error("Input list is invalid")
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
    for _, v in self:iter() do
        if item == v then
            return true
        end
    end
    return false
end

---Inserts an element into the `List` at the specified index.
---@param index integer The one-based index at which item should be inserted.
---@param item any The object to insert.
function List:insert(index, item)
    boundary_check(self, index, nil, 1, self.length + 1)
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
    local stack = {}

    local function _str(obj)
        if getmetatable(obj) == List then
            local index = require("utility.lib").tbl_find_first(stack, obj)
            if index > 0 then
                return "List<" .. index - 1 .. ">"
            else
                table.insert(stack, obj)
                local result = "List<" .. #stack - 1 .. ">{ "
                for i = 1, obj.length, 1 do
                    result = result .. _str(obj.data[i])
                    if i ~= obj.length then
                        result = result .. ", "
                    end
                end
                return result .. " }"
            end
        end
        return tostring(obj)
    end

    return _str(self)
end

---Sort the elements in the entire `List` using the specified `comparison`.
---@param comparison? fun(a:any, b:any):boolean The function to use when comparing elements.
function List:sort(comparison)
    table.sort(self.data, comparison)
end

---Get the iterator of the `List`.
---@return fun():integer?,any iterator
function List:iter()
    local index = 0
    return function()
        index = index + 1
        if index <= self.length then
            return index, self.data[index]
        end
    end
end

---Creates a shallow copy of a range of elements in the source `List`.
---@param index integer The one-based `List` index at which the range starts.
---@param count integer The number of elements in the range.
---@return collections.List slice A shallow copy of a range of elements in the source `List`.
function List:get_range(index, count)
    local data = {}
    for i = 1, count, 1 do
        data[i] = self[index + i - 1]
    end
    return List.from(data, count)
end

---Add the elements of the specified collection to the end of the `List`.
---@param collection any The collection whose elements should be added to the end of the `List`.
function List:add_range(collection)
    vim.validate { collection = { collection, "table" } }

    local f = get_iter(collection)

    local i = 0
    for _, v in f(collection) do
        i = i + 1
        self.data[self.length + i] = v
    end

    self.length = self.length + i
end

---Inserts the elements of a collection into the `List` at the specified index.
---@param index integer The one-based index at which the new elements should be inserted.
---@param collection any The collection whose elements should be inserted into the `List`.
function List:insert_range(index, collection)
    boundary_check(self, index, nil, 1, self.length + 1)
    vim.validate { collection = { collection, "table" } }

    local f = get_iter(collection)

    local buf = {}
    for i = index, self.length, 1 do
        buf[i] = self.data[i]
    end

    local j = 0
    for _, v in f(collection) do
        self.data[index + j] = v
        j = j + 1
    end

    self.length = self.length + j

    for i = index + j, self.length, 1 do
        self.data[i] = buf[i - j]
    end
end

---Removes a range of elements from the `List`.
---@param index integer The one-based starting index of the range of elements to remove.
---@param count integer The number of elements to remove.
function List:remove_range(index, count)
    boundary_check(self, index, count)
    if count == 0 then return end

    local c = self.length - count

    for i = index, self.length, 1 do
        if i <= c then
            self.data[i] = self[i + count]
        else
            self.data[i] = nil
        end
    end

    self.length = c
end

---Reverses the order of the elements in the `List` or a portion of it.
---@param index? integer The one-based starting index of the range to reverse.
---@param count? integer The number of elements in the range to reverse.
function List:reverse(index, count)
    if index and not count then
        error("Count should be specified")
    end

    index = index or 1
    count = count or self.length

    boundary_check(self, index, count)
    if count < 2 then return end

    local sum = index * 2 + count - 1

    for i = index, index + bit.rshift(count, 1) - 1, 1 do
        self[i], self[sum - i] = self[sum - i], self[i]
    end
end

---Determines whether the `List` contains elements that match the conditions defined by the specified predicate.
---@param match fun(v:any):boolean The function that defines the conditions of the elements to search for.
---@return boolean
function List:exists(match)
    vim.validate { match = { match, "function" } }
    for _, v in self:iter() do
        if match(v) then
            return true
        end
    end
    return false
end

---Searches for an element that matches the conditions defined by the specified predicate, and returns the one-based index of the first occurrence within the range of elements in the `List` that starts at the specified index and contains the specified number of elements.
---@param match fun(v:any):boolean The function that defines the conditions of the element to search for.
---@param startIndex? integer The one-based starting index of the search.
---@param count? integer The number of elements in the section to search.
---@return integer index The one-based index of the first occurrence of an element that matches the conditions defined by match, if found; otherwise, `0`.
function List:find_index(match, startIndex, count)
    vim.validate { match = { match, "function" } }
    if startIndex then
        boundary_check(self, startIndex, count)
    else
        startIndex = 1
    end
    local endIndex = count and startIndex + count - 1 or self.length

    for i = startIndex, endIndex, 1 do
        if match(self.data[i]) then
            return i
        end
    end
    return 0
end

---Searches for an element that matches the conditions defined by the specified predicate, and returns the one-based index of the last occurrence within the range of elements in the `List` that contains the specified number of elements and ends at the specified index.
---@param match fun(v:any):boolean The function that defines the conditions of the element to search for.
---@param startIndex? integer The one-based starting index of the backward search.
---@param count? integer The number of elements in the section to search.
---@return integer index The one-based index of the last occurrence of an element that matches the conditions defined by match, if found; otherwise, `0`.
function List:find_last_index(match, startIndex, count)
    vim.validate { match = { match, "function" } }
    if startIndex then
        boundary_check(self, startIndex, count, nil, nil, true)
    else
        startIndex = self.length
    end
    local endIndex = count and startIndex - count + 1 or 1

    for i = startIndex, endIndex, -1 do
        if match(self.data[i]) then
            return i
        end
    end
    return 0
end

---Retrieves all the elements that match the conditions defined by the specified predicate.
---@param match fun(v:any):boolean The function that defines the conditions of the elements to search for.
---@return collections.List result A `List` containing all the elements that match the conditions defined by the specified predicate, if found; otherwise, an empty `List`.
function List:find_all(match)
    vim.validate { match = { match, "function" } }
    local result = List()
    for i = 1, self.length, 1 do
        if match(self.data[i]) then
            result:add(self.data[i])
        end
    end
    return result
end

---Determines whether a `List` contains any elements.
---@return boolean
function List:any()
    return self.length > 0
end

---Removes all the elements that match the conditions defined by the specified predicate.
---@param match fun(v:any):boolean The function that defines the conditions of the elements to remove.
---@return integer count The number of elements removed from the `List`.
function List:remove_all(match)
    vim.validate { match = { match, "function" } }
    local count = 0
    for i = self.length, 1, -1 do
        if match(self.data[i]) then
            self:remove_at(i)
            count = count + 1
        end
    end
    return count
end

---Add up two lists.
---@param collection any The collection whose elements should be added to the end of the `List`.
---@return collections.List
function List:__add(collection)
    local result = self:get_range(1, self.length)
    result:add_range(collection)
    return result
end

return List
