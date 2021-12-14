local M = {}
local lib = require('utility/lib')


-- Extend highlight groups.
function M.hi_extd()
    local set_hi = lib.set_highlight_group
    set_hi('SpellBad',         vim.g.terminal_color_1,  nil, 'underline')
    set_hi('SpellCap',         vim.g.terminal_color_3,  nil, 'underline')
    set_hi('mkdBold',          vim.g.terminal_color_8,  nil, nil)
    set_hi('mkdItalic',        vim.g.terminal_color_8,  nil, nil)
    set_hi('mkdBoldItalic',    vim.g.terminal_color_8,  nil, nil)
    set_hi('mkdCodeDelimiter', vim.g.terminal_color_8,  nil, nil)
    set_hi('htmlBold',         vim.g.terminal_color_3,  nil, 'bold')
    set_hi('htmlItalic',       vim.g.terminal_color_5,  nil, 'italic')
    set_hi('htmlBoldItalic',   vim.g.terminal_color_11, nil, 'bold,italic')
    set_hi('htmlH1',           vim.g.terminal_color_1,  nil, 'bold')
    set_hi('htmlH2',           vim.g.terminal_color_1,  nil, 'bold')
    set_hi('htmlH3',           vim.g.terminal_color_1,  nil, nil)
    set_hi('mkdHeading',       vim.g.terminal_color_1,  nil, nil)
end


return M