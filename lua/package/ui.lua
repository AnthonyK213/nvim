-- vim-one
vim.cmd('packadd vim-one')
local function one_hl(...)
    vim.call('one#highlight', ...)
end
function uiconf_lua_one_extend()
    one_hl('SpellBad',         'e06c75', '', 'underline')
    one_hl('SpellCap',         'd19a66', '', 'underline')
    one_hl('mkdBold',          '4b5263', '', '')
    one_hl('mkdItalic',        '4b5263', '', '')
    one_hl('mkdBoldItalic',    '4b5263', '', '')
    one_hl('mkdCodeDelimiter', '4b5263', '', '')
    one_hl('htmlBold',         'd19a66', '', 'bold')
    one_hl('htmlItalic',       'c678dd', '', 'italic')
    one_hl('htmlBoldItalic',   'e5c07b', '', 'bold,italic')
    one_hl('htmlH1',           'e06c75', '', 'bold')
    one_hl('htmlH2',           'e06c75', '', 'bold')
    one_hl('htmlH3',           'e06c75', '', '')
    one_hl('mkdHeading',       'e06c75', '', '')
end
-- When colorscheme set to vim-one.
vim.cmd('augroup vim_one_extend')
vim.cmd('autocmd!')
vim.cmd('au ColorScheme one lua uiconf_lua_one_extend()')
vim.cmd('augroup end')
vim.o.tgc = true
vim.o.bg = 'dark'
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
    if vim.bo.readonly == true then return ' RO' end
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
--- Current file name.
local function get_current_file_name()
    local file = vim.fn.expand('%:t')
    if vim.fn.empty(file) == 1 then return '' end
    if string.len(file_readonly()) ~= 0 then return file..file_readonly() end
    if vim.bo.modifiable then
        if vim.bo.modified then return file..' MO' end
    end
    return file
end

vim.cmd('packadd lualine.nvim')
local lualine = require('lualine')
lualine.theme = 'onedark'
lualine.separator = '|'
lualine.sections = {
    lualine_a = { get_current_mode },
    lualine_b = { get_current_file_name },
    lualine_c = { 'branch', 'signify' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
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
        diagnostics_indicator = function(count, level)
            return "("..count..")"
        end,
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
