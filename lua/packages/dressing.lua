local border_style = _my_core_opt.tui.border
local border_styles = {
    single = {
        prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
    double = {
        prompt = { "═", "║", " ", "║", "╔", "╗", "║", "║" },
        results = { "═", "║", "═", "║", "╠", "╣", "╝", "╚" },
        preview = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
    },
    rounded = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
}

require("dressing").setup {
    input = {
        default_prompt = "> ",
        insert_only = true,
        anchor = "SW",
        relative = "cursor",
        border = _my_core_opt.tui.border,
        winblend = 10,
        winhighlight = "NormalFloat:Normal",
        get_config = nil,
    },
    select = {
        backend = { "telescope" },
        format_item_override = {},
        telescope = require("telescope.themes").get_dropdown {
            border = border_style ~= "none",
            borderchars = border_styles[border_style] or border_styles["rounded"],
        },
        get_config = nil,
    },
}
