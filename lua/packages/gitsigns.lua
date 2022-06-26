local gitsigns = require("gitsigns")

gitsigns.setup {
    signs = {
        add = {
            hl     = "GitSignsAdd",
            text   = "│",
            numhl  = "GitSignsAddNr",
            linehl = "GitSignsAddLn"
        },
        change = {
            hl     = "GitSignsChange",
            text   = "│",
            numhl  = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn"
        },
        delete = {
            hl     = "GitSignsDelete",
            text   = "_",
            numhl  = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn"
        },
        topdelete = {
            hl     = "GitSignsDelete",
            text   = "‾",
            numhl  = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn"
        },
        changedelete = {
            hl     = "GitSignsChange",
            text   = "~",
            numhl  = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn"
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
    preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
    },
    on_attach = function (bufnr)
        local kbd = vim.keymap.set
        local ntst = { noremap = true, silent = true, buffer = bufnr }
        kbd("n", "<leader>gj", gitsigns.next_hunk , ntst)
        kbd("n", "<leader>gk", gitsigns.prev_hunk, ntst)
        kbd("n", "<leader>gp", gitsigns.preview_hunk, ntst)
        kbd("n", "<leader>gb", gitsigns.blame_line, ntst)
    end
}
