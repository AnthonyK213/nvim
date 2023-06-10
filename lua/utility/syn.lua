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
---@param predicate string|string[]|fun(node: TSNode):boolean The predicate.
---@return nil|fun(node: TSNode):boolean
local function _check_predicate(predicate)
    if type(predicate) == "function" then
        return predicate
    elseif type(predicate) == "string" then
        return function(item)
            return item:type() == predicate
        end
    elseif vim.tbl_islist(predicate) then
        return function(item)
            return vim.list_contains(predicate, item:type())
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
---@param predicate string|string[]|fun(node: TSNode):boolean The predicate.
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
---@param predicate string|string[]|fun(node: TSNode):boolean The predicate.
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

---Find the first appeared ancestor by `predicate`.
---@param predicate string|string[]|fun(node: TSNode):boolean The predicate.
---@return ts.Node
function Node:find_ancestor(predicate)
    local p = _check_predicate(predicate)
    if not self:is_nil() and p then
        local current = self.node:parent()
        while current do
            if p(current) then
                return Node.new(current)
            end
            current = current:parent()
        end
    end
    return Node.new()
end

---Get reverse lookup table for query.
---@param query Query
---@return table
function M.captures_reverse_lookup(query)
    local captures = vim.deepcopy(query.captures)
    vim.tbl_add_reverse_lookup(captures)
    return captures
end

M.cs = {
    ---Extract method/constructor parameter list.
    ---@param param_list_node TSNode The `parameter_list` node.
    ---@param bufnr integer Buffer number.
    ---@return collections.List? param_list
    extract_params = function(param_list_node, bufnr)
        return Node.new(param_list_node)
            :find_children("parameter")
            :select(function(item)
                local ident = item.node:named_child(item.node:named_child_count() - 1)
                if not ident then return end
                return vim.treesitter.get_node_text(ident, bufnr)
            end)
            :where(function(item) return item ~= nil end)
    end,
}

M.cpp = {
    ---Extract function parameter list.
    ---@param param_list_node TSNode The `parameter_list` node.
    ---@param bufnr integer Buffer number.
    ---@return collections.List
    extract_params = function(param_list_node, bufnr)
        return Node.new(param_list_node)
            :find_children("parameter_declaration")
            :select(function(item)
                local ident = item:find_first_child("identifier", { recursive = true })
                if ident:is_nil() then return end
                return vim.treesitter.get_node_text(ident.node, bufnr)
            end)
            :where(function(item) return item ~= nil end)
    end
}

M.Syntax = Syntax

M.Node = Node

return M
