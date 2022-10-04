vim.cmd.packadd("onedark.nvim")

local style_list = {
    "dark", "darker", "cool",
    "deep", "warm", "warmer",
    "light"
}
local opt_style = _my_core_opt.tui.style

require("onedark").setup {
    style = vim.tbl_contains(style_list, opt_style) and opt_style or "dark",
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

vim.g._my_theme_switchable = true
require("onedark").load()
