vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_ignore = { '.git', '.cache' }
vim.g.nvim_tree_window_picker_exclude = {
    filetype = {
        'qf',
        'help',
    },
    buftype = {
        'terminal',
    }
}
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1
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
    },
    lsp = {
        hint = "H",
        info = "I",
        warning = "W",
        error = "E",
    }
}
local tree_cb = require('nvim-tree.config').nvim_tree_callback
vim.g.nvim_tree_bindings = {
    { key = {"<CR>", "<2-LeftMouse>"}, cb = tree_cb("edit") },
    { key = {"C", "<2-RightMouse>"},   cb = tree_cb("cd") },
    { key = "s",      cb = tree_cb("vsplit") },
    { key = "i",      cb = tree_cb("split") },
    { key = "t",      cb = tree_cb("tabnew") },
    { key = "<C-K>",  cb = tree_cb("prev_sibling") },
    { key = "<C-J>",  cb = tree_cb("next_sibling") },
    { key = "<S-CR>", cb = tree_cb("close_node") },
    { key = "<Tab>",  cb = tree_cb("preview") },
    { key = "<C-I>",  cb = tree_cb("toggle_ignored") },
    { key = "<C-H>",  cb = tree_cb("toggle_dotfiles") },
    { key = "R",      cb = tree_cb("refresh") },
    { key = "a",      cb = tree_cb("create") },
    { key = "d",      cb = tree_cb("remove") },
    { key = "r",      cb = tree_cb("rename") },
    { key = "<C-R>",  cb = tree_cb("full_rename") },
    { key = "x",      cb = tree_cb("cut") },
    { key = "c",      cb = tree_cb("copy") },
    { key = "p",      cb = tree_cb("paste") },
    { key = "y",      cb = tree_cb("copy_name") },
    { key = "<M-y>",  cb = tree_cb("copy_path") },
    { key = "<M-Y>",  cb = tree_cb("copy_absolute_path") },
    { key = "hk",     cb = tree_cb("prev_git_item") },
    { key = "hj",     cb = tree_cb("next_git_item") },
    { key = "u",      cb = tree_cb("dir_up") },
    { key = "q",      cb = tree_cb("close") },
    { key = "o",      cb = ":call usr#misc#nvim_tree_os_open()<CR>" },
}


local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>op', ':NvimTreeToggle<CR>',              { noremap = true, silent = true })
keymap('n', '<M-e>',      ':NvimTreeFindFile<CR>',            { noremap = true, silent = true })
keymap('i', '<M-e>',      '<ESC>:NvimTreeFindFile<CR>',       { noremap = true, silent = true })
keymap('t', '<M-e>',      '<C-\\><C-n>:NvimTreeFindFile<CR>', { noremap = true, silent = true })
