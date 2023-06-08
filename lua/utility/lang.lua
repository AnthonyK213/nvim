local collections = require("collections")
local List = collections.List
local Stack = collections.Stack

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

---@param node TSNode Current node.
---@param predicate fun(node: TSNode):boolean The predicate.
---@param stack collections.Stack
---@param option table
local function _find_children(node, predicate, stack, option)
    if not node then return end
    for child in node:iter_children() do
        if predicate(child) then
            if option.limit
                and option.limit ~= 0
                and stack:count() >= option.limit then
                return
            end
            stack:push(Node.new(child))
        else
            if option.recursive then
                _find_children(child, predicate, stack, option)
            end
        end
    end
end

---Find the first child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@param recursive? boolean
---@return ts.Node
function Node:find_first_child(predicate, recursive)
    local p = _check_predicate(predicate)
    if p then
        local option = { limit = 1, recursive = recursive }
        local list = self:find_children(p, option)
        if list:any() then
            return list[1]
        end
    end
    return Node.new()
end

---Find all child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@param option? table
---@return collections.List
function Node:find_children(predicate, option)
    option = option or {}
    local p = _check_predicate(predicate)
    if self:is_nil() or not p then return List.new() end
    local stack = Stack()
    _find_children(self.node, p, stack, option)
    return List.from(stack)
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
    get_func_signature = function(node, bufnr)
        if not node then return end
        local root = Node.new(node)

        local type_ = root:find_first_child(function(item)
            return vim.list_contains({
                "primitive_type",
                "type_identifier",
                "qualified_identifier",
            }, item:type())
        end)
        local type__name
        if not type_:is_nil() then
            type__name = vim.treesitter.get_node_text(type_.node, bufnr)
        end

        local param_list = root
            :find_first_child("function_declarator", true)
            :find_first_child("parameter_list")

        if param_list:is_nil() then return end

        local params = param_list
            :find_children("parameter_declaration")
            :select(function(item)
                local ident = item:find_first_child("identifier", true)
                if ident:is_nil() then return end
                return vim.treesitter.get_node_text(ident.node, bufnr)
            end)
            :where(function(item) return item ~= nil end)

        return type__name, params
    end,
}

return M
