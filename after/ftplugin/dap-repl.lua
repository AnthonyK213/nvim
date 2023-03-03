require("dap.ext.autocompl").attach()
local opt = { noremap = true, silent = true, buffer = true }
vim.keymap.set("i", "<Tab>", "<C-N>", opt)
vim.keymap.set("i", "<S-Tab>", "<C-P>", opt)
vim.keymap.set({ "n", "i" }, "<M-d>", "<C-\\><C-N><Cmd>bd!<CR>", opt)
