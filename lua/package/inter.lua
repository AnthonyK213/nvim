local keymap = vim.api.nvim_set_keymap
local augroup = require("utility/lib").set_au_group


-- nvim-tree.lua
keymap('n', '<leader>op', ':NvimTreeToggle<CR>',              { noremap = true, silent = true })
keymap('n', '<M-e>',      ':NvimTreeFindFile<CR>',            { noremap = true, silent = true })
keymap('i', '<M-e>',      '<ESC>:NvimTreeFindFile<CR>',       { noremap = true, silent = true })
keymap('t', '<M-e>',      '<C-\\><C-n>:NvimTreeFindFile<CR>', { noremap = true, silent = true })
-- telescope.nvim
keymap('n', '<leader>fb', ':lua require("telescope.builtin").buffers()<CR>',    { noremap = true, silent = true })
keymap('n', '<leader>ff', ':lua require("telescope.builtin").find_files()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>fg', ':lua require("telescope.builtin").live_grep()<CR>',  { noremap = true, silent = true })
-- vim-markdown
keymap('n', '<leader>mh', ':Toch<CR>:resize 15<CR>',                       { noremap = true, silent = true })
keymap('n', '<leader>mv', ':call usr#misc#toc_of_md_tex()<CR>',            { noremap = true, silent = true })
keymap('n', '<leader>mm', ':call usr#misc#vim_markdown_math_toggle()<CR>', { noremap = true, silent = true })
-- vim-table-mode
keymap('n', '<leader>ta', ':TableAddFormula<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>tc', ':TableEvalFormulaLine<CR>', { noremap = true, silent = true })
keymap('n', '<leader>tf', ':TableModeRealign<CR>',     { noremap = true, silent = true })
-- vim-vsnip & nvim-compe
keymap('i', '<CR>',
[[compe#confirm("<Plug>(lua_pairs_enter)")]],
{ noremap = false, silent = true, expr = true })
keymap('i', '<TAB>',
[[pumvisible() ? ]]..
[["<C-n>" : luaeval("require('utility/lib').get_context('b')") =~ '\v^\s*(\+|-|*|\d+\.)\s$' ? ]]..
[["<C-\><C-O>>>" . repeat(g:const_dir_r, &ts) : vsnip#jumpable(1) ? ]]..
[["<Plug>(vsnip-jump-next)" : luaeval("require('utility/lib').get_context('l')") =~ '\v(\w|\.|_)' ? ]]..
[[compe#complete() : "<TAB>"]],
{ noremap = false, silent = true, expr = true })
keymap('s', '<TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
keymap('i', '<S-TAB>',
[[pumvisible() ? ]]..
[["<C-p>" : vsnip#jumpable(1) ? ]]..
[["<Plug>(vsnip-jump-prev)" : "<S-TAB>"]],
{ noremap = false, silent = true, expr = true })
keymap('s', '<S-TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-prev)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
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
-- nvim-bufferline.lua
keymap('n', '<leader>bb', '<cmd>BufferLinePick<CR>', { noremap = true, silent = true })

-- nvim-colorizer.lua
vim.cmd('command! ColorizerReset lua package.loaded["colorizer"] = nil require("colorizer").setup() require("colorizer").attach_to_buffer(0)')

-- nvim-lspconfig
augroup('lsp_diagnositic_on_hold', 'CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')
