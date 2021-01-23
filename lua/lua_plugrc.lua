init_source('plugrc')

-- onedark.vim
vim.o.tgc = true
vim.o.bg  = 'dark'
vim.cmd('colorscheme onedark')
vim.g.airline_theme = 'onedark'


-- NERDTree
vim.g.NERDTreeDirArrowExpandable  = '+'
vim.g.NERDTreeDirArrowCollapsible = '-'
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeDirArrows = 1
vim.api.nvim_set_keymap(
    'n',
    '<leader>op',
    ':NERDTreeToggle<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<M-e>',
    ':NERDTreeFocus<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<M-e>',
    '<ESC>:NERDTreeFocus<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    't',
    '<M-e>',
    '<C-\\><C-n>:NERDTreeFocus<CR>',
    { noremap = true, silent = true })


-- signify
--- Signs
vim.g.signify_sign_add               = '+'
vim.g.signify_sign_delete            = '_'
vim.g.signify_sign_delete_first_line = '‾'
vim.g.signify_sign_change            = '~'
-- Disable the numbers disctracting
vim.g.signify_sign_show_count = 0
vim.g.signify_sign_show_text  = 1
vim.api.nvim_set_keymap(
    'n',
    '<leader>vj',
    '<Plug>(signify-next-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vk',
    '<Plug>(signify-prev-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vJ',
    '9999<Plug>(signify-next-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vK',
    '9999<Plug>(signify-prev-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vt',
    ':SignifyToggle<CR>',
    { noremap = true, silent = true })


-- vim-airline
--- hash: #
--- Separators
---     ;     ;    
vim.g.airline_left_sep     = ''
vim.g.airline_left_alt_sep = ''


-- vim-markdown
vim.g.vim_markdown_math = 0
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 2

function plugrc_lua_vim_markdown_math_toggle()
    vim.g.vim_markdown_math = 1 - vim.g.vim_markdown_math
    vim.cmd('syn off | syn on')
end

vim.api.nvim_set_keymap(
    'n',
    '<leader>mh',
    ':Toch<CR>:resize 15<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>mv',
    ':Tocv<CR>:vertical resize 50<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>mm',
    ':call v:lua.plugrc_lua_vim_markdown_math_toggle()<CR>',
    { noremap = true, silent = true })


-- markdown-preview
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1


-- vim-table-mode
vim.api.nvim_set_keymap(
    'n',
    '<leader>ta',
    ':TableAddFormula<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>tc',
    ':TableEvalFormulaLine<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>tf',
    ':TableModeRealign<CR>',
    { noremap = true, silent = true })


-- vimtex
vim.g.tex_flavor = 'latex'
if (vim.fn.has("win32") == 1) then
    vim.g.vimtex_view_general_viewer = 'SumatraPDF'
    vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
elseif (vim.fn.has("unix") == 1) then
    vim.g.vimtex_view_general_viewer = 'zathura'
end
vim.g.vimtex_view_general_options_latexmk = '-reuse-instance'
vim.g.vimtex_compiler_progname = 'nvr'


-- indentLine
vim.g.indentLine_char = '¦'
--vim.g.indentLine_setConceal = 1


-- vim-ipairs
vim.g.pairs_map_ret = 1
vim.g.pairs_map_bak = 1
vim.g.pairs_map_spc = 1


-- nvim-colorizer
require('colorizer').setup()


-- nvim-lspconfig && completion-nvim
--- rls
local lspconfig = require'lspconfig'
lspconfig.rls.setup {
    settings = {
        rust = {
            unstable_features = true,
            build_on_save = false,
            all_features = true,
        },
    },
    on_attach=require'completion'.on_attach
}
--- jedi_language_server
lspconfig.jedi_language_server.setup {
    on_attach=require'completion'.on_attach
}
--- texlab
lspconfig.texlab.setup {
    on_attach=require'completion'.on_attach
}
