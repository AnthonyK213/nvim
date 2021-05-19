local core_opt = require('core/opt')


-- Built-in plugins.
if core_opt.plug then
    if not core_opt.plug.matchit then vim.g.loaded_matchit = 1 end
    if not core_opt.plug.matchparen then vim.g.loaded_matchparen = 1 end
end


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


-- indent-blankline.nvim
vim.g.indent_blankline_char_list = { '¦' }
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_buftype_exclude = {
    'terminal', 'NvimTree'
}


-- vimwiki
vim.g.vimwiki_list = {{
    path = vim.fn.expand(vim.g.path_cloud.."/Documents/Agenda/"),
    path_html = vim.fn.expand(vim.g.path_cloud.."/Documents/Agenda/html/"),
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
    vim.g.vsnip_snippet_dir = vim.fn.expand('$LOCALAPPDATA/nvim/snippet')
elseif vim.fn.has('unix') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$HOME/.config/nvim/snippet')
end


-- nvim-compe
require('compe').setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 2,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
        nvim_lua = true,
        vsnip = true,
        calc = false,
    }
}


-- nvim-lspconfig
local lspconfig = require('lspconfig')
local lsp_option = require('core/opt').lsp or {}
--- clangd
if lsp_option.clangd then
    lspconfig.clangd.setup {}
end
--- jedi_language_server
if lsp_option.jedi_language_server then
    lspconfig.jedi_language_server.setup {}
end
--- rls
if lsp_option.rls then
    lspconfig.rls.setup {}
end
--- rust_analyzer
if lsp_option.rust_analyzer then
    lspconfig.rust_analyzer.setup {}
end
--- texlab
if lsp_option.texlab then
    lspconfig.texlab.setup {}
end
--- omnisharp
if lsp_option.omnisharp then
    local pid = vim.fn.getpid()
    lspconfig.omnisharp.setup {
        cmd = { "OmniSharp", "--languageserver" , "--hostPID", tostring(pid) };
    }
end
--- sumneko_lua
if lsp_option.sumneko_lua and lsp_option.sumneko_lua.enable then
    local system_name, sumneko_root_path
    if vim.fn.has("mac") == 1 then
        system_name = "macOS"
        sumneko_root_path = "path"
    elseif vim.fn.has("unix") == 1 then
        system_name = "Linux"
        sumneko_root_path = vim.fn.expand(
        lsp_option.sumneko_lua.path or
        "~/.local/bin/lua-language-server")
    elseif vim.fn.has('win32') == 1 then
        system_name = "Windows"
        sumneko_root_path = vim.fn.expand(
        lsp_option.sumneko_lua.path or
        "D:/Env/LSP/lua-language-server")
    else
        print("Unsupported system for sumneko.")
    end
    local sumneko_binary = sumneko_root_path..
    "/bin/"..system_name.."/lua-language-server"
    lspconfig.sumneko_lua.setup {
        cmd = { sumneko_binary, '-E', sumneko_root_path.."/main.lua" };
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
if lsp_option.vimls then
    lspconfig.vimls.setup {}
end
--- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics,
{ virtual_text = true, signs = true, update_in_insert = false })


-- treesitter
local ts_option = require("core/opt").ts or {}
require('nvim-treesitter.configs').setup {
    ensure_installed = ts_option.ensure or {},
    highlight = {
        enable = true,
        disable = ts_option.hi_disable or {}
    },
}
