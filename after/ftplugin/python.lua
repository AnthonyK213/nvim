local lib = require("utility.lib")
local bufnr = vim.api.nvim_get_current_buf()

vim.defer_fn(function()
    require("utility.util").new_keymap("i", '"', function(fallback)
        local indent = lib.get_context().b:match('^(%s*)""$')
        if not indent then
            fallback()
            return
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, {
            [["]],
            indent,
            indent .. [["""]],
        })
        vim.api.nvim_win_set_cursor(0, { row + 1, col + #indent })
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
