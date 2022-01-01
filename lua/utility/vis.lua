local M = {}
local lib = require('utility.lib')


---Extend highlight groups.
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

---Show syntax information under the cursor.
function M.show_hl_captures()
    local pos = vim.api.nvim_win_get_cursor(0)
    local lines = {}

    local show_matches = function(syntax_table)
        if #syntax_table == 0 then
            table.insert(lines, "* No highlight groups found")
        end
        for _, syntax in ipairs(syntax_table) do
            table.insert(lines, syntax:show())
        end
        table.insert(lines, "")
    end

    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
        table.insert(lines, "# Treesitter")
        show_matches(lib.get_treesitter_info(unpack(pos)))
    end

    if vim.b.current_syntax then
        table.insert(lines, "# Syntax")
        show_matches(lib.get_syntax_stack(unpack(pos)))
    end

    vim.lsp.util.open_floating_preview(
    lines, "markdown", { border = "single", pad_left = 4, pad_right = 4 })
end


return M
