---@class collections.deque
---@field field any
local Deque = {}

---@private
Deque.__index = Deque

---Constructor.
---@param field any
---@return collections.deque
function Deque.new(field)
    local deque = {
        field = field,
    }
    setmetatable(deque, Deque)
    return deque
end

return Deque
