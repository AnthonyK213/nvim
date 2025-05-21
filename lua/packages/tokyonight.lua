require("tokyonight").setup {
  style = _G._my_core_opt.tui.style or "storm",
  transparent = _G._my_core_opt.tui.transparent,
  styles = {
    comments  = { italic = false },
    keywords  = { italic = false },
    functions = {},
    variables = {},
    sidebars  = "dark",
    floats    = "dark",
  },
  sidebars = { "help", "qf", "terminal", "aerial" },
  dim_inactive = _G._my_core_opt.tui.auto_dim,
}

require("utility.util")
    .auto_hl("tokyonight", _G._my_core_opt.hl, _G._my_core_opt.hl_link, function()
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
vim.cmd.colorscheme("tokyonight")
