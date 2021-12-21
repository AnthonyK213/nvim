local M = {}
local lib = require('utility/lib')
local highlighter = require "vim.treesitter.highlighter"
local ts_utils = require "nvim-treesitter.ts_utils"


-- Extend highlight groups.
function M.hi_extd()
    local set_hi = lib.set_highlight_group
    set_hi('SpellBad',                vim.g.terminal_color_1, nil, 'underline')
    set_hi('SpellCap',                vim.g.terminal_color_3, nil, 'underline')
    set_hi('markdownH1',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownH2',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownH3',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownH4',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownH5',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownH6',              vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownUrl',             vim.g.terminal_color_4, nil, nil)
    set_hi('markdownBold',            vim.g.terminal_color_3, nil, 'bold')
    set_hi('markdownCode',            vim.g.terminal_color_2, nil, nil)
    set_hi('markdownItalic',          vim.g.terminal_color_5, nil, 'italic')
    set_hi('markdownCodeDelimiter',   vim.g.terminal_color_8, nil, nil)
    set_hi('markdownLinkText',        vim.g.terminal_color_6, nil, 'underline')
    set_hi('markdownTSEmphasis',      vim.g.terminal_color_5, nil, 'italic')
    set_hi('markdownTSLiteral',       vim.g.terminal_color_2, nil, nil)
    set_hi('markdownTSNone',          vim.g.terminal_color_7, nil, nil)
    set_hi('markdownTSPunctSpecial',  vim.g.terminal_color_1, nil, nil)
    set_hi('markdownTSStringEscape',  vim.g.terminal_color_6, nil, 'bold')
    set_hi('markdownTSStrong',        vim.g.terminal_color_3, nil, 'bold')
    set_hi('markdownTSTextReference', vim.g.terminal_color_6, nil, 'underline')
    set_hi('markdownTSTitle',         vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownTSURI',           vim.g.terminal_color_4, nil, nil)
end

-- Get syntax/treesitter highlight information.
-- https://github.com/nvim-treesitter/playground
function M.get_treesitter_hl()
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    local self = highlighter.active[buf]

    if not self then
        return {}
    end

    local matches = {}

    self.tree:for_each_tree(function(tstree, tree)
        if not tstree then
            return
        end

        local root = tstree:root()
        local root_start_row, _, root_end_row, _ = root:range()

        -- Only worry about trees within the line range
        if root_start_row > row or root_end_row < row then
            return
        end

        local query = self:get_query(tree:lang())

        -- Some injected languages may not have highlight queries.
        if not query:query() then
            return
        end

        local iter = query:query():iter_captures(root, self.bufnr, row, row + 1)

        for capture, node, metadata in iter do
            local hl = query.hl_cache[capture]

            if hl and ts_utils.is_in_node_range(node, row, col) then
                local c = query._query.captures[capture] -- name of the capture in the query
                if c ~= nil then
                    local general_hl = query:_get_hl_from_capture(capture)
                    local line = "* **@"..c.."** -> "..hl
                    if general_hl ~= hl then
                        line = line.." -> **"..general_hl.."**"
                    end
                    if metadata.priority then
                        line = line.." *(priority "..metadata.priority..")*"
                    end
                    table.insert(matches, line)
                end
            end
        end
    end, true)
    return matches
end

function M.get_syntax_hl()
    local line = vim.fn.line "."
    local col = vim.fn.col "."
    local matches = {}
    for _, i1 in ipairs(vim.fn.synstack(line, col)) do
        local i2 = vim.fn.synIDtrans(i1)
        local n1 = vim.fn.synIDattr(i1, "name")
        local n2 = vim.fn.synIDattr(i2, "name")
        table.insert(matches, "* "..n1.." -> **"..n2.."**")
    end
    return matches
end

function M.show_hl_captures()
    local buf = vim.api.nvim_get_current_buf()
    local lines = {}

    local function show_matches(matches)
        if #matches == 0 then
            table.insert(lines, "* No highlight groups found")
        end
        for _, line in ipairs(matches) do
            table.insert(lines, line)
        end
        table.insert(lines, "")
    end

    if highlighter.active[buf] then
        table.insert(lines, "# Treesitter")
        local matches = M.get_treesitter_hl()
        show_matches(matches)
    end

    if vim.b.current_syntax then
        table.insert(lines, "# Syntax")
        local matches = M.get_syntax_hl()
        show_matches(matches)
    end

    vim.lsp.util.open_floating_preview(lines, "markdown", { border = "single", pad_left = 4, pad_right = 4 })
end


return M
