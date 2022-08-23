vim.g.table_mode_corner = "+"
local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd("n", "<leader>ta", ":TableAddFormula<CR>", _o)
kbd("n", "<leader>tc", ":TableEvalFormulaLine<CR>", _o)
kbd("n", "<leader>tf", ":TableModeRealign<CR>", _o)
