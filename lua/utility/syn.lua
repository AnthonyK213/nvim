local collections = require("collections")
local List = collections.List
local Deque = collections.Deque

local M = {}

---Syntax structure.
---@class syn.Syntax
---@field private vs table Vim syntax.
---@field private ts table Treesitter.
---@field private st table Semantic tokens.
local Syntax = {}

---@private
Syntax.__index = Syntax

---Constructor.
---@param bufnr? integer Buffer number.
---@param row? integer 1-based row number.
---@param col? integer 0-based column number.
---@return syn.Syntax
function Syntax.new(bufnr, row, col)
    row = row and row - 1
    local data = vim.inspect_pos(bufnr, row, col)
    local syntax = {
        vs = (not vim.tbl_isempty(data.syntax)) and data.syntax or nil,
        ts = (not vim.tbl_isempty(data.treesitter)) and data.treesitter or nil,
        st = (not vim.tbl_isempty(data.semantic_tokens)) and data.semantic_tokens or nil,
    }
    setmetatable(syntax, Syntax)
    return syntax
end

---Match syntax name using vim regex.
---@param pattern string|{ vs: string?, ts: string?, st: string? }
---@return boolean matched True if matched.
function Syntax:match(pattern)
    vim.validate { pattern = { pattern, { "string", "table" } } }
    local map = { vs = "hl_group", ts = "capture", st = "type" }

    local match = function(item, pat)
        if pat and self[item] then
            for _, v in ipairs(self[item]) do
                if vim.regex(pat):match_str(v[map[item]]) then
                    return true
                end
            end
        end
        return false
    end

    for k, _ in pairs(map) do
        if match(k, type(pattern) == "string" and pattern or pattern[k]) then
            return true
        end
    end

    return false
end

---@private
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
    if type(predicate) == "function" then
        return predicate
    elseif type(predicate) == "string" then
        return function(item)
            return item:type() == predicate
        end
    end
end

---@private
local function _check_limit(limit)
    return (type(limit) == "number" and limit > 0) and limit or 1 / 0
end

---@private
---BFS.
---Include the root node.
---@param node TSNode
---@param predicate fun(node: TSNode):boolean
---@param option { limit: integer, recursive: boolean, type: "bfs"|"dfs" }
---@return collections.List
local function _find_children_bfs(node, predicate, option)
    local result = List.new()
    local deque = Deque(node)
    local depth = 0
    local last = node
    local limit = _check_limit(option.limit)
    while deque:count() > 0 do
        if option.recursive and depth > 1 then
            break
        end
        local _node = deque:pop_front() --[[@as TSNode]]
        if predicate(_node) then
            if result:count() >= limit then
                break
            end
            result:add(Node.new(_node))
        end
        for child in _node:iter_children() do
            deque:push_back(child)
        end
        if _node == last then
            depth = depth + 1
            if deque:count() > 0 then
                last = deque:get_back()
            end
        end
    end
    return result
end

---@private
---DFS
---Exclude the root node.
---@param node TSNode
---@param predicate fun(node: TSNode):boolean
---@param option { limit: integer, recursive: boolean, type: "bfs"|"dfs" }
---@return collections.List
local function _find_children_dfs(node, predicate, option)
    local function dfs_(node_, predicate_, result_, option_)
        if not node_ then return end
        for child in node_:iter_children() do
            if predicate_(child) then
                if result_:count() >= option_.limit then
                    return
                end
                result_:add(Node.new(child))
            end
            if option.recursive then
                dfs_(child, predicate_, result_, option_)
            end
        end
    end
    local result = List.new()
    local opt = vim.deepcopy(option)
    opt.limit = _check_limit(option.limit)
    dfs_(node, predicate, result, opt)
    return result
end

---Find the first child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@param option? { limit: integer, recursive: boolean, type: "bfs"|"dfs" }
---@return ts.Node
function Node:find_first_child(predicate, option)
    local p = _check_predicate(predicate)
    if p then
        local option_ = vim.deepcopy(option) or {}
        option_.limit = 1
        local list = self:find_children(p, option_)
        if list:any() then
            return list[1]
        end
    end
    return Node.new()
end

---Find all child node by a predicate.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@param option? { limit: integer, recursive: boolean, type: "bfs"|"dfs" }
---@return collections.List
function Node:find_children(predicate, option)
    option = option or {}
    local p = _check_predicate(predicate)
    if self:is_nil() or not p then return List.new() end
    return (option.type == "bfs"
        and _find_children_bfs
        or _find_children_dfs)(self.node, p, option)
end

---Find node upward by a predicate at position (row, col).
---@param bufnr integer Buffer number.
---@param row integer Row number, 1-indexed.
---@param col integer Column number, 0-indexed.
---@param predicate string|fun(node: TSNode):boolean The predicate.
---@return TSNode?
function M.find_parent(bufnr, row, col, predicate)
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
end

M.cs = {
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
                "predefined_type",
            }, item:type())
        end)
        local type__name
        if not type_:is_nil() then
            type__name = vim.treesitter.get_node_text(type_.node, bufnr)
        end

        local param_list = root:find_first_child("parameter_list")
        if param_list:is_nil() then return end

        local params = param_list
            :find_children("parameter")
            :select(function(item)
                local ident = item.node:named_child(item.node:named_child_count() - 1)
                if not ident then return end
                return vim.treesitter.get_node_text(ident, bufnr)
            end)
            :where(function(item) return item ~= nil end)

        return type__name, params
    end,
}

M.cpp = {
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
            :find_first_child("function_declarator", { recursive = true })
            :find_first_child("parameter_list")

        if param_list:is_nil() then return end

        local params = param_list
            :find_children("parameter_declaration")
            :select(function(item)
                local ident = item:find_first_child("identifier", { recursive = true })
                if ident:is_nil() then return end
                return vim.treesitter.get_node_text(ident.node, bufnr)
            end)
            :where(function(item) return item ~= nil end)

        return type__name, params
    end,
}

M.Syntax = Syntax

return M
