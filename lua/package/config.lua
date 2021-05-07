-- matchit & matchparen
vim.g.loaded_matchit = 1
--vim.g.loaded_matchparen = 1


-- nvim-tree.lua
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1
}
vim.g.nvim_tree_ignore = { '.git', '.cache' }
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


-- neogit
require('neogit').setup {}


-- gitsigns.nvim
require('gitsigns').setup {
    signs = {
        add = {
            hl     = 'GitSignsAdd',
            text   = '│',
            numhl  = 'GitSignsAddNr',
            linehl = 'GitSignsAddLn'
        },
        change = {
            hl     = 'GitSignsChange',
            text   = '│',
            numhl  = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        },
        delete = {
            hl     = 'GitSignsDelete',
            text   = '_',
            numhl  = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        topdelete = {
            hl     = 'GitSignsDelete',
            text   = '‾',
            numhl  = 'GitSignsDeleteNr',
            linehl = 'GitSignsDeleteLn'
        },
        changedelete = {
            hl     = 'GitSignsChange',
            text   = '~',
            numhl  = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn'
        },
    },
    numhl = false,
    linehl = false,
    keymaps = {
        noremap = true,
        buffer = true,
        ['n <leader>hj'] = '<cmd>lua require("gitsigns").next_hunk()<CR>',
        ['n <leader>hk'] = '<cmd>lua require("gitsigns").prev_hunk()<CR>',
        ['n <leader>hp'] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
        ['n <leader>hb'] = '<cmd>lua require("gitsigns").blame_line()<CR>',
        ['o ih'] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require("gitsigns").select_hunk()<CR>'
    },
    watch_index = {
        interval = 1000
    },
    current_line_blame = false,
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    use_decoration_api = true,
    use_internal_diff = false,  -- If luajit is present
}


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


-- vimwiki
vim.g.vimwiki_list = {{
    path = vim.fn.expand(vim.g.onedrive_path.."/Documents/Agenda/"),
    path_html = vim.fn.expand(vim.g.onedrive_path.."/Documents/Agenda/html/"),
    syntax = 'default',
    ext = '.wiki'
}}
vim.g.vimwiki_folding    = 'syntax'
vim.g.vimwiki_ext2syntax = { ['.wikimd']='markdown' }


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


-- lua-pairs
require('lua-pairs').setup {
    ret = false,
    bak = true,
    spc = true,
    extd = {
        ["$"]   = "$",
        ["`"]   = "`",
        ["*"]   = "*",
        ["**"]  = "**",
        ["***"] = "***",
        ["<u>"] = "</u>"
    },
    extd_map = {
        ["<M-P>"] = "`",
        ["<M-I>"] = "*",
        ["<M-B>"] = "**",
        ["<M-M>"] = "***",
        ["<M-U>"] = "<u>"
    }
}


-- vim-vsnip
if vim.fn.has('win32') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$localappdata/nvim/snippet')
elseif vim.fn.has('unix') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$HOME/.config/nvim/snippet')
end


-- completion-nvim
vim.g.completion_confirm_key         = ""
vim.g.completion_enable_snippet      = 'vim-vsnip'
vim.g.completion_enable_auto_popup   = 1
vim.g.completion_auto_change_source  = 1
vim.g.completion_matching_smart_case = 1
vim.g.completion_trigger_keyword_length = 2
vim.g.completion_matching_strategy_list = { 'exact', 'substring', 'fuzzy' }
vim.g.completion_chain_complete_list = {
    default = {
        { complete_items = { 'lsp', 'vim-vsnip' } },
        { complete_items = { 'path' }, triggered_only = { '/' } },
        { mode           = '<c-p>' },
        { mode           = '<c-n>' }
    },
    vimwiki = {},
    markdown = {
        { complete_items = { 'path' }, triggered_only = { '/' } },
        { complete_items = { 'vim-vsnip' } },
        { mode = '<c-p>' },
        { mode = '<c-n>' }
    },
    string = {
        { complete_items = { 'path' }, triggered_only = { '/' } },
    },
    comment = {}
}
--- completion attach
local custom_attach = function() require('completion').on_attach() end


-- nvim-lspconfig
local lspconfig = require('lspconfig')
local init_lsp_option = require('core/opt').lsp or {}
--- clangd
if init_lsp_option.clangd then
    lspconfig.clangd.setup { on_attach = custom_attach }
end
--- jedi_language_server
if init_lsp_option.jedi_language_server then
    lspconfig.jedi_language_server.setup { on_attach = custom_attach }
end
--- rls
if init_lsp_option.rls then
    lspconfig.rls.setup { on_attach = custom_attach }
end
--- rust_analyzer
if init_lsp_option.rust_analyzer then
    lspconfig.rust_analyzer.setup { on_attach = custom_attach }
end
--- texlab
if init_lsp_option.texlab then
    lspconfig.texlab.setup { on_attach = custom_attach }
end
--- omnisharp
if init_lsp_option.omnisharp then
    local pid = vim.fn.getpid()
    lspconfig.omnisharp.setup {
        cmd = { "OmniSharp", "--languageserver" , "--hostPID", tostring(pid) };
        on_attach = custom_attach
    }
end
--- sumneko_lua
if init_lsp_option.sumneko_lua and init_lsp_option.sumneko_lua.enable then
    local system_name, sumneko_root_path
    if vim.fn.has("mac") == 1 then
        system_name = "macOS"
        sumneko_root_path = "path"
    elseif vim.fn.has("unix") == 1 then
        system_name = "Linux"
        sumneko_root_path = vim.fn.expand(
        init_lsp_option.sumneko_lua.path or
        "~/.local/bin/lua-language-server")
    elseif vim.fn.has('win32') == 1 then
        system_name = "Windows"
        sumneko_root_path = vim.fn.expand(
        init_lsp_option.sumneko_lua.path or
        "D:/Env/LSP/lua-language-server")
    else
        print("Unsupported system for sumneko.")
    end
    local sumneko_binary = sumneko_root_path..
    "/bin/"..system_name.."/lua-language-server"
    lspconfig.sumneko_lua.setup {
        cmd = { sumneko_binary, '-E', sumneko_root_path.."/main.lua" };
        on_attach = custom_attach,
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = vim.split(package.path, ';'),
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = {
                        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    },
                },
            },
        },
    }
end
--- vim script
if init_lsp_option.vimls then
    lspconfig.vimls.setup { on_attach = custom_attach }
end
--- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics,
{ virtual_text = true, signs = true, update_in_insert = false })


-- treesitter
local ts_option = require("core/opt").ts or {}
require('nvim-treesitter.configs').setup {
    ensure_installed = ts_option.ensure or { "c" },
    highlight = {
        enable = true,
        disable = ts_option.hi_disable or {}
    },
}
