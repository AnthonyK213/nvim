vim.g.table_mode_corner = '+'


local kbd = vim.api.nvim_set_keymap
kbd('n', '<leader>ta', ':TableAddFormula<CR>',      { noremap = true, silent = true })
kbd('n', '<leader>tc', ':TableEvalFormulaLine<CR>', { noremap = true, silent = true })
kbd('n', '<leader>tf', ':TableModeRealign<CR>',     { noremap = true, silent = true })
