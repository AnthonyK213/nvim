---@class collections.LinkedListNode : collections.Iterable
---@field private _data any
---@field private _list? collections.LinkedList
---@field private _prev? collections.LinkedListNode
---@field private _next? collections.LinkedListNode
---@operator call:collections.LinkedListNode
local LinkedListNode = {}

---@private
LinkedListNode.__index = LinkedListNode

setmetatable(LinkedListNode, { __call = function(o, v) return o.new(v) end })

---Create a node which contains `value`.
---The created node does not belong to any `LinkedList`.
---@param value any
---@return collections.LinkedListNode
function LinkedListNode.new(value)
  local node = {
    _data = value,
  }
  setmetatable(node, LinkedListNode)
  return node
end

---Get the node value it contains.
---@return any
function LinkedListNode:value()
  return self._data
end

---Get the `LinkedList` which owns the node.
---@return collections.LinkedList|nil
function LinkedListNode:list()
  return self._list
end

---Get previous node.
---@return collections.LinkedListNode|nil
function LinkedListNode:prev()
  return self._prev
end

---Get next node.
---@return collections.LinkedListNode|nil
function LinkedListNode:next()
  return self._next
end

---@private
---Returns a string that represents the current object.
---@return string
function LinkedListNode:__tostring()
  return string.format("Node(%s)", require("collections.util").to_string(self._data))
end

--------------------------------------------------------------------------------

---@class collections.LinkedList
---@field private _length integer
---@field private _first collections.LinkedListNode|nil
---@field private _last collections.LinkedListNode|nil
---@operator call:collections.LinkedList
local LinkedList = {}

---@private
LinkedList.__index = LinkedList

setmetatable(LinkedList, { __call = function(o) return o.new() end })

---Creat an empty linked list.
---@return collections.LinkedList
function LinkedList.new()
  local linked_list = {
    _length = 0,
  }
  setmetatable(linked_list, LinkedList)
  return linked_list
end

---Gets the number of nodes actually contained in the `LinkedList`.
---@return integer
function LinkedList:count()
  return self._length
end

---Gets the first node of the `LinkedList`.
---@return collections.LinkedListNode|nil
function LinkedList:first()
  return self._first
end

---Gets the first node of the `LinkedList`.
---@return collections.LinkedListNode|nil
function LinkedList:last()
  return self._last
end

---@private
---@return collections.LinkedListNode
function LinkedList:_add_check(item)
  local node

  if getmetatable(item) == LinkedListNode then
    if item:list() == self then
      node = item
    elseif item:list() == nil then
      node = item
      rawset(node, "_list", self)
    else
      error("The node is owned by another `LinkedList`")
    end
  else
    node = LinkedListNode(item)
    rawset(node, "_list", self)
  end

  return node
end

---@private
function LinkedList:_owns_node(node)
  return getmetatable(node) == LinkedListNode and node:list() == self
end

---@private
function LinkedList:_contains_node(node)
  if not self:_owns_node(node) then
    return false
  end
  local c = self._first
  while c do
    if rawequal(c, node) then
      return true
    end
    c = c:next()
  end
  return false
end

---Determines whether any loops in the `LinkedList`
---@return boolean
function LinkedList:has_loop()
  local fast, slow = self._first, self._first

  while fast and slow do
    slow = slow:next()
    fast = fast:next()
    if not fast then
      return false
    end
    fast = fast:next()
    if fast == slow then
      return true
    end
  end

  return false
end

---Adds the specified new node or value after the specified existing node in the `LinkedList`.
---@param node collections.LinkedListNode
---@param item any
function LinkedList:add_after(node, item)
  assert(self:_contains_node(node), "LinkedList does not contain the `node`")
  local new_node = self:_add_check(item)
  local next = node:next()
  rawset(new_node, "_next", next)
  rawset(new_node, "_prev", node)
  rawset(node, "_next", new_node)
  if next then
    rawset(next, "_prev", new_node)
  else
    self._last = new_node
  end
  self._length = self._length + 1
end

