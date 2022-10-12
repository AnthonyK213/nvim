require("neogit").setup {
    integrations = {
        diffview = true
    }
}

local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd("n", "<leader>gn", "<Cmd>Neogit<CR>", _o)
