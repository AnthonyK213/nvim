vim.g.vim_markdown_math = 0
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 2


local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>mh', ':Toch<CR>:resize 15<CR>',                       { noremap = true, silent = true })
keymap('n', '<leader>mv', ':call usr#misc#show_toc()<CR>',                 { noremap = true, silent = true })
keymap('n', '<leader>mm', ':call usr#misc#vim_markdown_math_toggle()<CR>', { noremap = true, silent = true })
