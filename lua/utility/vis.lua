local M = {}
local lib = require('utility/lib')


-- Extend highlight groups.
function M.hi_extd()
    local set_hi = lib.set_highlight_group
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

--- Set background according to time.
function M.time_background()
    local timer = vim.loop.new_timer()
    timer:start(0, 60000, vim.schedule_wrap(function()
        local hour = tonumber(vim.fn.strftime('%H'))
        local bg = (hour > 6 and hour < 18) and 'light' or 'dark'
        if vim.o.bg ~= bg then vim.o.bg = bg end
    end))
end


return M
