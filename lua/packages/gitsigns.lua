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
    keymaps = {
        noremap = true,
        buffer = true,
        ['n <leader>gj'] = '<cmd>lua require("gitsigns").next_hunk()<CR>',
        ['n <leader>gk'] = '<cmd>lua require("gitsigns").prev_hunk()<CR>',
        ['n <leader>gp'] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
        ['n <leader>gb'] = '<cmd>lua require("gitsigns").blame_line()<CR>',
        ['o ih'] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require("gitsigns").select_hunk()<CR>'
    },
    watch_gitdir = {
        interval = 1000
    },
    current_line_blame = false,
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
}
