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

-- Extend theme highlight.
local function set_hi(group, fg, bg, attr)
    local cmd = "highlight! "..group
    if fg then cmd = cmd.." guifg="..fg end
    if bg then cmd = cmd.." guibg="..bg end
    if attr then cmd = cmd.." gui="..attr end
    vim.cmd(cmd)
end

function M.ui_hi_extend()
    set_hi('SpellBad',         '#f07178', nil, 'underline')
    set_hi('SpellCap',         '#ffcc00', nil, 'underline')
    set_hi('mkdBold',          '#474747', nil, nil)
    set_hi('mkdItalic',        '#474747', nil, nil)
    set_hi('mkdBoldItalic',    '#474747', nil, nil)
    set_hi('mkdCodeDelimiter', '#474747', nil, nil)
    set_hi('htmlBold',         '#ffcc00', nil, 'bold')
    set_hi('htmlItalic',       '#c792ea', nil, 'italic')
    set_hi('htmlBoldItalic',   '#ffcb6b', nil, 'bold,italic')
    set_hi('htmlH1',           '#f07178', nil, 'bold')
    set_hi('htmlH2',           '#f07178', nil, 'bold')
    set_hi('htmlH3',           '#f07178', nil, nil)
    set_hi('mkdHeading',       '#f07178', nil, nil)
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
function M.lualine_setup()
    require('lualine').setup {
        options = {
            theme = 'material-nvim',
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
        extensions = {'nvim-tree'}
    }
end

--- Execute when load one-nvim.
function M.ui_refresh()
    M.ui_hi_extend()
end


return M
