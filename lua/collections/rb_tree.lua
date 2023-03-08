---@enum Color
local Color = {
    Red = 0,
    Black = 1,
}

---@class collections.RbNode
---@field key any
---@field value any
---@field left collections.RbNode
---@field right collections.RbNode
---@field parent collections.RbNode
---@field color Color
local RbNode = {}

---@private
RbNode.__index = RbNode

---Constructor.
---@generic K
---@generic V
---@param key K
---@param value V
---@return collections.RbNode
function RbNode.new(key, value)
    local rb_node = {
        key = key,
        value = value,
    }
    setmetatable(rb_node, RbNode)
    rb_node.left = RbNode.Nil()
    rb_node.right = RbNode.Nil()
    rb_node.parent = RbNode.Nil()
    return rb_node
end

---@type collections.RbNode
local Nil = { color = Color.Black }
setmetatable(Nil, RbNode)

---Nil.
---@return collections.RbNode
function RbNode.Nil()
    return Nil
end

---Determine if node is `Nil`.
---@return boolean
function RbNode:is_Nil()
    return self == Nil
end

---@private
---To string.
---@return string
function RbNode:__tostring()
    if self == RbNode.Nil() then
        return "B[Nil]"
    end
    return string.format("%s[%s:%s]", self.color == 1 and "B" or "R", tostring(self.key), tostring(self.value))
end

---@class collections.RbTree<K, V>
---@field private root collections.RbNode
---@operator call:collections.RbTree
local RbTree = {}

---@private
RbTree.__index = RbTree

setmetatable(RbTree, { __call = function(o) return o.new() end })

---Create an empty red-black tree.
---@return collections.RbTree
function RbTree.new()
    local rb_tree = {
        root = RbNode.Nil(),
    }
    setmetatable(rb_tree, RbTree)
    return rb_tree
end

---@private
---Left rotation.
---@param node collections.RbNode
function RbTree:_rotate_left(node)
    local right = node.right
    node.right = right.left
    if not right.left:is_Nil() then
        right.left.parent = node
    end
    local parent = node.parent
    right.parent = parent
    if parent:is_Nil() then
        self.root = right
    elseif node == parent.left then
        parent.left = right
    else
        parent.right = right
    end
    right.left = node
    node.parent = right
end

---@private
---Right rotation.
---@param node collections.RbNode
function RbTree:_rotate_right(node)
    local left = node.left
    node.left = left.right
    if not left.right:is_Nil() then
        left.right.parent = node
    end
    local parent = node.parent
    left.parent = parent
    if parent:is_Nil() then
        self.root = left
    elseif node == parent.right then
        parent.right = left
    else
        parent.left = left
    end
    left.right = node
    node.parent = left
end

---@private
---Transplant.
---@param u collections.RbNode
---@param v collections.RbNode
function RbTree:_transplant(u, v)
    if u.parent:is_Nil() then
        self.root = v
    elseif u == u.parent.left then
        u.parent.left = v
    else
        u.parent.right = v
    end
    v.parent = u.parent
end

---@private
---Minimum.
---@param node collections.RbNode
function RbTree:_minimum(node)
    while not node.left:is_Nil() do
        node = node.left
    end
    return node
end

---@private
---Get node by `key`.
---@param key any
---@return (collections.RbNode)?
function RbTree:_get_node(key)
    local node = self.root
    while not node:is_Nil() do
        if key < node.key then
            node = node.left
        elseif key == node.key then
            return node
        else
            node = node.right
        end
    end
end

