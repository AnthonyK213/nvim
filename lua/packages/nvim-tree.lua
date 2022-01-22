vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_window_picker_exclude = {
    filetype = { 'qf', 'help' },
    buftype  = { 'terminal' }
}
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 0
}
vim.g.nvim_tree_icons = {
    default = '▪ ',
    symlink = '▫ ',
    git = {
        unstaged = "✗",
        staged = "✓",
        unmerged = "U",
        renamed = "➜",
        untracked = "★",
        deleted = "D",
        ignored = "◌"
    },
    folder = {
        default = "+",
        open = "-",
        empty = "*",
        empty_open = "*",
        symlink = "@",
        symlink_open = "@",
    }
}

require('nvim-tree').setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    open_on_setup       = false,
    ignore_ft_on_setup  = {},
    auto_close          = false,
    open_on_tab         = false,
    hijack_cursor       = true,
    update_cwd          = false,
    update_to_buf_dir   = {
        enable = true,
        auto_open = true,
    },
    diagnostics = {
        enable = false,
        icons = {}
    },
    update_focused_file = {
        enable      = true,
        update_cwd  = false,
        ignore_list = {}
    },
    system_open = {
        cmd  = nil,
        args = {}
    },
    filters = {
        dotfiles = true,
        custom = { '.git', '.cache' }
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 500
    },
    view = {
        width = 30,
        height = 30,
        hide_root_folder = false,
        side = 'left',
        auto_resize = false,
        mappings = {
            custom_only = true,
            list = {
                { key = {"<CR>", "<2-LeftMouse>"}, action = "edit" },
                { key = {"C", "<2-RightMouse>"},   action = "cd" },
                { key = "<C-I>",  action = "toggle_ignored" },
                { key = "<C-J>",  action = "next_sibling" },
                { key = "<C-K>",  action = "prev_sibling" },
                { key = "<C-R>",  action = "full_rename" },
                { key = "<M-Y>",  action = "copy_absolute_path" },
                { key = "<M-y>",  action = "copy_path" },
                { key = "<S-CR>", action = "close_node" },
                { key = "<Tab>",  action = "preview" },
                { key = "D",      action = "remove" },
                { key = "H",      action = "toggle_dotfiles" },
                { key = "R",      action = "refresh" },
                { key = "a",      action = "create" },
                { key = "c",      action = "copy" },
                { key = "gj",     action = "next_git_item" },
                { key = "gk",     action = "prev_git_item" },
                { key = "i",      action = "split" },
                { key = "o",      action = "system_open" },
                { key = "p",      action = "paste" },
                { key = "q",      action = "close" },
                { key = "r",      action = "rename" },
                { key = "s",      action = "vsplit" },
                { key = "t",      action = "tabnew" },
                { key = "u",      action = "dir_up" },
                { key = "x",      action = "cut" },
                { key = "y",      action = "copy_name" },
            }
        },
        number = false,
        relativenumber = false,
    },
    trash = {
        cmd = "trash",
        require_confirm = true
    }
}


local kbd = vim.api.nvim_set_keymap
local ntst = { noremap = true, silent = true }
kbd('n', '<leader>op', ':NvimTreeToggle<CR>',              ntst)
kbd('n', '<M-e>',      ':NvimTreeFindFile<CR>',            ntst)
kbd('i', '<M-e>',      '<ESC>:NvimTreeFindFile<CR>',       ntst)
kbd('t', '<M-e>',      '<C-\\><C-N>:NvimTreeFindFile<CR>', ntst)
