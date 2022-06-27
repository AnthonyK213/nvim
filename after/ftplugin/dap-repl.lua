require("dap.ext.autocompl").attach()

vim.keymap.set("i", "<Tab>", "<C-N>", { noremap = true, silent = true, buffer = true })
vim.keymap.set("i", "<S-Tab>", "<C-P>", { noremap = true, silent = true, buffer = true })
