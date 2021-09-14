local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>fb', ':lua require("telescope.builtin").buffers()<CR>',    { noremap = true, silent = true })
keymap('n', '<leader>ff', ':lua require("telescope.builtin").find_files()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>fg', ':lua require("telescope.builtin").live_grep()<CR>',  { noremap = true, silent = true })
