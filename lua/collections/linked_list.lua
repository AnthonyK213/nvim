---@class collections.LinkedList
---@field field any
local LinkedList = {}

---@private
LinkedList.__index = LinkedList

---Constructor.
---@param field any
---@return collections.LinkedList
function LinkedList.new(field)
    local o = {
        field = field,
    }
    setmetatable(o, LinkedList)
    return o
end

return LinkedList
