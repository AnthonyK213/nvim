local misc = {}


-- Run code complete option list.
function RUN_CODE_OPTION()
    local ft = vim.bo.filetype
    if ft == 'c' then
        return {'build', 'check'}
    elseif ft == 'rust' then
        return {'build', 'clean', 'check', 'rustc'}
    elseif ft == 'tex' then
        return {'biber', 'bibtex'}
    else
        return {''}
    end
end

-- Define auto command group.
function misc.set_au_group(name, ...)
    vim.cmd('augroup '..name)
    vim.cmd('autocmd!')
    for _, cmd in ipairs({...}) do
        vim.cmd('au '..cmd)
    end
    vim.cmd('augroup end')
end

--- Toggle math display.
function misc.vim_markdown_math_toggle()
    vim.g.vim_markdown_math = 1 - vim.g.vim_markdown_math
    vim.fn.execute('syn off | syn on')
end

-- Extend theme one.
function misc.ui_one_extend()
    local one_h = function(...) vim.call('one#highlight', ...) end

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
end

-- indent-guides.nvim toggle colors.
function misc.indent_guides_color_toggle()
    local indent = require('indent_guides')
    local green, red
    if vim.o.bg == 'dark' then
        green = '#2a3834'
        red   = '#332b36'
    else
        green = '#e7f4ec'
        red   = '#f4e7ef'
    end

    indent.setup({
        exclude_filetypes = {
            'help',
            'dashboard',
            'dashpreview',
            'NvimTree',
            'vista',
            'sagahover',
        };
        even_colors = { fg=green, bg=red };
        odd_colors  = { fg=red, bg=green };
    })

    indent.indent_guides_enable()
end

-- lualine.nvim setup
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

--- lualine setup.
function misc.lualine_setup()
    require('lualine').setup {
        options = {
            theme = 'one'..vim.o.bg,
            section_separators = nil,
            component_separators = nil,
            icons_enabled = false
        },
        sections = {
            lualine_a = { get_current_mode },
            lualine_b = { 'branch' },
            lualine_c = { file_readonly, { 'filename', full_path=true, shorten=false }, 'diff' },
            lualine_x = { { 'diagnostics', sources={ 'nvim_lsp' } }, 'filetype' },
            lualine_y = { 'encoding', 'fileformat' },
            lualine_z = { 'progress', 'location' },
        },
        inactive_sections = {
            lualine_a = { },
            lualine_b = { },
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = { },
            lualine_z = { },
        },
        extensions = { 'nerdtree' }
    }
end


return misc
