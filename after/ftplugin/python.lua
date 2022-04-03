vim.cmd[[setlocal tabstop=4 shiftwidth=4 softtabstop=4]]

local lib = require('utility.lib')
local new_keymap = require('utility.util').new_keymap
local buf_handle = vim.api.nvim_get_current_buf()

vim.defer_fn(function ()
    new_keymap("i", '"', function (fallback)
        if lib.get_context('b'):match('^%s*""$') then
            lib.feedkeys('"\n"""<C-\\><C-O>O', 'n', true)
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = buf_handle })
end, 500)
