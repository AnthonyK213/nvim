local border_style = _my_core_opt.tui.border
local border_styles = {
    single = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    double = { "═", "║", "═", "║", "╔" ,"╗", "╝", "╚" },
    rounded = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-Down>"] = require("telescope.actions").cycle_history_next,
                ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
            },
        },
        border = border_style ~= "none",
        borderchars = border_styles[border_style] or border_styles["rounded"]
    },
}

local builtin = require("telescope.builtin")
local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd("n", "<leader>fb", function () builtin.buffers() end, _o)
kbd("n", "<leader>ff", function () builtin.find_files() end, _o)
kbd("n", "<leader>fg", function () builtin.live_grep() end, _o)
