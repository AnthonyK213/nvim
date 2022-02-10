vim.g.table_mode_corner = '+'


local kbd = vim.api.nvim_set_keymap
local ntst = { noremap = true, silent = true }
kbd('n', '<leader>ta', ':TableAddFormula<CR>',      ntst)
kbd('n', '<leader>tc', ':TableEvalFormulaLine<CR>', ntst)
kbd('n', '<leader>tf', ':TableModeRealign<CR>',     ntst)
