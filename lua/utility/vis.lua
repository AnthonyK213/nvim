local M = {}
local lib = require('utility/lib')


-- Extend highlight groups.
function M.hi_extd()
    local set_hi = lib.set_highlight_group
    set_hi('SpellBad',                vim.g.terminal_color_1, nil, 'underline')
    set_hi('SpellCap',                vim.g.terminal_color_3, nil, 'underline')
    set_hi('markdownTSEmphasis',      vim.g.terminal_color_5, nil, 'italic')
    set_hi('markdownTSLiteral',       vim.g.terminal_color_2, nil, nil)
    set_hi('markdownTSNone',          vim.g.terminal_color_7, nil, nil)
    set_hi('markdownTSPunctSpecial',  vim.g.terminal_color_1, nil, nil)
    set_hi('markdownTSStringEscape',  vim.g.terminal_color_6, nil, 'bold')
    set_hi('markdownTSStrong',        vim.g.terminal_color_3, nil, 'bold')
    set_hi('markdownTSTextReference', vim.g.terminal_color_6, nil, nil)
    set_hi('markdownTSTitle',         vim.g.terminal_color_1, nil, 'bold')
    set_hi('markdownTSURI',           vim.g.terminal_color_4, nil, 'underline')
end


return M
