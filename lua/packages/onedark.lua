local style_list = {
  "dark", "darker", "cool",
  "deep", "warm", "warmer",
  "light"
}
local opt_style = _my_core_opt.tui.style

require("onedark").setup {
  style = vim.list_contains(style_list, opt_style) and opt_style or "dark",
  transparent = _my_core_opt.tui.transparent,
  term_colors = true,
  ending_tildes = false,
  toggle_style_key = "<leader>bs",
  toggle_style_list = style_list,
  code_style = {
    comments = "italic",
    keywords = "none",
    functions = "none",
    strings = "none",
    variables = "none"
  },
  colors = {},
  highlights = _my_core_opt.hl,
  diagnostics = {
    darker = true,
    undercurl = true,
    background = true,
  },
}

require("utility.util").auto_hl("onedark", nil, _my_core_opt.hl_link, function()
  return {
    red = vim.g.terminal_color_1,
    green = vim.g.terminal_color_2,
    yellow = vim.g.terminal_color_3,
    blue = vim.g.terminal_color_4,
    purple = vim.g.terminal_color_5,
    cyan = vim.g.terminal_color_6,
    light_grey = vim.g.terminal_color_7,
    bg3 = vim.g.terminal_color_8
  }
end)

vim.g._my_theme_switchable = true
require("onedark").load()
