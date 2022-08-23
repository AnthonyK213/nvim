vim.cmd [[packadd tokyonight.nvim]]

vim.g.tokyonight_style = _my_core_opt.tui.style or "storm"
vim.g.tokyonight_transparent = _my_core_opt.tui.transparent
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_sidebars = {
    "help", "qf", "terminal",
    "aerial", "packer",
}

require("utility.util").auto_hl("tokyonight", _my_core_opt.hl, function ()
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
vim.cmd [[colorscheme tokyonight]]
