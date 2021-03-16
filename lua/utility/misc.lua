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


return misc
