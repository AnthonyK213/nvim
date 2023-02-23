local Iterator = require("collections.iter")

---@class collections.Deque Represents a double-ended queue.
---@field private data any[]
---@field private front integer
---@field private back integer
---@operator call:collections.Deque
local Deque = {}

---@private
Deque.__index = Deque

setmetatable(Deque, { __call = function(o, ...) return o.new(...) end })

---Constructor.
---@return collections.Deque
function Deque.new(...)
    local count = select("#", ...)
    local front = -bit.rshift(count, 1)
    local deque = {
        data = {},
        front = front,
        back = front + count - 1,
    }
    for i = 1, count, 1 do
        deque.data[i + front - 1] = select(i, ...)
    end
    setmetatable(deque, Deque)
    return deque
end

---Create `Deque` from an iterable collection.
---@param iterable any An iterable collection.
---@return collections.Deque
function Deque.from(iterable)
    local data = {}
    local index = 0
    for _, v in Iterator.get(iterable):consume() do
        index = index + 1
        data[index] = v
    end
    local deque = {
        data = data,
        front = 1,
        back = index,
    }
    setmetatable(deque, Deque)
    return deque
end

---@private
---@param index? integer
---@param min? integer
---@param max? integer
function Deque:boundary_check(index, min, max)
    if self.front > self.back then
        error("Deque is empty")
    end
    if index and (index > (max or self.back) or index < (min or self.front)) then
        error("Index out of bounds")
    end
end

---@private
---Convert one-based `index` into the index of `data`.
---@param index integer The one-based index.
---@return integer
function Deque:data_index(index)
    return index + self.front - 1
end

---Get the element at the given one-based index.
---@param index integer The one-based index.
---@return any
function Deque:get(index)
    index = self:data_index(index)
    self:boundary_check(index)
    return self.data[index]
end

---Get the front element.
---@return any
function Deque:get_back()
    self:boundary_check()
    return self.data[self.back]
end

---Get the back element.
---@return any
function Deque:get_front()
    self:boundary_check()
    return self.data[self.front]
end

---Removes the last element from the deque and returns it.
---@return any
function Deque:pop_back()
    self:boundary_check()
    local item = self.data[self.back]
    self.data[self.back] = nil
    self.back = self.back - 1
    return item
end

---Removes the first element and returns it.
---@return any
function Deque:pop_front()
    self:boundary_check()
    local item = self.data[self.front]
    self.data[self.front] = nil
    self.front = self.front + 1
    return item
end

---Appends an element to the back of the `Deque`.
---@param item any
function Deque:push_back(item)
    self.back = self.back + 1
    self.data[self.back] = item
end

---Prepends an element to the `Deque`.
---@param item any
function Deque:push_front(item)
    self.front = self.front - 1
    self.data[self.front] = item
end

---Returns the number of the elements in the `Deque`.
---@return integer
function Deque:count()
    return self.back - self.front + 1
end

---Determines whether an element is in the `Deque`.
---@param item any The object to locate in the `Deque`.
---@return boolean result `true` if `item` is found in the `Deque`; otherwise, `false`.
function Deque:contains(item)
    for i = self.front, self.back, 1 do
        if self.data[i] == item then
            return true
        end
    end
    return false
end

---Clears the deque, removing all values.
function Deque:clear()
    for i = self.front, self.back, 1 do
        self.data[i] = nil
    end
    self.front = 0
    self.back = -1
end

---Inserts an element at one-based `index` within the deque, shifting all elements
---with indices greater than or equal to `index` towards the back.
---@param index integer The one-based index at which item should be inserted.
---@param item any The object to insert.
function Deque:insert(index, item)
    index = self:data_index(index)
    self:boundary_check(index, nil, self.back + 1)
    for i = self.back, index, -1 do
        self.data[i + 1] = self.data[i]
    end
    self.data[index] = item
    self.back = self.back + 1
end

---Removes and returns the element at one-based `index` from the `Deque`.
---@param index integer The one-based index of the element to remove.
---@return any item The removed item.
function Deque:remove_at(index)
    index = self:data_index(index)
    self:boundary_check(index)
    local item = self.data[index]
    for i = index, self.back - 1, 1 do
        self.data[i] = self.data[i + 1]
    end
    self.data[self.back] = nil
    self.back = self.back - 1
    return item
end

---Get the iterator of the `Deque`.
---@return fun():integer?, any iterator
function Deque:iter()
    local index = self.front - 1
    return function()
        index = index + 1
        if index <= self.back then
            return index + 1 - self.front, self.data[index]
        end
    end
end

---Rotates the deque `mid` places to the left.
---@param mid integer
function Deque:rotate_left(mid)
    mid = mid % self:count()
    for _ = 1, mid, 1 do
        self:push_back(self:pop_front())
    end
end

---Rotates the deque `mid` places to the right.
---@param mid integer
function Deque:rotate_right(mid)
    mid = mid % self:count()
    for _ = 1, mid, 1 do
        self:push_front(self:pop_back())
    end
end

---@private
---Returns a string that represents the current object.
---@return string
function Deque:__tostring()
    return require("collections.util").iter_inspect(self, Deque, "Deque")
end

return Deque
