local augroup = require("utility/lib").set_augroup


-- colorscheme
vim.cmd('packadd tokyonight.nvim')
vim.g.tokyonight_style = require('core/opt').tui.theme or 'storm'
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_sidebars = { "qf", "terminal" }


-- lualine.nvim
vim.cmd('packadd lualine.nvim')
local mode_alias = {
    i = 'I', ic  = 'I', ix     = 'I',
    v = 'v', V   = 'V', [''] = 'B',
    n = 'N', niI = 'Ĩ', no     = 'N',
    R = 'R', Rv = 'R',
    s = 's', S  = 'S',
    c = 'C', t  = 'T',
    multi = 'M',
}
require('lualine').setup {
    options = {
        theme = 'tokyonight',
        section_separators = '',
        component_separators = '',
        icons_enabled = false
    },
    sections = {
        lualine_a = {function()
            return mode_alias[vim.api.nvim_get_mode().mode] or '_'
        end},
        lualine_b = {'branch'},
        lualine_c = {{'filename', path=2}, 'diff'},
        lualine_x = {{'diagnostics', sources={'nvim_lsp'}}, 'filetype'},
        lualine_y = {'encoding', 'fileformat'},
        lualine_z = {'progress', 'location'},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {},
    },
    extensions = {'nvim-tree', 'quickfix'}
}


-- nvim-bufferline.lua
vim.cmd('packadd bufferline.nvim')
require('bufferline').setup {
    options = {
        buffer_close_icon= '×',
        modified_icon = '+',
        close_icon = '×',
        left_trunc_marker = '<',
        right_trunc_marker = '>',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,

        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count) return "("..count..")" end,

        custom_filter = function(buf_number)
            local bt = vim.bo[buf_number].bt
            if (bt ~= 'terminal' and
                bt ~= 'quickfix') then
                return true
            end
        end,

        show_buffer_icons = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = 'extension'
    }
}
vim.api.nvim_set_keymap('n', '<leader>bb', '<cmd>BufferLinePick<CR>', { noremap = true, silent = true })


-- nvim-colorizer
vim.cmd('packadd nvim-colorizer.lua')
require('colorizer').setup()
vim.cmd('command! ColorizerReset lua package.loaded["colorizer"] = nil require("colorizer").setup() require("colorizer").attach_to_buffer(0)')


-- Setting colorscheme.
augroup('highlight_extend', 'ColorScheme * lua require("utility/vis").hi_extd()')
vim.cmd[[colorscheme tokyonight]]
