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
vim.cmd('au ColorScheme one call v:lua.uiconf_lua_one_extend()')
vim.cmd('augroup end')
vim.o.bg = 'dark'
vim.g.one_allow_italics = 1
vim.cmd('colorscheme one')


-- galaxyline
vim.cmd('packadd galaxyline.nvim')

-- galaxy-airline
local gl = require('galaxyline')
--- Variables
local gls = gl.section
gl.short_line_list = {'defx', 'packager', 'vista', 'NvimTree'}
local colors = {
    bg         = '#282c34',
    fg         = '#aab2bf',
    section_bg = '#38393f',
    blue       = '#61afef',
    green      = '#98c379',
    purple     = '#c678dd',
    orange     = '#d19a66',
    red1       = '#e06c75',
    red2       = '#be5046',
    yellow     = '#e5c07b',
    gray1      = '#5c6370',
    gray2      = '#2c323d',
    gray3      = '#3e4452',
    darkgrey   = '#5c6370',
    grey       = '#848586',
    middlegrey = '#8791A5'
}
local mode_colors = {
    c      = colors.green,
    i      = colors.blue,
    ic     = colors.blue,
    ix     = colors.blue,
    n      = colors.green,
    niI    = colors.blue,
    no     = colors.green,
    R      = colors.red1,
    Rv     = colors.red1,
    s      = colors.red1,
    S      = colors.red1,
    t      = colors.blue,
    v      = colors.purple,
    V      = colors.purple,
    [''] = colors.purple
}
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
    v      = 'V',
    V      = 'Ṿ',
    [''] = 'Ṽ',
}
--- Functions
--- Check whether the current buffer is empty.
local buffer_not_empty = function()
    if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then return true end
    return false
end
--- Check if the windows width is greater than a given number of columns.
local check_width = function()
    return vim.fn.winwidth(0) / 2 > 40 and buffer_not_empty()
end
--- Mode colors.
local mode_color = function()
    if mode_colors[vim.fn.mode(1)] ~= nil then
        return mode_colors[vim.fn.mode(1)]
    else
        return colors.darkgrey
    end
end
--- If readonly.
local function file_readonly()
    if vim.bo.filetype == 'help' then return '' end
    if vim.bo.readonly == true then return ' RO ' end
    return ''
end
--- Current file name.
local function get_current_file_name()
    local file = vim.fn.expand('%:t')
    if vim.fn.empty(file) == 1 then return '' end
    if string.len(file_readonly()) ~= 0 then return file .. file_readonly() end
    if vim.bo.modifiable then
        if vim.bo.modified then return file .. ' MO ' end
    end
    return file..' '
end
--- Left side
gls.left[1] = {
    ViMode = {
        provider = function()
            vim.api.nvim_command('hi GalaxyViMode guibg='..mode_color())
            if mode_alias[vim.fn.mode(1)] ~= nil then
                return '  '..mode_alias[vim.fn.mode(1)]..' '
            else
                return '  _ '
            end
        end,
        highlight = {colors.bg, colors.section_bg},
    }
}
gls.left[2] = {
    FileType = {
        provider = {
            function() return '  ' end,
            'FileTypeName'
        },
        condition = buffer_not_empty,
        highlight = {colors.orange, colors.section_bg},
        separator = ' ',
        separator_highlight = {colors.section_bg, colors.section_bg}
    }
}
gls.left[3] = {
    FileName = {
        provider  = get_current_file_name,
        condition = buffer_not_empty,
        highlight = {colors.fg, colors.section_bg},
        separator = "",
        separator_highlight = {colors.section_bg, colors.bg}
    }
}
gls.left[9] = {
    DiagnosticError = {
        provider = 'DiagnosticError',
        icon = ' E ',
        highlight = {colors.red1, colors.bg}
    }
}
gls.left[10] = {
    Space = {
        provider = function() return ' ' end,
        highlight = {colors.section_bg, colors.bg}
    }
}
gls.left[11] = {
    DiagnosticWarn = {
        provider = 'DiagnosticWarn',
        icon = ' W ',
        highlight = {colors.yellow, colors.bg}
    }
}
gls.left[12] = {
    Space = {
        provider = function() return ' ' end,
        highlight = {colors.section_bg, colors.bg}
    }
}
gls.left[13] = {
    DiagnosticInfo = {
        provider = 'DiagnosticInfo',
        icon = ' I ',
        highlight = {colors.blue, colors.section_bg},
        separator = ' ',
        separator_highlight = {colors.section_bg, colors.bg}
    }
}
--- Right side
gls.right[1] = {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = check_width,
        icon = '+',
        highlight = {colors.green, colors.bg}
    }
}
gls.right[2] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = check_width,
        icon = '~',
        highlight = {colors.yellow, colors.bg}
    }
}
gls.right[3] = {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = check_width,
        icon = '-',
        highlight = {colors.red1, colors.bg}
    }
}
gls.right[4] = {
    Space = {
        provider = function() return ' ' end,
        highlight = {colors.section_bg, colors.bg}
    }
}
gls.right[5] = {
    GitIcon = {
        provider = function() return '  ' end,
        condition = buffer_not_empty and
        require('galaxyline.provider_vcs').check_git_workspace,
        highlight = {colors.middlegrey, colors.bg}
    }
}
gls.right[6] = {
    GitBranch = {
        provider  = 'GitBranch',
        condition = buffer_not_empty,
        highlight = {colors.middlegrey, colors.bg}
    }
}
gls.right[7] = {
    Space = {
        provider = function() return ' ' end,
        highlight = {colors.section_bg, colors.bg}
    }
}
gls.right[8] = {
    FileFormat = {
        provider  = {
            'FileFormat',
            function() return ' ' end
        },
        condition = buffer_not_empty,
        highlight = {colors.fg, colors.section_bg},
        separator = ' ',
        separator_highlight = {colors.bg, colors.section_bg}
    }
}
gls.right[9] = {
    FileEncode = {
        provider  = {
            'FileEncode',
            function() return ' ' end
        },
        condition = buffer_not_empty,
        highlight = {colors.fg, colors.section_bg}
    }
}
gls.right[10] = {
    LineColumn = {
        provider = {
            'LineColumn',
            function() return ' ' end
        },
        highlight = {colors.gray2, colors.blue},
        separator = ' ',
        separator_highlight = {colors.section_bg, colors.blue},
    }
}
gls.right[11] = {
    ScrollBar = {
        provider = 'ScrollBar',
        highlight = {colors.yellow,colors.purple},
    }
}
--- Short line
gls.short_line_left[1] = {
    FileType = {
        provider = {
            function() return '  ' end,
            'FileTypeName'
        },
        condition = buffer_not_empty,
        highlight = {colors.orange, colors.section_bg},
        separator = ' ',
        separator_highlight = {colors.section_bg, colors.section_bg}
    }
}
gls.short_line_left[2] = {
    FileName = {
        provider = get_current_file_name,
        highlight = {colors.fg, colors.section_bg},
        separator = ' ',
        separator_highlight = {colors.section_bg, colors.bg}
    }
}
--- Force manual load so that nvim boots with a status line
gl.load_galaxyline()


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
vim.api.nvim_set_keymap(
    'n',
    '<leader>bb',
    '<cmd>BufferLinePick<CR>',
    { noremap = true, silent = true })
