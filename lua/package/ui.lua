vim.o.tgc = true
local augroup = require("utility/lib").set_au_group


-- one-nvim
vim.cmd('packadd one-nvim')
vim.g.one_nvim_transparent_bg = false


-- lualine.nvim
vim.cmd('packadd lualine.nvim')


-- nvim-bufferline.lua
vim.cmd('packadd nvim-bufferline.lua')
require('bufferline').setup {
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


-- Load color scheme.
augroup('one_ui_setup',
'ColorScheme one-nvim lua local misc = require("package/misc") '
..'misc.ui_one_extend() '
..'misc.lualine_setup() '
..'misc.indent_guides_color_toggle()')
vim.cmd('colorscheme one-nvim')
