local kbd_b = vim.api.nvim_buf_set_keymap
local ntst = { noremap = true, silent = true }

require('aerial').setup {
    backends = {
        ['_'] = { "lsp", "treesitter" },
        markdown = { 'markdown' }
    },
    close_behavior = 'auto',
    manage_folds = false,
    filter_kind = {
        ['_'] = {
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
        kbd_b(bufnr, 'n', '{',          '<Cmd>AerialPrev<CR>', ntst)
        kbd_b(bufnr, 'n', '}',          '<Cmd>AerialNext<CR>', ntst)
        kbd_b(bufnr, 'n', '[[',         '<Cmd>AerialPrevUp<CR>', ntst)
        kbd_b(bufnr, 'n', ']]',         '<Cmd>AerialNextUp<CR>', ntst)
        kbd_b(bufnr, 'n', '<leader>mv', '<Cmd>AerialToggle!<CR>', ntst)
        kbd_b(bufnr, 'n', '<leader>fa', '<Cmd>Telescope aerial<CR>', ntst)
    end
}

-- Telescope load aerial.
require('telescope').load_extension('aerial')
