local M = {}
local lib = require('utility.lib')


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
