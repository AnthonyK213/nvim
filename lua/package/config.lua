-- NERDTree
vim.g.NERDTreeDirArrowExpandable  = '+'
vim.g.NERDTreeDirArrowCollapsible = '-'
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeDirArrows = 1


-- signify
--- Signs
vim.g.signify_sign_add               = '+'
vim.g.signify_sign_delete            = '_'
vim.g.signify_sign_delete_first_line = '‾'
vim.g.signify_sign_change            = '~'
--- Disable the numbers disctracting
vim.g.signify_sign_show_count = 0
vim.g.signify_sign_show_text  = 1


-- vim-markdown
vim.g.vim_markdown_math = 0
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 2


-- markdown-preview
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_preview_options = {
    mkit                = {},
    katex               = {},
    uml                 = {},
    maid                = {},
    disable_sync_scroll = 0,
    sync_scroll_type    = 'middle',
    hide_yaml_meta      = 1,
    sequence_diagrams   = {},
    flowchart_diagrams  = {},
    content_editable    = false
}


-- vim-table-mode
vim.g.table_mode_corner = '+'


-- vim-orgmode
vim.g.org_agenda_path = vim.fn.expand(vim.g.onedrive_path.."/Documents/Agenda/Agenda.org")
vim.g.org_agenda_files = { vim.g.org_agenda_path }


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
vim.g.indentLine_enabled = 1
vim.g.indentLine_char = '¦'
vim.g.indentLine_setConceal = 1


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


-- completion-nvim
vim.g.completion_confirm_key         = ""
vim.g.completion_enable_snippet      = 'UltiSnips'
vim.g.completion_enable_auto_popup   = 1
vim.g.completion_auto_change_source  = 1
vim.g.completion_matching_smart_case = 1
vim.g.completion_trigger_keyword_length = 2
vim.g.completion_matching_strategy_list = { 'exact', 'substring', 'fuzzy' }
vim.g.completion_chain_complete_list = {
    default = {
        { complete_items = { 'lsp', 'UltiSnips' } },
        { complete_items = { 'path' }, triggered_only = { '/' } },
        { mode           = '<c-p>' },
        { mode           = '<c-n>' }
    },
    vim = {
        { complete_items = { 'UltiSnips' } },
        { mode           = '<c-p>' },
        { mode           = '<c-n>' }
    },
    lua = {
        { complete_items = { 'ts', 'UltiSnips' } },
        { mode           = '<c-p>' },
        { mode           = '<c-n>' }
    },
    markdown = {
        { mode = '<c-p>' },
        { mode = '<c-n>' }
    },
    string = {
        { complete_items = { 'path' }, triggered_only = { '/' } },
    },
    comment = {}
}
--- completion attach
local custom_attach = function()
    require'completion'.on_attach()
end


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
    { virtual_text = true, signs = true, update_in_insert = false })


-- treesitter
require'nvim-treesitter.configs'.setup {
    highlight = { enable = true },
}
