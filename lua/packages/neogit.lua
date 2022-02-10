require('neogit').setup {}


local kbd = vim.api.nvim_set_keymap
kbd('n', '<leader>gn', '<Cmd>Neogit<CR>', { noremap = true, silent = true })
