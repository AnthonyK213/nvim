local opt = {
    dep = {
        sh = 'bash',
        cc = 'gcc',
        py3 = '/usr/bin/python3',
        proxy = nil,
    },
    path = {
        home = vim.env.HOME,
        cloud = vim.env.ONEDRIVE or vim.env.HOME,
        desktop = vim.fn.expand(vim.env.HOME..'/Desktop'),
        bin = vim.fn.expand(vim.env.HOME..'/bin'),
    },
    tui = {
        theme = 'dark',
        style = 'dark',
        transparent = false,
    },
    gui = {
        theme = 'auto',
        opacity = 0.98,
        font_size = 13,
        font_half = 'Monospace',
        font_full = 'Monospace',
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
        sumneko_lua = false,
        texlab = false,
        vimls = false,
    },
    ts = {
        ensure = { "c", "lua" },
        hi_disable = {},
    },
    plug = {
        matchit = false,
        matchparen = false,
    }
}

local opt_file = vim.fn.stdpath('config')..'/opt.json'
if require("utility.lib").path_exists(opt_file) then
    local opt_json = table.concat(vim.fn.readfile(opt_file))
    local opt_extd = vim.json.decode(opt_json)
    opt = vim.tbl_deep_extend("force", opt, opt_extd)
end

_G.core_opt = opt
