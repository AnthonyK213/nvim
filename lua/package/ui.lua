vim.o.tgc = true
vim.o.bg = 'dark'


-- vim-one
vim.cmd('packadd vim-one')
local one_h = function(...) vim.call('one#highlight', ...) end
function UI_ONE_EXTEND()
    one_h('SpellBad',         'e06c75', '', 'underline')
    one_h('SpellCap',         'd19a66', '', 'underline')
    one_h('mkdBold',          '4b5263', '', '')
    one_h('mkdItalic',        '4b5263', '', '')
    one_h('mkdBoldItalic',    '4b5263', '', '')
    one_h('mkdCodeDelimiter', '4b5263', '', '')
    one_h('htmlBold',         'd19a66', '', 'bold')
    one_h('htmlItalic',       'c678dd', '', 'italic')
    one_h('htmlBoldItalic',   'e5c07b', '', 'bold,italic')
    one_h('htmlH1',           'e06c75', '', 'bold')
    one_h('htmlH2',           'e06c75', '', 'bold')
    one_h('htmlH3',           'e06c75', '', '')
    one_h('mkdHeading',       'e06c75', '', '')
    one_h('diffChanged',      'd19a66', '', '')
end
-- When colorscheme set to vim-one.
vim.cmd('augroup vim_one_extend')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua UI_ONE_EXTEND()')
vim.cmd('augroup end')
vim.g.one_allow_italics = 1
vim.cmd('colorscheme one')


-- lualine.nvim
local mode_alias = {
    c      = 'C',
    i      = 'I',
    ic     = 'I',
    ix     = 'I',
    n      = 'N',
    multi  = 'M',
    niI    = 'Ĩ',
    no     = 'N',
    R      = 'R',
    Rv     = 'R',
    s      = 'S',
    S      = 'S',
    t      = 'T',
    v      = 'v',
    V      = 'V',
    [''] = 'B',
}
--- If file is readonly.
local function file_readonly()
    if vim.bo.filetype == 'help' then return '' end
    if vim.bo.readonly == true then return 'RO' end
    return ''
end
--- Current mode.
local function get_current_mode()
    if mode_alias[vim.fn.mode(1)] ~= nil then
        return mode_alias[vim.fn.mode(1)]
    else
        return '_'
    end
end
--- Get diagnostics
local function get_diagnostics()
    local e_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local w_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    local e_str, w_str = '', ''
    if e_count ~= 0 then e_str = ' E:'..tostring(e_count) end
    if w_count ~= 0 then w_str = ' W:'..tostring(w_count) end
    return e_str..w_str
end
--- Load status line.
vim.cmd('packadd lualine.nvim')
local lualine = require('lualine')
lualine.options = {
    theme = 'one'..vim.o.bg,
    separator = '|',
    icons_enabled = false
}
lualine.sections = {
    lualine_a = { get_current_mode },
    lualine_b = { { 'branch', icons_enabled=true }, { 'signify', colored=false } },
    lualine_c = { { 'filename', shorten=false, full_path=true }, file_readonly },
    lualine_x = { get_diagnostics, 'filetype', 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
}
lualine.inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {  },
    lualine_z = {  },
}
lualine.extensions = { 'fzf' }
lualine.status()
vim.cmd('augroup lualine_color_toggle')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua require("lualine").options.theme="one"..vim.o.bg')
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
        diagnostics_indicator = function(count, level) return "("..count..")" end,
        show_buffer_close_icons = true,
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
