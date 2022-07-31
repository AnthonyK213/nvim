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
        get_config = nil,
    },
}
