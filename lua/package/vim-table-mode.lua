vim.g.table_mode_corner = '+'


local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>ta', ':TableAddFormula<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>tc', ':TableEvalFormulaLine<CR>', { noremap = true, silent = true })
keymap('n', '<leader>tf', ':TableModeRealign<CR>',     { noremap = true, silent = true })
