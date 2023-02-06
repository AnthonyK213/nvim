local border_style = _my_core_opt.tui.border
local border_styles = {
    single = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    double = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
    rounded = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-Down>"] = require("telescope.actions").cycle_history_next,
                ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
            },
        },
        border = border_style ~= "none",
        borderchars = border_styles[border_style] or border_styles["rounded"]
    },
    extensions = {
        aerial = {
            show_nesting = {
                ["_"] = false,
                json = true,
                markdown = true,
            }
        }
    }
}

-- Load extensions.
require("telescope").load_extension("aerial")
