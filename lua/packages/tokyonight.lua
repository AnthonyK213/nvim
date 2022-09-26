vim.cmd [[packadd tokyonight.nvim]]

require("tokyonight").setup {
    style = _my_core_opt.tui.style or "storm",
    transparent = _my_core_opt.tui.transparent,
    styles = {
        comments = "italic",
        keywords = "NONE",
        functions = "NONE",
        variables = "NONE",
        sidebars = "dark",
        floats = "dark",
    },
    sidebars = {
        "help", "qf", "terminal",
        "aerial", "packer",
    }
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
vim.cmd.colorscheme("tokyonight")