---Adds a new node or value before an existing node in the `LinkedList`.
---@param node collections.LinkedListNode
---@param item any
function LinkedList:add_before(node, item)
  assert(self:_contains_node(node), "LinkedList does not contain the `node`")
  local new_node = self:_add_check(item)
  local prev = node:prev()
  rawset(new_node, "_prev", prev)
  rawset(new_node, "_next", node)
  rawset(node, "_prev", new_node)
  if prev then
    rawset(prev, "_next", new_node)
  else
    self._first = new_node
  end
  self._length = self._length + 1
end

---Adds a new node or value at the start of the `LinkedList`.
---@param item any
function LinkedList:add_first(item)
  local node = self:_add_check(item)
  local first = self._first
  rawset(node, "_next", first)
  rawset(node, "_prev", nil)
  if first then
    rawset(first, "_prev", node)
  else
    self._last = node
  end
  self._first = node
  self._length = self._length + 1
end

---Adds a new node at the end of the `LinkedList`.
---@param item any
function LinkedList:add_last(item)
  local node = self:_add_check(item)
  local last = self._last
  rawset(node, "_prev", last)
  rawset(node, "_next", nil)
  if last then
    rawset(last, "_next", node)
  else
    self._first = node
  end
  self._last = node
  self._length = self._length + 1
end

---Removes all nodes from the `LinkedList`.
function LinkedList:clear()
  local node = self._first
  while node do
    rawset(node, "_prev", nil)
    node = node:next()
    if node then
      node:prev().next = nil
    end
  end
  self._first = nil
  self._last = nil
  self._length = 0
end

---Determines whether a value is in the `LinkedList`.
---@param value any
---@return boolean
function LinkedList:contains(value)
  for _, v in self:iter() do
    if v == value then
      return true
    end
  end
  return false
end

---Get the iterator of the `LinkedList`.
---@return fun():integer?, any iterator
function LinkedList:iter()
  local index = 0
  local node = self._first
  return function()
    index = index + 1
    if node then
      local value = node:value()
      node = node:next()
      return index, value
    end
  end
end

---Removes the specified node from the `LinkedList`.
---@param node collections.LinkedListNode
function LinkedList:remove(node)
  assert(self:_contains_node(node), "LinkedList does not contain the `node`")
  local prev = node:prev()
  local next = node:next()
  if prev then
    rawset(prev, "_next", next)
  else
    self._first = next
  end
  if next then
    rawset(next, "_prev", prev)
  else
    self._last = prev
  end
  rawset(node, "_prev", nil)
  rawset(node, "_next", nil)
  self._length = self._length - 1
end

---Removes the node at the start of the `LinkedList`.
function LinkedList:remove_first()
  local first = self._first
  if not first then
    return
  end
  local next = first:next()
  self._first = next
  if next then
    rawset(next, "_prev", nil)
  else
    self._last = nil
  end
  rawset(first, "_next", nil)
  self._length = self._length - 1
end

---Removes the node at the end of the `LinkedList`.
function LinkedList:remove_last()
  local last = self._last
  if not last then
    return
  end
  local prev = last:prev()
  if prev then
    rawset(prev, "_next", nil)
  else
    self._first = nil
  end
  self._last = prev
  rawset(last, "_prev", nil)
  self._length = self._length - 1
end

---Finds the first node that contains the specified value.
---@param value any
---@return collections.LinkedListNode|nil
function LinkedList:find(value)
  local node = self._first
  while node do
    if node:value() == value then
      return node
    end
    node = node:next()
  end
end

---Finds the last node that contains the specified value.
---@param value any
---@return collections.LinkedListNode|nil
function LinkedList:find_last(value)
  local node = self._last
  while node do
    if node:value() == value then
      return node
    end
    node = node:prev()
  end
end

---@private
---Returns a string that represents the current object.
---@return string
function LinkedList:__tostring()
  assert(not self:has_loop(), "Loop found")
  return require("collections.util").iter_inspect(self, LinkedList, "LinkedList", " <-> ")
end

return {
  LinkedList = LinkedList,
  LinkedListNode = LinkedListNode,
}
