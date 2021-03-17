vim.o.tgc = true
vim.o.bg = 'dark'


-- vim-one
vim.cmd('packadd vim-one')
vim.g.one_allow_italics = 1
vim.cmd('augroup vim_one_extend')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua require("utility/misc").ui_one_extend()')
vim.cmd('augroup end')


-- lualine.nvim
vim.cmd('packadd lualine.nvim')
vim.cmd('augroup lualine_setup')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua require("utility/misc").lualine_setup()')
vim.cmd('augroup end')


-- nvim-bufferline.lua
vim.cmd('packadd nvim-bufferline.lua')
require'bufferline'.setup {
    options = {
        view = "default",
        numbers = "none",
        number_style = "",
        mappings = false,
        buffer_close_icon= 'x',
        modified_icon = '+',
        close_icon = 'x',
        left_trunc_marker = '<',
        right_trunc_marker = '>',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count) return "("..count..")" end,
        show_buffer_close_icons = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = 'extension'
    }
}


-- nvim-colorizer
vim.cmd('packadd nvim-colorizer.lua')
require('colorizer').setup()


-- indent-guides.nvim
vim.cmd('packadd indent-guides.nvim')
vim.cmd('augroup indent_guides_color_toggle')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua require("utility/misc").indent_guides_color_toggle()')
vim.cmd('augroup end')


-- Load color scheme.
vim.cmd('colorscheme one')
