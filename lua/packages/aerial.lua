local keymap = vim.api.nvim_buf_set_keymap
local ntst = { noremap = true, silent = true }

require'aerial'.setup {
    backends = { "lsp", "treesitter", "markdown" },
    close_behavior = 'close',
    manage_folds = false,
    on_attach = function (bufnr)
        keymap(bufnr, 'n', '<leader>mv', '<Cmd>AerialToggle!<CR>', ntst)
        keymap(bufnr, 'n', '{', '<Cmd>AerialPrev<CR>', ntst)
        keymap(bufnr, 'n', '}', '<Cmd>AerialNext<CR>', ntst)
        keymap(bufnr, 'n', '[[', '<Cmd>AerialPrevUp<CR>', ntst)
        keymap(bufnr, 'n', ']]', '<Cmd>AerialNextUp<CR>', ntst)
        keymap(bufnr, 'n', '<leader>fa', '<Cmd>Telescope aerial<CR>', ntst)
    end
}

-- Telescope load aerial.
require('telescope').load_extension('aerial')
