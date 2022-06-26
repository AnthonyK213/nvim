require("neogit").setup {}


local kbd = vim.keymap.set
kbd("n", "<leader>gn", "<Cmd>Neogit<CR>", { noremap = true, silent = true })