---@private
---Insert a node.
---@param node collections.RbNode
function RbTree:_insert_node(node)
    local x, y = self.root, RbNode.Nil()
    while not x:is_Nil() do
        y = x
        if node.key < x.key then
            x = x.left
        else
            x = x.right
        end
    end
    node.parent = y
    if y:is_Nil() then
        self.root = node
    elseif node.key < y.key then
        y.left = node
    else
        y.right = node
    end
    node.left = RbNode.Nil()
    node.right = RbNode.Nil()
    node.color = Color.Red

    while node.parent.color == Color.Red do
        if node.parent == node.parent.parent.left then
            y = node.parent.parent.right
            if y.color == Color.Red then
                node.parent.color = Color.Black
                y.color = Color.Black
                node.parent.parent.color = Color.Red
                node = node.parent.parent
            elseif node == node.parent.right then
                node = node.parent
                self:_rotate_left(node)
            else
                node.parent.color = Color.Black
                node.parent.parent.color = Color.Red
                self:_rotate_right(node.parent.parent)
            end
        else
            y = node.parent.parent.left
            if y.color == Color.Red then
                node.parent.color = Color.Black
                y.color = Color.Black
                node.parent.parent.color = Color.Red
                node = node.parent.parent
            elseif node == node.parent.left then
                node = node.parent
                self:_rotate_right(node)
            else
                node.parent.color = Color.Black
                node.parent.parent.color = Color.Red
                self:_rotate_left(node.parent.parent)
            end
        end
    end

    self.root.color = Color.Black
end

---@private
---Delete a node.
---@param node collections.RbNode
function RbTree:_delete_node(node)
    local x, y = nil, node
    local y_original_color = y.color
    if node.left:is_Nil() then
        x = node.right
        self:_transplant(node, node.right)
    elseif node.right:is_Nil() then
        x = node.left
        self:_transplant(node, node.left)
    else
        y = self:_minimum(node.right)
        y_original_color = y.color
        x = y.right
        if y.parent == node then
            x.parent = y
        else
            self:_transplant(y, y.right)
            y.right = node.right
            y.right.parent = y
        end
        self:_transplant(node, y)
        y.left = node.left
        y.left.parent = y
        y.color = node.color
    end
    if y_original_color == Color.Black then
        while x ~= self.root and x.color == Color.Black do
            if x == x.parent.left then
                local w = x.parent.right
                if w.color == Color.Red then
                    w.color = Color.Black
                    x.parent.color = Color.Red
                    self:_rotate_left(x.parent)
                    w = x.parent.right
                elseif w.left.color == Color.Black and w.right.color == Color.Black then
                    w.color = Color.Red
                    x = x.parent
                elseif w.right.color == Color.Black then
                    w.left.color = Color.Black
                    w.color = Color.Red
                    self:_rotate_right(w)
                    w = x.parent.right
                else
                    w.color = x.parent.color
                    x.parent.color = Color.Black
                    w.right.color = Color.Black
                    self:_rotate_left(x.parent)
                    x = self.root
                end
            else
                local w = x.parent.left
                if w.color == Color.Red then
                    w.color = Color.Black
                    x.parent.color = Color.Red
                    self:_rotate_right(x.parent)
                    w = x.parent.left
                elseif w.right.color == Color.Black and w.left.color == Color.Black then
                    w.color = Color.Red
                    x = x.parent
                elseif w.left.color == Color.Black then
                    w.right.color = Color.Black
                    w.color = Color.Red
                    self:_rotate_left(w)
                    w = x.parent.left
                else
                    w.color = x.parent.color
                    x.parent.color = Color.Black
                    w.left.color = Color.Black
                    self:_rotate_right(x.parent)
                    x = self.root
                end
            end
        end
        x.color = Color.Black
    end
end

---Get `value` by `key`.
---@param key any
---@return any
function RbTree:get(key)
    local node = self:_get_node(key)
    if node then
        return node.value
    end
end

---Add a pair of key & value.
---@param key any
---@param value any
---@return boolean
function RbTree:add(key, value)
    if not self:_get_node(key) then
        self:_insert_node(RbNode.new(key, value))
        return true
    end
    return false
end

---Remove a node by `key`.
---@param key any
---@return boolean
---@return any
function RbTree:remove_at(key)
    local node = self:_get_node(key)
    if node then
        self:_delete_node(node)
        return true, node.value
    end
    return false
end

---@private
---To string.
---@return string
function RbTree:__tostring()
    local Deque = require("collections.deque")
    local deque = Deque(self.root)
    local result = ""
    while deque:count() > 0 do
        local n = deque:pop_front()
        if n.left then
            deque:push_back(n.left)
        end
        if n.right then
            deque:push_back(n.right)
        end
        result = result .. tostring(n) .. ", "
    end
    return result
end

return RbTree
