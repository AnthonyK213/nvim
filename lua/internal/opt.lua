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
      [lib.Os.Windows] = { "cmd", "/c", "start", '""' },
      [lib.Os.Macos] = "open"
    })[os_this],
    proxy = nil,
  },
  path = {
    home = vim.env.HOME,
    cloud = vim.env.ONEDRIVE or vim.env.HOME,
    desktop = vim.env.HOME .. "/Desktop",
    bin = vim.env.HOME .. "/bin",
  },
  tui = {
    scheme = "onedark",
    theme = "dark",
    style = "dark",
    transparent = false,
    global_statusline = false,
    border = "none",
    cmp_ghost = false,
    auto_dim = false,
    animation = false,
    show_context = false,
    devicons = false,
    bufferline_style = { "▕", "▕" },
    welcome_header = {
      [[                                                    ]],
      [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
      [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
      [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
      [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
      [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
      [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
      [[                                                    ]],
    },
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
    font_wide = "Monospace",
    cursor_blink = false,
  },
  lsp = {},
  ts = {
    ensure_installed = {},
    highlight_disable = {},
    matchup_disable = {},
  },
  dap = {
    python = false,
    csharp = false
  },
  disable = {
    "matchit",
    "matchparen",
    "netrwPlugin"
  },
}

-- Merge custom options.
local exists, opt_file = lib.get_dotfile("nvimrc")
if exists and opt_file then
  local code, result = lib.json_decode(opt_file)
  if code == 0 then
    opt = vim.tbl_deep_extend("force", opt, result)
  else
    vim.notify("Invalid option file", vim.log.levels.WARN, nil)
  end
end

-- Normalize the paths.
for k, v in pairs(opt.path) do
  opt.path[k] = vim.fs.normalize(v)
end

---Set global variables according to a table.
---@param tbl table Table of configurations.
---@param prefix string Prefix for the global variable.
local function _tbl_set_var(tbl, prefix)
  for k, v in pairs(tbl) do
    vim.api.nvim_set_var(prefix .. k, v)
  end
end

-- Path
_tbl_set_var(opt.path, "_my_path_")

-- GUI
_tbl_set_var(opt.gui, "_my_gui_")

-- Misc
vim.g.mapleader = " "
vim.g.python3_host_prog = opt.dep.py3
vim.g.markdown_fenced_languages = {
  "c", "cpp", "cs", "rust", "lua", "vim", "python", "lisp", "tex",
  "javascript", "typescript", "json", "cmake", "sh", "ps1", "dosbatch",
  "ruby", "java", "go", "perl", "html", "xml", "toml", "yaml",
  "config", "gitconfig", "sshconfig", "dosini"
}

-- Const paths
opt.path.dylib = vim.fn.stdpath("data") .. "/dylib/"

-- Highlights
opt.hl = {
  FloatBorder = { fg = "$cyan" },
  SpellBad = { fg = "$red", sp = "$red", fmt = "underline" },
  SpellCap = { fg = "$yellow", fmt = "underline" },
  Underlined = { sp = "$cyan", fmt = "underline" },
  htmlUnderline = { sp = "$cyan", fmt = "underline" },
  --#region Markdown
  markdownH1 = { fg = "$red", fmt = "bold" },
  markdownH2 = { fg = "$red", fmt = "bold" },
  markdownH3 = { fg = "$red", fmt = "bold" },
  markdownH4 = { fg = "$red" },
  markdownH5 = { fg = "$red" },
  markdownH6 = { fg = "$red" },
  markdownBold = { fg = "$yellow", fmt = "bold" },
  markdownItalic = { fg = "$purple", fmt = "italic" },
  markdownBoldItalic = { fg = "$yellow", fmt = "bold,italic" },
  markdownCode = { fg = "$green" },
  markdownUrl = { fg = "$bg3" },
  markdownEscape = { fg = "$cyan" },
  markdownLinkText = { fg = "$cyan", sp = "$cyan", fmt = "underline" },
  markdownHeadingDelimiter = { fg = "$red" },
  markdownBoldDelimiter = { fg = "$bg3" },
  markdownItalicDelimiter = { fg = "$bg3" },
  markdownBoldItalicDelimiter = { fg = "$bg3" },
  markdownCodeDelimiter = { fg = "$bg3" },
  markdownLinkDelimiter = { fg = "$bg3" },
  markdownLinkTextDelimiter = { fg = "$bg3" },
  markdownListMarker = { fg = "$purple" },
  --#endregion
}

opt.hl_link = {
  --#region Vimwiki
  VimwikiHeader1 = "markdownH1",
  VimwikiHeader2 = "markdownH2",
  VimwikiHeader3 = "markdownH3",
  VimwikiHeader4 = "markdownH4",
  VimwikiHeader5 = "markdownH5",
  VimwikiHeader6 = "markdownH6",
  VimwikiHeaderChar = "markdownHeadingDelimiter",
  VimwikiBold = "markdownBold",
  VimwikiItalic = "markdownItalic",
  VimwikiBoldItalic = "markdownBoldItalic",
  VimwikiUnderline = "Underlined",
  VimwikiCode = "markdownCode",
  VimwikiPre = "markdownCode",
  VimwikiDelimiter = "markdownCodeDelimiter",
  VimwikiListTodo = "markdownListMarker",
  VimwikiWeblink1 = "markdownLinkText",
  --#endregion
  --#region Treesitter: markdown
  ["@text.title.1.marker.markdown"] = "markdownH1",
  ["@text.title.2.marker.markdown"] = "markdownH2",
  ["@text.title.3.marker.markdown"] = "markdownH3",
  ["@text.title.4.marker.markdown"] = "markdownH4",
  ["@text.title.5.marker.markdown"] = "markdownH5",
  ["@text.title.6.marker.markdown"] = "markdownH6",
  ["@text.title.1.markdown"] = "markdownH1",
  ["@text.title.2.markdown"] = "markdownH2",
  ["@text.title.3.markdown"] = "markdownH3",
  ["@text.title.4.markdown"] = "markdownH4",
  ["@text.title.5.markdown"] = "markdownH5",
  ["@text.title.6.markdown"] = "markdownH6",
  ["@text.strong.markdown_inline"] = "markdownBold",
  ["@text.emphasis.markdown_inline"] = "markdownItalic",
  ["@text.literal.markdown_inline"] = "markdownCode",
  ["@text.uri.markdown_inline"] = "markdownUrl",
  ["@punctuation.special.markdown"] = "markdownListMarker",
  ["@punctuation.delimiter.markdown_inline"] = "markdownBoldDelimiter",
  ["@punctuation.delimiter.markdown"] = "markdownCodeDelimiter",
  ["@punctuation.bracket.markdown_inline"] = "markdownLinkDelimiter",
  ["@text.escape.markdown_inline"] = "markdownEscape",
  ["@text.reference.markdown_inline"] = "markdownLinkText",
  ["@text.literal.block.markdown"] = "markdownCode",
  ["@label.markdown"] = "markdownCodeDelimiter",
  --#endregion
}

-- Directional operation which won't break the history.
local rep_term = vim.api.nvim_replace_termcodes
vim.g._const_dir_l = rep_term("<C-G>U<Left>", true, false, true)
vim.g._const_dir_d = rep_term("<C-G>U<Down>", true, false, true)
vim.g._const_dir_u = rep_term("<C-G>U<Up>", true, false, true)
vim.g._const_dir_r = rep_term("<C-G>U<Right>", true, false, true)

--[[Box Drawing
┌┬─┐┍┯━┑┎┰─┒┏┳━┓╭┬─╮╒╤═╕╓╥─╖╔╦═╗
├┼─┤┝┿━┥┠╂─┨┣╋━┫├┼─┤╞╪═╡╟╫─╢╠╬═╣
││ │││ │┃┃ ┃┃┃ ┃││ │││ │║║ ║║║ ║
└┴─┘┕┷━┙┖┸─┚┗┻━┛╰┴─╯╘╧═╛╙╨─╜╚╩═╝
]]

---Evaluate string values in option table.
---@param tbl table
local function _eval(tbl)
  if type(tbl) == "table" then
    for k, v in pairs(tbl) do
      local t = type(v)
      if t == "string" then
        local m = v:match("^%${(.+)}$")
        if m then
          local ok, result = pcall(vim.fn.luaeval, m)
          if ok then
            tbl[k] = result
          else
            vim.notify("Invalid expression for key `" .. k .. "`", vim.log.levels.WARN)
          end
        end
      elseif t == "table" then
        _eval(v)
      end
    end
  end
end

_eval(opt)

_G._my_core_opt = opt

---Filetype.
vim.filetype.add {
  filename = {
    ["_nvimrc"] = "json",
    [".nvimrc"] = "json",
  },
  extension = {
    markdown = "vimwiki.markdown",
    urdf = "xml",
  }
}
