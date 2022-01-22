require('gitsigns').setup {
    signs = {
        add = {
            hl     = 'GitSignsAdd',
            text   = '│',
            numhl  = 'GitSignsAddNr',
            linehl = 'GitSignsAddLn'
        },
        change = {
            hl     = 'GitSignsChange',
            text   = '│',
            numhl  = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        },
        delete = {
            hl     = 'GitSignsDelete',
            text   = '_',
            numhl  = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        topdelete = {
            hl     = 'GitSignsDelete',
            text   = '‾',
            numhl  = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        changedelete = {
            hl     = 'GitSignsChange',
            text   = '~',
            numhl  = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        },
    },
    numhl = false,
    linehl = false,
    watch_gitdir = {
        interval = 1000
    },
    current_line_blame = false,
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
}


local kbd = vim.api.nvim_set_keymap
local ntst = { noremap = true, silent = true }
kbd('n', '<leader>gj', '<Cmd>lua require("gitsigns").next_hunk()<CR>', ntst)
kbd('n', '<leader>gk', '<Cmd>lua require("gitsigns").prev_hunk()<CR>', ntst)
kbd('n', '<leader>gp', '<Cmd>lua require("gitsigns").preview_hunk()<CR>', ntst)
kbd('n', '<leader>gb', '<Cmd>lua require("gitsigns").blame_line()<CR>', ntst)
