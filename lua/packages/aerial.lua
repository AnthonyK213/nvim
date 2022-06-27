local kbd = vim.keymap.set

require("aerial").setup {
    backends = {
        ["_"] = { "lsp", "treesitter" },
        markdown = { "markdown" }
    },
    close_behavior = "auto",
    manage_folds = false,
    filter_kind = {
        ["_"] = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
        },
        lua = {
            "Function",
            "Method",
        },
    },
    highlight_closest = false,
    on_attach = function (bufnr)
        local _opt = { noremap = true, silent = true, buffer = bufnr }
        kbd("n", "{", "<Cmd>AerialPrev<CR>", _opt)
        kbd("n", "}", "<Cmd>AerialNext<CR>", _opt)
        kbd("n", "[[", "<Cmd>AerialPrevUp<CR>", _opt)
        kbd("n", "]]", "<Cmd>AerialNextUp<CR>", _opt)
        kbd("n", "<leader>mv", "<Cmd>AerialToggle!<CR>", _opt)
        kbd("n", "<leader>fa", "<Cmd>Telescope aerial<CR>", _opt)
    end
}

-- Telescope load aerial.
require("telescope").load_extension("aerial")
