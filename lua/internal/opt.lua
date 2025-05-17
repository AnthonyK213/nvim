local lib = require("utility.lib")

-- Source basics.vim
lib.vim_source("viml/basics")

local os_this = lib.get_os_type()

local opt = {
  general = {
    offline = false,
    ---@type string?
    proxy   = nil,
    shell   = ({
      [lib.OS.Linux]   = "bash",
      [lib.OS.Windows] = { "powershell.exe", "-nologo" },
      [lib.OS.MacOS]   = "zsh"
    })[os_this],
    upgrade = false,
  },
  path = {
    home    = vim.env.HOME,
    desktop = vim.fs.joinpath(vim.env.HOME, "Desktop"),
    vimwiki = vim.fs.joinpath(vim.env.HOME, "vimwiki"),
  },
  tui = {
    scheme            = "onedark",
    theme             = "dark",
    style             = "dark",
    transparent       = false,
    global_statusline = false,
    border            = "none",
    cmp_ghost         = false,
    auto_dim          = false,
    animation         = false,
    show_context      = false,
    devicons          = false,
    bufferline_style  = { "▕", "▕" },
    welcome_header    = {
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
    theme        = "auto",
    opacity      = 1.0,
    ligature     = false,
    popup_menu   = false,
    tabline      = false,
    scroll_bar   = false,
    line_space   = 0.0,
    font_size    = 13,
    font_half    = "Monospace",
    font_wide    = "Monospace",
    cursor_blink = false,
  },
  lsp = {},
  ts = {
    ensure_installed  = {},
    highlight_disable = {},
    matchup_disable   = {},
  },
  dap = {},
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
    lib.warn("Invalid option file")
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
vim.g.markdown_fenced_languages = {
  "c", "cpp", "cs", "rust", "lua", "vim", "python", "lisp", "tex",
  "javascript", "typescript", "json", "cmake", "sh", "ps1", "dosbatch",
  "ruby", "java", "go", "perl", "html", "xml", "toml", "yaml",
  "config", "gitconfig", "sshconfig", "dosini"
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

--[=[
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
            lib.warn("Invalid expression for key `" .. k .. "`")
          end
        end
      elseif t == "table" then
        _eval(v)
      end
    end
  end
end

_eval(opt)
]=]

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
  ["@markup.heading.1.marker.markdown"] = "markdownH1",
  ["@markup.heading.2.marker.markdown"] = "markdownH2",
  ["@markup.heading.3.marker.markdown"] = "markdownH3",
  ["@markup.heading.4.marker.markdown"] = "markdownH4",
  ["@markup.heading.5.marker.markdown"] = "markdownH5",
  ["@markup.heading.6.marker.markdown"] = "markdownH6",
  ["@markup.heading.1.markdown"] = "markdownH1",
  ["@markup.heading.2.markdown"] = "markdownH2",
  ["@markup.heading.3.markdown"] = "markdownH3",
  ["@markup.heading.4.markdown"] = "markdownH4",
  ["@markup.heading.5.markdown"] = "markdownH5",
  ["@markup.heading.6.markdown"] = "markdownH6",
  ["@markup.strong.markdown_inline"] = "markdownBold",
  ["@markup.italic.markdown_inline"] = "markdownItalic",
  ["@markup.raw.markdown_inline"] = "markdownCode",
  ["@markup.link.url.markdown_inline"] = "markdownUrl",
  ["@markup.list.markdown"] = "markdownListMarker",
  ["@markup.raw.delimiter.markdown_inline"] = "markdownCodeDelimiter",
  ["@markup.raw.delimiter.markdown"] = "markdownCodeDelimiter",
  ["@string.escape.markdown_inline"] = "markdownEscape",
  ["@markup.link.markdown_inline"] = "markdownLinkText",
  ["@markup.link.label.markdown_inline"] = "markdownLinkText",
  ["@markup.raw.block.markdown"] = "markdownCode",
  ["@label.markdown"] = "markdownCodeDelimiter",
  ["@conceal.markdown_inline"] = "markdownCodeDelimiter",
  --#endregion
}

---Find executable. If not found, return the first element in `exe_list`.
---@param exe_list string[]
---@return string
local function _find_exe(exe_list)
  for _, exe in ipairs(exe_list) do
    if vim.fn.executable(exe) == 1 then
      return exe
    end
  end
  return exe_list[1]
end

-- Executable.
opt.dep = {
  cc  = _find_exe { "clang", "gcc" },
  cxx = _find_exe { "clang++", "g++" },
  py  = _find_exe { "python3", "python" }
}

_G._my_core_opt = opt

-- Filetype.
vim.filetype.add {
  filename = {
    ["_nvimrc"] = "json",
    [".nvimrc"] = "json",
  },
  extension = {
    markdown = "vimwiki.markdown",
    urdf = "xml",
    vert = "glsl",
    frag = "glsl",
  }
}
