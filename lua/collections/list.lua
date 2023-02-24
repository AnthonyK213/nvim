local Iterator = require("collections.iter")

---@class collections.List : collections.Iterable Represents a list of objects that can be accessed by index. Provides methods to search, sort, and manipulate lists.
---@field private _data any[]
---@field private _length integer
---@operator call:collections.List
---@operator add(any[]|collections.Iterable):collections.List
local List = {}

---@private
List.__index = function(o, key)
    if type(key) == "number" then
        o:boundary_check(key)
        return o._data[key]
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
        _data = { ... },
        _length = select("#", ...),
    }
    setmetatable(list, List)
    return list
end

---Create `List` from an iterable collection.
---@param iterable any[]|collections.Iterable An iterable collection.
---@return collections.List
function List.from(iterable)
    local data = {}
    local index = 0
    for _, v in Iterator.get(iterable):consume() do
        index = index + 1
        data[index] = v
    end
    local list = {
        _data = data,
        _length = index,
    }
    setmetatable(list, List)
    return list
end

---@private
---Boundary check.
---@param index integer
---@param count? integer
---@param min? integer
---@param max? integer
---@param backward? boolean
function List:boundary_check(index, count, min, max, backward)
    if math.floor(index) ~= index then
        error("Index must be an integer")
    end
    if count then
        if math.floor(count) ~= count then
            error("Count must be an integer")
        elseif count < 0
            or (backward and index < count or index + count > self._length + 1) then
            error("Count out of bounds")
        end
    end
    if index < (min or 1) or index > (max or self._length) then
        error("Index out of bounds")
    end
end

---Gets the number of elements contained in the `List`.
---@return integer
function List:count()
    return self._length
end

---Adds an object to the end of the `List`.
---@param item any The object to be added to the end of the `List`.
function List:add(item)
    self._length = self._length + 1
    self._data[self._length] = item
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
    self:boundary_check(index, nil, 1, self._length + 1)
    for i = self._length, index, -1 do
        self._data[i + 1] = self._data[i]
    end
    self._data[index] = item
    self._length = self._length + 1
end

---Removes and returns the element at the specified index of the `List`.
---@param index integer The one-based index of the element to remove.
---@return any item The removed item.
function List:remove_at(index)
    self:boundary_check(index)
    local item = self._data[index]
    for i = index, self._length - 1, 1 do
        self._data[i] = self._data[i + 1]
    end
    self._data[self._length] = nil
    self._length = self._length - 1
    return item
end

---Performs the specified action on each element of the `List`.
---@param action fun(item: any, index?: integer) The action to perform on each element of the `List`.
function List:for_each(action)
    for i = 1, self._length, 1 do
        action(self._data[i], i)
    end
end

---Projects each element of a `List` into a new form.
---@param selector fun(item: any, index?: integer):any Transform function.
---@return collections.List
function List:select(selector)
    local result = List.new()
    for i = 1, self._length, 1 do
        result:add(selector(self._data[i], i))
    end
    return result
end

---Removes all elements from the `List`.
function List:clear()
    for i = 1, self._length, 1 do
        self._data[i] = nil
    end
    self._length = 0
end

---Returns the elements from the given `List`.
---@param i? integer
---@param j? integer
---@return ...
function List:unpack(i, j)
    return unpack(self._data, i or 1, j or self._length)
end

---Sort the elements in the entire `List` using the specified `comparison`.
---@generic T
---@param comparer? fun(a: T, b: T):boolean The function to use when comparing elements.
function List:sort(comparer)
    table.sort(self._data, comparer)
end

---Get the iterator of the `List`.
---@return fun():integer?, any iterator
function List:iter()
    local index = 0
    return function()
        index = index + 1
        if index <= self._length then
            return index, self._data[index]
        end
    end
end

