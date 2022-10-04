local kbd = vim.keymap.set

require("aerial").setup {
    backends = {
        ["_"] = { "lsp", "treesitter" },
        markdown = { "markdown" }
    },
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
    on_attach = function(bufnr)
        local _o = { noremap = true, silent = true, buffer = bufnr }
        kbd("n", "{", "<Cmd>AerialPrev<CR>", _o)
        kbd("n", "}", "<Cmd>AerialNext<CR>", _o)
        kbd("n", "[[", "<Cmd>AerialPrevUp<CR>", _o)
        kbd("n", "]]", "<Cmd>AerialNextUp<CR>", _o)
        kbd("n", "<leader>mv", "<Cmd>AerialToggle!<CR>", _o)
        kbd("n", "<leader>fa", "<Cmd>Telescope aerial<CR>", _o)
    end
}

-- Telescope load aerial.
require("telescope").load_extension("aerial")
