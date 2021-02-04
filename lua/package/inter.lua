local keymap = vim.api.nvim_set_keymap


-- NERDTree
keymap('n', '<leader>op', ':NERDTreeToggle<CR>',           { noremap = true, silent = true })
keymap('n', '<M-e>',      ':NERDTreeFocus<CR>',            { noremap = true, silent = true })
keymap('i', '<M-e>',      '<ESC>:NERDTreeFocus<CR>',       { noremap = true, silent = true })
keymap('t', '<M-e>',      '<C-\\><C-n>:NERDTreeFocus<CR>', { noremap = true, silent = true })
-- fzf
keymap('n', '<leader>bx', ':Buffers<CR>', { noremap = true, silent = true })
keymap('n', '<leader>ff', ':Files<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>fg', ':Rg<CR>',      { noremap = true, silent = true })
-- signify
keymap('n', '<leader>vj', '<Plug>(signify-next-hunk)',     { noremap = false, silent = true })
keymap('n', '<leader>vk', '<Plug>(signify-prev-hunk)',     { noremap = false, silent = true })
keymap('n', '<leader>vJ', '9999<Plug>(signify-next-hunk)', { noremap = false, silent = true })
keymap('n', '<leader>vK', '9999<Plug>(signify-prev-hunk)', { noremap = false, silent = true })
keymap('n', '<leader>vt', ':SignifyToggle<CR>',            { noremap = true,  silent = true })
-- vim-markdown
keymap('n', '<leader>mh', ':Toch<CR>:resize 15<CR>',                                     { noremap = true, silent = true })
keymap('n', '<leader>mv', ':Tocv<CR>:vertical resize 50<CR>',                            { noremap = true, silent = true })
keymap('n', '<leader>mm', ':lua require("utility/util").vim_markdown_math_toggle()<CR>', { noremap = true, silent = true })
-- vim-table-mode
keymap('n', '<leader>ta', ':TableAddFormula<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>tc', ':TableEvalFormulaLine<CR>', { noremap = true, silent = true })
keymap('n', '<leader>tf', ':TableModeRealign<CR>',     { noremap = true, silent = true })
-- UltiSnips
vim.g.UltiSnipsExpandTrigger       = "<C-C><C-S>"
vim.g.UltiSnipsJumpForwardTrigger  = "<C-C><C-L>"
vim.g.UltiSnipsJumpBackwardTrigger = "<C-C><C-H>"
-- completion-nvim
keymap('i', '<CR>',
    [[pumvisible() ? complete_info()["selected"] != "-1" ? ]]..
    [["<Plug>(completion_confirm_completion)" : "<C-E><CR>" : ]]..
    [["<Plug>(ipairs_enter)"]],
    { noremap = false, silent = true, expr = true })
keymap('i', '<TAB>',
    [[luaeval("require('utility/lib').get_context('b')") =~ '\v^\s*(\+|-|*|\d+\.)\s$' ? ]]..
    [["<C-\><C-O>V>" . repeat(g:const_dir_r, &ts) : ]]..
    [["<Plug>(completion_smart_tab)"]],
    { noremap = false, silent = true, expr = true })
keymap('i', '<S-TAB>',    '<Plug>(completion_smart_s_tab)', { noremap = false, silent = true })
keymap('i', '<C-C><C-J>', '<Plug>(completion_next_source)', { noremap = false, silent = true })
keymap('i', '<C-C><C-K>', '<Plug>(completion_prev_source)', { noremap = false, silent = true })
-- nvim-lspconfig
keymap('n', 'K', '<cmd>lua require("utility/util").show_doc()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>ga', '<cmd>lua vim.lsp.buf.code_action()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>gd', '<cmd>lua vim.lsp.buf.declaration()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>gf', '<cmd>lua vim.lsp.buf.definition()<CR>',       { noremap = true, silent = true })
keymap('n', '<leader>gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>',       { noremap = true, silent = true })
keymap('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>gw', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { noremap = true, silent = true })


-- vim-orgmode
vim.cmd('command! OrgAgenda :exe ":tabnew" g:org_agenda_path')
-- vimtex
vim.cmd('augroup completion_nvim_enable_all')
vim.cmd('autocmd!')
vim.cmd('au BufEnter * lua require("completion").on_attach()')
vim.cmd('augroup end')
-- nvim-lspconfig
vim.cmd('augroup lsp_diagnositic_on_hold')
vim.cmd('autocmd!')
vim.cmd('au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')
vim.cmd('augroup end')
