init_source('plugrc')


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
--- Disable the numbers disctracting
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


-- vim-markdown
vim.g.vim_markdown_math = 0
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 2
--- Toggle math display.
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
vim.g.mkdp_preview_options = {
    ['mkit']                = {},
    ['katex']               = {},
    ['uml']                 = {},
    ['maid']                = {},
    ['disable_sync_scroll'] = 0,
    ['sync_scroll_type']    = 'middle',
    ['hide_yaml_meta']      = 1,
    ['sequence_diagrams']   = {},
    ['flowchart_diagrams']  = {},
    ['content_editable']    = false
}


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


-- vim-orgmode
vim.g.org_agenda_path = vim.fn.expand(vim.g.onedrive_path.."/Documents/Agenda/Agenda.org")
vim.g.org_agenda_files = { vim.g.org_agenda_path }
vim.cmd([[command! OrgAgenda :exe ":tabnew" g:org_agenda_path]])


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
vim.g.pairs_map_ret  = 0
vim.g.pairs_map_bak  = 1
vim.g.pairs_map_spc  = 1
vim.g.pairs_usr_extd = {
    ["$"]   = "$",
    ["`"]   = "`",
    ["*"]   = "*",
    ["**"]  = "**",
    ["***"] = "***",
    ["<u>"] = "</u>"
}
vim.g.pairs_usr_extd_map = {
    ["<M-P>"] = "`",
    ["<M-I>"] = "*",
    ["<M-B>"] = "**",
    ["<M-M>"] = "***",
    ["<M-U>"] = "<u>"
}


-- nvim-colorizer
require('colorizer').setup()


-- UltiSnips
vim.g.UltiSnipsExpandTrigger       = "<C-c><C-s>"
vim.g.UltiSnipsJumpForwardTrigger  = "<C-c><C-j>"
vim.g.UltiSnipsJumpBackwardTrigger = "<C-c><C-k>"


-- completion-nvim
vim.g.completion_confirm_key         = ""
vim.g.completion_enable_snippet      = 'UltiSnips'
vim.g.completion_auto_change_source  = 1
vim.g.completion_chain_complete_list = {
    ['vim'] = {
        { ['complete_items'] = { 'UltiSnips' } },
        { ['mode']           = '<c-p>' },
        { ['mode']           = '<c-n>' }
    },
    ['lua'] = {
        { ['complete_items'] = { 'UltiSnips' } },
        { ['mode']           = '<c-p>' },
        { ['mode']           = '<c-n>' }
    },
    ['markdown'] = {
        { ['mode'] = '<c-p>' },
        { ['mode'] = '<c-n>' }
    },
    ['default'] = {
        { ['complete_items'] = { 'lsp', 'UltiSnips' } },
        { ['complete_items'] = { 'path' }, ['triggered_only'] = { '/' } },
        { ['mode']           = '<c-p>' },
        { ['mode']           = '<c-n>' }
    }
}
--- completion attach
local custom_attach = function(client)
    require'completion'.on_attach(client)
end
vim.api.nvim_set_keymap(
    'i',
    '<CR>',
    [[pumvisible() ? complete_info()["selected"] != "-1" ? ]]..
    [["<Plug>(completion_confirm_completion)" : "<C-E><CR>" : ]]..
    [["<Plug>(ipairs_enter)"]],
    { noremap = false, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<TAB>',
    [[Lib_Get_Char('b') =~ '\v^\s*(\+|-|*|\d+\.)\s$' ? ]]..
    [["<C-O>V>" . repeat(g:lib_const_r, &ts) : ]]..
    [["<Plug>(completion_smart_tab)"]],
    { noremap = false, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<S-TAB>',
    '<Plug>(completion_smart_s_tab)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-J>',
    '<Plug>(completion_next_source)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-K>',
    '<Plug>(completion_prev_source)',
    { noremap = false, silent = true })


-- nvim-lspconfig
local lspconfig = require'lspconfig'
--- clangd
lspconfig.clangd.setup { on_attach=custom_attach }
--- rls
lspconfig.rust_analyzer.setup { on_attach=custom_attach }
--- jedi_language_server
lspconfig.jedi_language_server.setup { on_attach=custom_attach }
--- texlab
lspconfig.texlab.setup { on_attach=custom_attach }
--- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics,
{ virtual_text = true, signs = true, update_in_insert = true })