---Creates a shallow copy of a range of elements in the source `List`.
---@param index integer The one-based `List` index at which the range starts.
---@param count integer The number of elements in the range.
---@return collections.List slice A shallow copy of a range of elements in the source `List`.
function List:get_range(index, count)
    local list = List()
    for i = 1, count, 1 do
        list._data[i] = self[index + i - 1]
    end
    list._length = count
    return list
end

---Add the elements of the specified collection to the end of the `List`.
---@param iterable any[]|collections.Iterable The collection whose elements should be added to the end of the `List`.
function List:add_range(iterable)
    local i = 0
    for _, v in Iterator.get(iterable):consume() do
        i = i + 1
        self._data[self._length + i] = v
    end

    self._length = self._length + i
end

---Inserts the elements of a collection into the `List` at the specified index.
---@param index integer The one-based index at which the new elements should be inserted.
---@param iterable any[]|collections.Iterable The collection whose elements should be inserted into the `List`.
function List:insert_range(index, iterable)
    self:boundary_check(index, nil, 1, self._length + 1)

    local buf = {}
    for i = index, self._length, 1 do
        buf[i] = self._data[i]
    end

    local j = 0
    for _, v in Iterator.get(iterable):consume() do
        self._data[index + j] = v
        j = j + 1
    end

    self._length = self._length + j

    for i = index + j, self._length, 1 do
        self._data[i] = buf[i - j]
    end
end

---Removes a range of elements from the `List`.
---@param index integer The one-based starting index of the range of elements to remove.
---@param count integer The number of elements to remove.
function List:remove_range(index, count)
    self:boundary_check(index, count)
    if count == 0 then return end

    local c = self._length - count

    for i = index, self._length, 1 do
        if i <= c then
            self._data[i] = self[i + count]
        else
            self._data[i] = nil
        end
    end

    self._length = c
end

---Reverses the order of the elements in the `List` or a portion of it.
---@param index? integer The one-based starting index of the range to reverse.
---@param count? integer The number of elements in the range to reverse.
function List:reverse(index, count)
    if index and not count then
        error("Count should be specified")
    end

    index = index or 1
    count = count or self._length

    self:boundary_check(index, count)
    if count < 2 then return end

    local sum = index * 2 + count - 1

    for i = index, index + bit.rshift(count, 1) - 1, 1 do
        self[i], self[sum - i] = self[sum - i], self[i]
    end
end

---Determines whether the `List` contains elements that match the conditions defined by the specified predicate.
---@param match fun(v: any):boolean The function that defines the conditions of the elements to search for.
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
---@param match fun(v: any):boolean The function that defines the conditions of the element to search for.
---@param startIndex? integer The one-based starting index of the search.
---@param count? integer The number of elements in the section to search.
---@return integer index The one-based index of the first occurrence of an element that matches the conditions defined by match, if found; otherwise, `0`.
function List:find_index(match, startIndex, count)
    vim.validate { match = { match, "function" } }
    if startIndex then
        self:boundary_check(startIndex, count)
    else
        startIndex = 1
    end
    local endIndex = count and startIndex + count - 1 or self._length

    for i = startIndex, endIndex, 1 do
        if match(self._data[i]) then
            return i
        end
    end
    return 0
end

---Searches for an element that matches the conditions defined by the specified predicate, and returns the one-based index of the last occurrence within the range of elements in the `List` that contains the specified number of elements and ends at the specified index.
---@param match fun(v: any):boolean The function that defines the conditions of the element to search for.
---@param startIndex? integer The one-based starting index of the backward search.
---@param count? integer The number of elements in the section to search.
---@return integer index The one-based index of the last occurrence of an element that matches the conditions defined by match, if found; otherwise, `0`.
function List:find_last_index(match, startIndex, count)
    vim.validate { match = { match, "function" } }
    if startIndex then
        self:boundary_check(startIndex, count, nil, nil, true)
    else
        startIndex = self._length
    end
    local endIndex = count and startIndex - count + 1 or 1

    for i = startIndex, endIndex, -1 do
        if match(self._data[i]) then
            return i
        end
    end
    return 0
