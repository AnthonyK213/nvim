local M = {}


--- Toggle math display.
function M.vim_markdown_math_toggle()
    vim.g.vim_markdown_math = 1 - vim.g.vim_markdown_math
    vim.fn.execute('syn off | syn on')
end

-- Toc
function M.toc_of_md_tex()
    if vim.bo.filetype == 'markdown' then
        vim.cmd('Tocv')
        vim.cmd('vertical resize 50')
    elseif vim.bo.filetype == 'tex' then
        vim.cmd('VimtexTocToggle')
    else
        print("Filetype "..vim.bo.filetype.." doesn't support Toc.")
    end
end

-- Extend theme one-nvim.
local function set_hi(group, fg, bg, attr)
    local cmd = "highlight "..group
    if fg then cmd = cmd.." guifg="..fg end
    if bg then cmd = cmd.." guibg="..bg end
    if attr then cmd = cmd.." gui="..attr end
    vim.cmd(cmd)
end

local function one_hi_extend()
    set_hi('SpellBad',         '#e06c75', nil, 'underline')
    set_hi('SpellCap',         '#d19a66', nil, 'underline')
    set_hi('mkdBold',          '#4b5263', nil, nil)
    set_hi('mkdItalic',        '#4b5263', nil, nil)
    set_hi('mkdBoldItalic',    '#4b5263', nil, nil)
    set_hi('mkdCodeDelimiter', '#4b5263', nil, nil)
    set_hi('htmlBold',         '#d19a66', nil, 'bold')
    set_hi('htmlItalic',       '#c678dd', nil, 'italic')
    set_hi('htmlBoldItalic',   '#e5c07b', nil, 'bold,italic')
    set_hi('htmlH1',           '#e06c75', nil, 'bold')
    set_hi('htmlH2',           '#e06c75', nil, 'bold')
    set_hi('htmlH3',           '#e06c75', nil, nil)
    set_hi('mkdHeading',       '#e06c75', nil, nil)
end

-- indent-guides.nvim toggle colors.
local function indent_guides_color_toggle()
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

--- Current mode.
local function get_current_mode()
    if mode_alias[vim.fn.mode(1)] ~= nil then
        return mode_alias[vim.fn.mode(1)]
    else
        return '_'
    end
end

--- lualine setup.
local function lualine_setup()
    require('lualine').setup {
        options = {
            theme = 'one'..vim.o.bg,
            section_separators = '',
            component_separators = '',
            icons_enabled = false
        },
        sections = {
            lualine_a = {get_current_mode},
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
    }
end

--- Execute when load one-nvim.
function M.one_ui_setup()
    one_hi_extend()
    lualine_setup()
    indent_guides_color_toggle()
end


return M
