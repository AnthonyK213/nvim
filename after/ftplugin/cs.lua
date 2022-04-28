local lib = require('utility.lib')
local new_keymap = require('utility.util').new_keymap
local buf_handle = vim.api.nvim_get_current_buf()

vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4

vim.defer_fn(function ()
    new_keymap("i", '/', function (fallback)
        if lib.get_context().b:match('^%s*//$') then
            lib.feedkeys('/ <summary>\n\n</summary><Up> ', 'n', true)
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = buf_handle })
end, 500)

vim.keymap.set('n', '=G', function ()
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        vim.lsp.buf.formatting_sync()
    else
        lib.feedkeys('=G', 'n', true)
    end
end)
