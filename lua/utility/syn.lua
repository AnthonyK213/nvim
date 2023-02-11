---Syntax structure.
---@class Syntax
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
---@return Syntax
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

return Syntax
