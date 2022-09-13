---Syntax structure.
---@class Syntax
---@field vs table Vim syntax.
---@field ts table Treesitter.
local Syntax = {}

Syntax.__index = Syntax

---Get syntax stack.
---@param row integer 1-based row number.
---@param col integer 0-based column number.
---@return table result Syntax table.
local function get_vs(row, col)
    local vs = {}
    for _, id in ipairs(vim.fn.synstack(row, col + 1)) do
        local name = vim.fn.synIDattr(id, "name")
        local link_id = vim.fn.synIDtrans(id)
        local link_name = vim.fn.synIDattr(link_id, "name")
        table.insert(vs, {
            id = id,
            name = name,
            link_id = link_id,
            link_name = link_name
        })
    end
    return vs
end

---Get treesitter information.
---https://github.com/nvim-treesitter/playground
---@param row integer 1-based row number.
---@param col integer 0-based column number.
---@return table result Syntax table.
local function get_ts(row, col)
    local buf = vim.api.nvim_get_current_buf()
    local row_0 = row - 1
    local buf_highlighter = vim.treesitter.highlighter.active[buf]
    if not buf_highlighter then return {} end
    local ts = {}

    buf_highlighter.tree:for_each_tree(function(tstree, tree)
        if not tstree then return end

        local root = tstree:root()
        local root_start_row, _, root_end_row, _ = root:range()

        -- Only worry about trees within the line range
        if root_start_row > row_0 or root_end_row < row_0 then return end

        local query = buf_highlighter:get_query(tree:lang())

        -- Some injected languages may not have highlight queries.
        if not query:query() then return end

        local iter = query:query():iter_captures(root, buf_highlighter.bufnr, row_0, row)

        for capture, node, metadata in iter do
            local hl = query.hl_cache[capture]

            local is_in_node_range
            local start_row, start_col, end_row, end_col = node:range()
            if row_0 >= start_row and row_0 <= end_row then
                if row_0 == start_row and row_0 == end_row then
                    is_in_node_range = col >= start_col and col < end_col
                elseif row_0 == start_row then
                    is_in_node_range = col >= start_col
                elseif row_0 == end_row then
                    is_in_node_range = col < end_col
                else
                    is_in_node_range = true
                end
            else
                is_in_node_range = false
            end

            if hl and is_in_node_range then
                -- Name of the capture in the query
                local c = query._query.captures[capture]
                if c then
                    table.insert(ts, {
                        id = hl,
                        name = c,
                        token = c,
                        metadata = metadata
                    })
                end
            end
        end
    end, true)
    return ts
end

---Constructor.
---@param row integer 1-based row number.
---@param col integer 0-based column number.
---@return Syntax
function Syntax.new(row, col)
    local vs, ts = {}, {}

    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
        ts = get_ts(row, col)
    end

    if vim.b.current_syntax then
        vs = get_vs(row, col)
    end

    local o = {
        vs = vs,
        ts = ts
    }

    setmetatable(o, Syntax)
    return o
end

---Match syntax name by vim.regex.
---@param t_pattern string Matching pattern among `self.ts` and `self.vs`,
--- but if `v_pattern` is given and not empty, then just match among `self.ts`.
---@param v_pattern? string Matching pattern among `self.vs`.
---@return boolean matched True if matched.
function Syntax:match(t_pattern, v_pattern)
    local re
    local match = function (s)
        for _, obj in ipairs(s) do
            if re:match_str(obj.name) then
                return true
            end
        end
    end
    if #t_pattern == 0 then
        if type(v_pattern) == "string" and #v_pattern > 0 then
            re = vim.regex(v_pattern)
            if match(self.vs) then return true end
        end
    else
        re = vim.regex(t_pattern)
        if match(self.ts) then return true end
        if type(v_pattern) == "string" then
            if #v_pattern > 0 then
                re = vim.regex(v_pattern)
                if match(self.vs) then return true end
            end
        else
            if match(self.vs) then return true end
        end
    end

    return false
end

---Show syntax information.
function Syntax:show()
    local lines = {}

    if not vim.tbl_isempty(self.ts) then
        table.insert(lines, "# Treesitter")
        for _, obj in ipairs(self.ts) do
            local line = "* **@"..obj.token.."** -> "..obj.id
            if obj.name ~= obj.id then
                line = line.." -> **"..obj.name.."**"
            end
            if obj.metadata.priority then
                line = line.." *(priority "..obj.metadata.priority..")*"
            end
            table.insert(lines, line)
        end
    end

    if not vim.tbl_isempty(self.vs) then
        table.insert(lines, "# Vim_Syntax")
        for _, obj in ipairs(self.vs) do
            table.insert(lines, "* "..obj.name.." -> **"..obj.link_name.."**")
        end
    end

    if vim.tbl_isempty(lines) then
        table.insert(lines, "* No highlight groups found.")
    end

    vim.lsp.util.open_floating_preview(lines, "markdown", {
        border = _my_core_opt.tui.border,
        pad_left = 4,
        pad_right = 4
    })
end

---Match syntax name at cursor.
---See `Syntax:match(t_pattern, v_pattern)`.
---@param t_pattern string
---@param v_pattern? string
---@return boolean matched True if matched.
function Syntax.match_here(t_pattern, v_pattern)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return Syntax.new(row, col):match(t_pattern, v_pattern)
end


return Syntax
