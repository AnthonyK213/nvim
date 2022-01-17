require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-Down>"] = require('telescope.actions').cycle_history_next,
                ["<C-Up>"] = require('telescope.actions').cycle_history_prev,
            },
        },
    },
}

local kbd = vim.api.nvim_set_keymap
local ntst = { noremap = true, silent = true }
kbd('n', '<leader>fb', ':lua require("telescope.builtin").buffers()<CR>',    ntst)
kbd('n', '<leader>ff', ':lua require("telescope.builtin").find_files()<CR>', ntst)
kbd('n', '<leader>fg', ':lua require("telescope.builtin").live_grep()<CR>',  ntst)
