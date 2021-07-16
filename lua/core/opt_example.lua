return {
    dep = {
        --sh = 'zsh',
        --cc = 'clang',
        --py3 = '/usr/bin/python3',
    },
    path = {
        home = nil,
        cloud = nil,
        desktop = nil,
    },
    tui = {
        --bg = 'dark',
        --theme = '',
    },
    gui = {
        font_half = 'Consolas',
        font_full = '黑体',
        font_size = 12,
        --bg = 'light',
    },
    lsp = {
        clangd = false,
        jedi_language_server = false,
        pyright = false,
        omnisharp = false,
        rls = false,
        rust_analyzer = false,
        sumneko_lua = {
            enable = false,
            path = nil
        },
        texlab = false,
        vimls = false,
    },
    ts = {
        ensure = { "c", "rust", "python", "lua" },
        --hi_disable = { "c" },
    },
    plug = {
        matchit = true,
        matchparen = true,
    }
}
