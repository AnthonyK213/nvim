---@class collections.Stack : collections.Iterable
---@field private _data table
---@field private _top integer
---@operator call:collections.Stack
local Stack = {}

---@private
Stack.__index = Stack

setmetatable(Stack, { __call = function(o) return o.new() end })

---Create an empty stack.
---@return collections.Stack
function Stack.new()
    local stack = {
        _top = 0,
        _data = {},
    }
    setmetatable(stack, Stack)
    return stack
end

---Removes all objects from the `Stack`.
function Stack:clear()
    for i = 1, self._top, 1 do
        self._data[i] = nil
    end
    self._top = 0
end

---Gets the number of elements contained in the `Stack`.
---@return integer
function Stack:count()
    return self._top
end

---Returns the object at the top of the Stack without removing it.
---@return any
function Stack:peek()
    if self._top == 0 then error("Stack is empty") end
    return self._data[self._top]
end

---Removes and returns the object at the top of the `Stack`.
---@return any
function Stack:pop()
    if self._top == 0 then error("Stack is empty") end
    local item = self._data[self._top]
    self._data[self._top] = nil
    self._top = self._top - 1
    return item
end

---Inserts an object at the top of the `Stack`.
---@param item any
function Stack:push(item)
    self._top = self._top + 1
    self._data[self._top] = item
end

---Determines whether an element is in the `Stack`.
---@param item any
---@return boolean
function Stack:contains(item)
    for i = 1, self._top, 1 do
        if self._data[i] == item then
            return true
        end
    end
    return false
end

---Get the iterator of the `Stack`.
---@return fun():integer?, any iterator
function Stack:iter()
    local index = 0
    return function()
        index = index + 1
        if index <= self._top then
            return index, self._data[index]
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
