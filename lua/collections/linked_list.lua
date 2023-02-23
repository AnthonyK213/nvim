---@class collections.LinkedListNode
---@field private data any
---@field private list collections.LinkedList
---@field private prev collections.LinkedListNode
---@field private next collections.LinkedListNode
local LinkedListNode = {}

---@private
LinkedListNode.__index = LinkedListNode

---Constructor.
---@param value any
---@return collections.LinkedListNode
function LinkedListNode.new(value)
    local node = {
        data = value,
    }
    setmetatable(node, LinkedListNode)
    return node
end

function LinkedListNode:get_value()
    return self.data
end

function LinkedListNode:get_list()
    return self.list
end

function LinkedListNode:get_prev()
    return self.prev
end

function LinkedListNode:get_next()
    return self.next
end

--------------------------------------------------------------------------------

---@class collections.LinkedList
---@field length integer
---@field first collections.LinkedListNode
---@field last collections.LinkedListNode
local LinkedList = {}

---@private
LinkedList.__index = LinkedList

---Constructor.
---@return collections.LinkedList
function LinkedList.new()
    local linked_list = {
        length = 0,
    }
    setmetatable(linked_list, LinkedList)
    return linked_list
end

function LinkedList:count()
    return self.length
end

---Adds the specified new node after the specified existing node in the `LinkedList`.
---@param node collections.LinkedListNode
---@param new_node collections.LinkedListNode
function LinkedList:add_after(node, new_node)
    if node:get_list() ~= self then
        return
    end
    local next = node:get_next()
    new_node.next = next
    new_node.prev = node
    node.next = new_node
end

function LinkedList:add_before()

end

function LinkedList:add_first()

end

function LinkedList:add_last()

end

return {
    LinkedListNode = LinkedListNode,
    LinkedList = LinkedList,
}
