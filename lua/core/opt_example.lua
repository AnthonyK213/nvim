return {
    --sh  = 'zsh',
    --cc  = 'clang',
    --py3 = '/usr/bin/python3',
    --bg  = 'dark',
    --[[
    gui = {
        font_family = 'Consolas',
        font_size = 12,
        bg = 'light'
    },
    ]]
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
    },
    ]]
    --[[
    ts = {
        ensure = { "c", "rust", "python", "lua" },
        hi_disable = { "c" }
    }
    ]]
}
