-- GUI options
--vim.g.gui_font_size   = 12
--vim.g.gui_font_family = 'Consolas'
--vim.g.gui_background  = 'dark'

-- Options
INIT_OPTIONS = {
    --sh  = 'zsh',
    --cc  = 'clang',
    --py3 = '/usr/bin/python3',
    --bg  = 'dark',
    --[[
    lsp = {
        -- C, C++
        clangd = false,
        -- C#
        omnisharp = false,
        -- LaTeX
        texlab = false,
        -- Lua
        sumneko_lua = false,
        -- Python
        jedi_language_server = false,
        -- Rust
        rls = false,
        rust_analyzer = false,
        -- Vim script
        vimls = false
    }
    --]]
}


require('core')
