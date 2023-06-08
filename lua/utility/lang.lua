local List = require("collections").List;

local M = {}

---@class ts.Node
---@field node TSNode
local Node = {}

---@private
Node.__index = Node

---Constructor.
---@param node? TSNode
---@return ts.Node
function Node.new(node)
    local o = {
        node = node,
    }
    setmetatable(o, Node)
    return o
end

function Node:is_nil()
    return self.node == nil
end

---@private
---Make sure the predicate is a function, except for `string` which means the
---predicate is to find the exact `type`.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@return nil|fun(node: TSNode):boolean
local function _check_predicate(predicate)
    if type(predicate) == "string" then
        return function(item)
            return item:type() == predicate
        end
    end
    if type(predicate) ~= "function" then
        return nil
    end
    return predicate
end

---Find the first child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@return ts.Node
function Node:find_child(predicate)
    local p = _check_predicate(predicate)
    if self:is_nil() or not p then return Node.new() end
    for child in self.node:iter_children() do
        if p(child) then
            return Node.new(child)
        end
    end
    return Node.new()
end

---Find all child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@return collections.List
function Node:find_all_children(predicate)
    local p = _check_predicate(predicate)
    if self:is_nil() or not p then return List.new() end
    local result = List()
    for child in self.node:iter_children() do
        if p(child) then
            result:add(Node.new(child))
        end
    end
    return result
end

M.cpp = {
    ---Find node upward by a predicate at position (row, col).
    ---@param bufnr integer Buffer number.
    ---@param row integer Row number, 1-indexed.
    ---@param col integer Column number, 0-indexed.
    ---@param predicate string|fun(node: TSNode):boolean The predicate.
    ---@return TSNode?
    find_parent = function(bufnr, row, col, predicate)
        local p = _check_predicate(predicate)
        if not p then return end
        local node = vim.treesitter.get_node {
            bufnr = bufnr,
            pos = { row - 1, col },
        }
        while node do
            if p(node) then break end
            node = node:parent()
        end
        return node
    end,
    ---Get function definition information.
    ---@param node TSNode The `function_definition` node.
    ---@param bufnr integer Buffer number.
    ---@return string? return_type
    ---@return collections.List? param_list
    get_func_def = function(node, bufnr)
        if not node or node:type() ~= "function_definition" then return end
        local root = Node.new(node)

        local type_ = root:find_child(function(item)
            return item:type() == "primitive_type"
                or item:type() == "type_identifier"
        end)
        local type__name
        if not type_:is_nil() then
            type__name = vim.treesitter.get_node_text(type_.node, bufnr)
        end

        local params = root
            :find_child("function_declarator")
            :find_child("parameter_list")
            :find_all_children("parameter_declaration")
            :select(function(item)
                local ident = item:find_child("identifier")
                if ident:is_nil() then return end
                return vim.treesitter.get_node_text(ident.node, bufnr)
            end)
            :where(function(item) return item ~= nil end)

        return type__name, params
    end,
}

return M
