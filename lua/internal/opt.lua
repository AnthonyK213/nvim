local lib = require("utility.lib")

-- Source basics.vim
lib.vim_source("viml/basics")

local os_this = lib.get_os_type()

local opt = {
    dep = {
        sh = ({
            [lib.Os.Linux] = "bash",
            [lib.Os.Windows] = { "powershell.exe", "-nologo" },
            [lib.Os.Macos] = "zsh"
        })[os_this],
        cc = "gcc",
        py3 = "/usr/bin/python3",
        start = ({
            [lib.Os.Linux] = "xdg-open",
            [lib.Os.Windows] = {"cmd", "/c", "start", '""'},
            [lib.Os.Macos] = "open"
        })[os_this],
        proxy = nil,
    },
    path = {
        home = vim.env.HOME,
        cloud = vim.env.ONEDRIVE or vim.env.HOME,
        desktop = vim.fs.normalize(vim.env.HOME.."/Desktop"),
        bin = vim.fs.normalize(vim.env.HOME.."/bin"),
    },
    tui = {
        scheme = "onedark",
        theme = "dark",
        style = "dark",
        transparent = false,
        global_statusline = false,
        border = "none",
        cmp_ghost = false,
    },
    gui = {
        theme = "auto",
        opacity = 0.98,
        ligature = false,
        popup_menu = false,
        tabline = false,
        scroll_bar = false,
        line_space = 0.0,
        font_size = 13,
        font_half = "Monospace",
        font_full = "Monospace",
    },
    lsp = {
        clangd = false,
        jedi_language_server = false,
        omnisharp = false,
        powershell_es = false,
        pyright = false,
        rust_analyzer = false,
        sumneko_lua = false,
        texlab = false,
        vimls = false,
    },
    ts = {
        ensure = {},
        hi_disable = {},
    },
    dap = {
        python = false,
        csharp = false
    },
    plug = {
        matchit = false,
        matchparen = false,
    }
}

-- Merge custom options.
local exists, opt_file = lib.get_nvimrc()
if exists and opt_file then
    local f = io.open(opt_file)
    if f then
        local ok, result = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if ok then
            opt = vim.tbl_deep_extend("force", opt, result)
        else
            vim.notify("Invalid option file", vim.log.levels.WARN, nil)
        end
    end
end

---Set global variables according to a table.
---@param tbl table Table of configurations.
---@param prefix string Prefix for the global variable.
local function tbl_set_var(tbl, prefix)
    for k, v in pairs(tbl) do
        vim.api.nvim_set_var(prefix..k, v)
    end
end

-- Path
tbl_set_var(opt.path, "_my_path_")

-- GUI
tbl_set_var(opt.gui, "_my_gui_")

-- Misc
vim.g.mapleader = " "
vim.g.python3_host_prog = opt.dep.py3
vim.g.markdown_fenced_languages = {
    "c", "cpp", "cs", "rust", "lua", "vim", "python", "lisp", "tex",
    "javascript", "typescript", "json", "cmake", "sh", "ps1", "dosbatch",
    "ruby", "java", "go", "perl", "html", "xml", "toml", "yaml",
    "config", "gitconfig", "sshconfig", "dosini"
}

-- Directional operation which won't break the history.
local rep_term = vim.api.nvim_replace_termcodes
vim.g._const_dir_l = rep_term("<C-G>U<Left>",  true, false, true)
vim.g._const_dir_d = rep_term("<C-G>U<Down>",  true, false, true)
vim.g._const_dir_u = rep_term("<C-G>U<Up>",    true, false, true)
vim.g._const_dir_r = rep_term("<C-G>U<Right>", true, false, true)

--[[Box Drawing
┌┬─┐┍┯━┑┎┰─┒┏┳━┓╭┬─╮╒╤═╕╓╥─╖╔╦═╗
├┼─┤┝┿━┥┠╂─┨┣╋━┫├┼─┤╞╪═╡╟╫─╢╠╬═╣
││ │││ │┃┃ ┃┃┃ ┃││ │││ │║║ ║║║ ║
└┴─┘┕┷━┙┖┸─┚┗┻━┛╰┴─╯╘╧═╛╙╨─╜╚╩═╝
]]

_G._my_core_opt = opt
