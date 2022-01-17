require('neogit').setup {}


local kbd = vim.api.nvim_set_keymap
kbd('n', '<leader>gn', ':Neogit<CR>', { noremap = true, silent = true })
