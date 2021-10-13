require('neogit').setup {}


local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>gn', ':Neogit<CR>', { noremap = true, silent = true })
