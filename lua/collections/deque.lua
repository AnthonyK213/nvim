---@class collections.deque
---@field private data any[]
---@field private front integer
---@field private back integer
---@operator call:collections.deque
local Deque = {}

---@private
Deque.__index = Deque

setmetatable(Deque, { __call = function(o) return o.new() end })

---Creates an empty deque.
---@return collections.deque
function Deque.new()
    local deque = {
        data = {},
        front = 0,
        back = -1,
    }
    setmetatable(deque, Deque)
    return deque
end

---@private
---@param index? integer
function Deque:boundary_check(index)
    if self.front > self.back then
        error("Deque is empty")
    end
    if index and (index > self.back or index < self.front) then
        error("Index out of bounds")
    end
end

---Get the element at the given one-based index.
---@param index any
---@return any
function Deque:get(index)
    index = index + self.front - 1
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
    local value = self.data[self.back]
    self.data[self.back] = nil
    self.back = self.back - 1
    return value
end

---Removes the first element and returns it.
---@return any
function Deque:pop_front()
    self:boundary_check()
    local value = self.data[self.front]
    self.data[self.front] = nil
    self.front = self.front + 1
    return value
end

---Appends an element to the back of the deque.
---@param value any
function Deque:push_back(value)
    self.back = self.back + 1
    self.data[self.back] = value
end

---Prepends an element to the deque.
---@param value any
function Deque:push_front(value)
    self.front = self.front - 1
    self.data[self.front] = value
end

---Returns the number of the elements in the deque.
---@return integer
function Deque:count()
    return self.back - self.front + 1
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
function Deque:insert()

end

---Removes and returns the element at one-based `index` from the deque.
function Deque:remove()

end

return Deque
