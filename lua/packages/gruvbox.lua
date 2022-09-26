vim.cmd [[packadd gruvbox.nvim]]

require("gruvbox").setup {
    undercurl = true,
    underline = true,
    bold = true,
    italic = false,
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,
    contrast = "soft",
    overrides = {},
}

require("utility.util").auto_hl("gruvbox", vim.tbl_extend("force", {
    EndOfBuffer = { fg = "$bg0", bg = "$bg0" }
}, _my_core_opt.hl), function ()
    return {
        bg0 = vim.g.terminal_color_0,
        red = vim.g.terminal_color_1,
        green = vim.g.terminal_color_2,
        yellow = vim.g.terminal_color_3,
        blue = vim.g.terminal_color_4,
        purple = vim.g.terminal_color_5,
        cyan = vim.g.terminal_color_6,
        light_grey = vim.g.terminal_color_7,
        bg3 = vim.g.terminal_color_8,
    }
end)

vim.g._my_theme_switchable = true
vim.cmd.colorscheme("gruvbox")
