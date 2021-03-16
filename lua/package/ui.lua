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
--- Load status line.
vim.cmd('packadd lualine.nvim')
local lualine = require('lualine')
lualine.options = {
    theme = 'one'..vim.o.bg,
    section_separators = nil,
    component_separators = '│',
    icons_enabled = false
}
lualine.sections = {
    lualine_a = { get_current_mode },
    lualine_b = { { 'branch', icons_enabled=true }, { 'diff', colored=true } },
    lualine_c = { { 'filename', shorten=false, full_path=true }, file_readonly },
    lualine_x = { { 'diagnostics', sources={ 'nvim_lsp' } }, 'filetype' },
    lualine_y = { 'encoding', 'fileformat' },
    lualine_z = { 'progress', 'location' },
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
vim.cmd('au ColorSchemePre one lua require("lualine").options.theme="one"..vim.o.bg')
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