end

---Retrieves all the elements that match the conditions defined by the specified predicate.
---@param match fun(v: any):boolean The function that defines the conditions of the elements to search for.
---@return collections.List result A `List` containing all the elements that match the conditions defined by the specified predicate, if found; otherwise, an empty `List`.
function List:find_all(match)
    vim.validate { match = { match, "function" } }
    local result = List()
    for i = 1, self._length, 1 do
        if match(self._data[i]) then
            result:add(self._data[i])
        end
    end
    return result
end

---Determines whether a `List` contains any elements.
---@return boolean
function List:any()
    return self._length > 0
end

---Removes all the elements that match the conditions defined by the specified predicate.
---@param match fun(v: any):boolean The function that defines the conditions of the elements to remove.
---@return integer count The number of elements removed from the `List`.
function List:remove_all(match)
    vim.validate { match = { match, "function" } }
    local count = 0
    for i = self._length, 1, -1 do
        if match(self._data[i]) then
            self:remove_at(i)
            count = count + 1
        end
    end
    return count
end

---Searches a range of elements in the sorted `List` for a element using the
---specified comparer and returns the one-based index of the element.
---@generic T
---@param item T The object to locate.
---@param index? integer The one-based starting index of the range to search.
---@param count? integer The length of the range to search.
---@param comparer? fun(x: T, y: T):integer Comparer to compare elements.
---  - `x` is less than `y`: Less than zero;
---  - `x` equals `y`: 0;
---  - `x` is greater than `y`: Greater than zero.
---@return integer position The one-based index of item in the sorted `List`, if item is found; otherwise, a negative number that is the bitwise complement of the index of the next element that is larger than item or, if there is no larger element, the bitwise complement of Count.
function List:binary_search(item, index, count, comparer)
    index = index or 1
    count = count or self._length
    comparer = comparer or function(x, y)
            if x < y then
                return -1
            elseif x == y then
                return 0
            else
                return 1
            end
        end
    self:boundary_check(index, count)
    local u, v = index, index + count - 1
    local c_u = comparer(item, self[u])
    local c_v = comparer(item, self[v])
    if c_u == 0 then
        return u
    elseif c_v == 0 then
        return v
    elseif c_u < 0 then
        return bit.bnot(u)
    elseif c_v > 0 then
        return bit.bnot(v + 1)
    end
    while u < v - 1 do
        local mid = bit.rshift(u + v, 1)
        local c = comparer(item, self[mid])
        if c < 0 then
            v = mid
        elseif c == 0 then
            return mid
        else
            u = mid
        end
    end
    c_u = comparer(item, self[u])
    c_v = comparer(item, self[v])
    if c_u == 0 then
        return u
    elseif c_v == 0 then
        return v
    else
        return bit.bnot(v)
    end
end

---Equality test (raw).
---@param list collections.List
---@return boolean
function List:eq(list)
    return rawequal(self, list)
end

---@private
---Add up two lists.
---@param collection any The collection whose elements should be added to the end of the `List`.
---@return collections.List
function List:__add(collection)
    local result = self:get_range(1, self._length)
    result:add_range(collection)
    return result
end

---@private
---Equality test.
---@param list collections.List
---@return boolean
function List:__eq(list)
    if getmetatable(list) ~= List or self:count() ~= list:count() then
        return false
    end
    for i, v in self:iter() do
        if v ~= list[i] then
            return false
        end
    end
    return true
end

---@private
---Set the element at the specified index of the `List`.
---@param index integer
---@param value any
function List:__newindex(index, value)
    self:boundary_check(index)
    self._data[index] = value
end

---@private
---Returns a string that represents the current object.
---@return string
function List:__tostring()
    return require("collections.util").iter_inspect(self, List, "List")
end

return List
