local aerial = require'aerial'
require('telescope').load_extension('aerial')

local M = {}

function M.aerial_on_attach(client)
    aerial.on_attach(client)
    -- Toggle the aerial window with <leader>a
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mt', '<Cmd>AerialToggle!<CR>', {})
    -- Jump forwards/backwards with '{' and '}'
    vim.api.nvim_buf_set_keymap(0, 'n', '{', '<Cmd>AerialPrev<CR>', {})
    vim.api.nvim_buf_set_keymap(0, 'n', '}', '<Cmd>AerialNext<CR>', {})
    -- Jump up the tree with '[[' or ']]'
    vim.api.nvim_buf_set_keymap(0, 'n', '[[', '<Cmd>AerialPrevUp<CR>', {})
    vim.api.nvim_buf_set_keymap(0, 'n', ']]', '<Cmd>AerialNextUp<CR>', {})
end

return M
