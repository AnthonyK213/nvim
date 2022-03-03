require('dressing').setup {
    input = {
        default_prompt = "> ",
        insert_only = true,
        anchor = "SW",
        relative = "cursor",
        border = "rounded",
        winblend = 10,
        winhighlight = "NormalFloat:Normal",
        get_config = nil,
    },
    select = {
        backend = { "telescope" },
        telescope = {
            theme = "dropdown",
        },
        format_item_override = {},
        get_config = nil,
    },
}
