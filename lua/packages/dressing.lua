require('dressing').setup {
    input = {
        default_prompt = "> ",
        insert_only = false,
        anchor = "SW",
        relative = "cursor",
        row = 0,
        col = 0,
        border = "rounded",
        prefer_width = 40,
        max_width = nil,
        min_width = 20,
        winblend = 10,
        winhighlight = "",
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
