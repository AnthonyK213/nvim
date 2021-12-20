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
        bin = nil,
    },
    tui = {
        --bg = 'dark',
        --theme = '',
    },
    gui = {
        font_half = 'Consolas',
        font_full = 'Microsoft Yahei',
        font_size = 12,
        --bg = 'light',
        --opacity = 0.96,
    },
    lsp = {
        clangd = false,
        jedi_language_server = false,
        powershell_es = {
            enable = false,
            path = nil
        },
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
        ensure = { "c" },
        --hi_disable = { "c" },
    },
    plug = {
        matchit = false,
        matchparen = false,
    }
}
