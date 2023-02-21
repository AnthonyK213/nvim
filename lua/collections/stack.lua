---@class collections.Stack
---@field private data table
---@field private top integer
local Stack = {}

---@private
Stack.__index = Stack

---Constructor.
---@return collections.Stack
function Stack.new()
    local stack = {
        top = 0,
        data = {},
    }
    setmetatable(stack, Stack)
    return stack
end

---Removes all objects from the `Stack`.
function Stack:clear()
    for i = 1, self.top, 1 do
        self.data[i] = nil
    end
    self.top = 0
end

---Gets the number of elements contained in the `Stack`.
---@return integer
function Stack:count()
    return self.top
end

---Returns the object at the top of the Stack without removing it.
---@return any
function Stack:peek()
    if self.top == 0 then error("Stack is empty") end
    return self.data[self.top]
end

---Removes and returns the object at the top of the `Stack`.
---@return any
function Stack:pop()
    if self.top == 0 then error("Stack is empty") end
    local item = self.data[self.top]
    self.data[self.top] = nil
    self.top = self.top - 1
    return item
end

---Inserts an object at the top of the `Stack`.
---@param item any
function Stack:push(item)
    self.top = self.top + 1
    self.data[self.top] = item
end

---Determines whether an element is in the `Stack`.
---@param item any
---@return boolean
function Stack:contains(item)
    for i = 1, self.top, 1 do
        if self.data[i] == item then
            return true
        end
    end
    return false
end

---Get the iterator of the `List`.
---@return fun():integer?, any iterator
function Stack:iter()
    local index = 0
    return function()
        index = index + 1
        if index <= self.top then
            return index, self.data[index]
        end
    end
end

---@private
---Returns a string that represents the current object.
---@return string
function Stack:__tostring()
    return require("collections.util").iter_inspect(self, Stack, "Stack")
end

return Stack
