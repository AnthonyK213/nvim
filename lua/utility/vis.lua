local M = {}
local lib = require('utility/lib')


-- Extend highlight groups.
function M.hi_extd()
    local set_hi = lib.set_highlight_group
    set_hi('SpellBad',         '#f7768e', nil, 'underline')
    set_hi('SpellCap',         '#ff9e64', nil, 'underline')
    set_hi('mkdBold',          '#394b70', nil, nil)
    set_hi('mkdItalic',        '#394b70', nil, nil)
    set_hi('mkdBoldItalic',    '#394b70', nil, nil)
    set_hi('mkdCodeDelimiter', '#394b70', nil, nil)
    set_hi('htmlBold',         '#ff9e64', nil, 'bold')
    set_hi('htmlItalic',       '#c792ea', nil, 'italic')
    set_hi('htmlBoldItalic',   '#e0af68', nil, 'bold,italic')
    set_hi('htmlH1',           '#f7768e', nil, 'bold')
    set_hi('htmlH2',           '#f7768e', nil, 'bold')
    set_hi('htmlH3',           '#f7768e', nil, nil)
    set_hi('mkdHeading',       '#f7768e', nil, nil)
end

--- Set background according to time.
function M.time_background()
    local timer = vim.loop.new_timer()
    timer:start(0, 60000, vim.schedule_wrap(function()
        local hour = tonumber(os.date('%H'))
        local bg = (hour > 6 and hour < 18) and 'light' or 'dark'
        if vim.o.bg ~= bg then vim.o.bg = bg end
    end))
end


return M
