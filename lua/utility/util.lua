local M = {}
local lib = require('utility/lib')
local pub = require('utility/pub')


--- Open terminal and launch shell.
function M.terminal()
    lib.belowright_split(15)
    vim.fn.execute('terminal '..pub.shell)
    vim.cmd('setl nonu')
end

--- Show documents.
function M.show_doc()
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.fn.execute('h '..vim.fn.expand('<cword>'))
    else
        vim.lsp.buf.hover()
    end
end

--- Open and edit text file in vim.
function M.edit_file(file_path, chdir)
    local path = vim.fn.expand(file_path)
    if vim.fn.expand("%:t") == '' then
        vim.fn.execute('e '..path)
    else
        vim.fn.execute('tabnew '..path)
    end
    if chdir then
        vim.fn.execute('cd %:p:h')
    end
end

--- Open file with system default browser.
function M.open_file(file_path)
    if vim.fn.glob(file_path) == '' then return end
    local file_path_esc = "\""..vim.fn.shellescape(file_path).."\""
    local cmd
    if vim.fn.has("win32") == 1 then
        cmd = pub.start..' ""'
    else
        cmd = pub.start
    end
    vim.fn.execute('!'..cmd..' '..file_path_esc)
end

--- Open url with system default web browser.
function M.open_url(url)
    if not url then
        print('No invalid url found.')
        return
    end
    local url_arg
    if vim.fn.has('win32') == 1 then
        url_arg = url
    else
        url_arg = "\""..url.."\""
    end
    vim.fn.execute('!'..pub.start..' '..url_arg)
end

--- Match URL in string.
function M.match_url(str)
    local function max4(a, b, c, d)
        return math.max(a + 0, b + 0, c + 0, d + 0)
    end

    local protocols = {
        [''] = 0,
        ['http://'] = 0,
        ['https://'] = 0,
        ['ftp://'] = 0
    }

    local url, prot, subd, tld, colon, port, slash, path =
    str:match('(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)'..
    '(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))')

    if (url and
        protocols[prot:lower()] == (1 - #slash) * #path and
        not subd:find('%W%W') and
        (colon == '' or port ~= '' and port + 0 < 65536) and
        (pub.url_domain_table[tld:lower()] or tld:find('^%d+$') and
        subd:find('^%d+%.%d+%.%d+%.$') and
        max4(tld, subd:match('^(%d+)%.(%d+)%.(%d+)%.$')) < 256)) then
        return url
    end
end

--- Search web.
function M.search_web(mode, site)
    local search_obj
    if mode == 'n' then
        local del_list = {
            ".", ",", "'", "\"",
            ";", "*", "~", "`",
            "(", ")", "[", "]", "{", "}"
        }
        search_obj = lib.str_escape(lib.get_clean_cWORD(del_list), pub.esc_url)
    elseif mode == 'v' then
        search_obj = lib.str_escape(lib.get_visual_selection(), pub.esc_url)
    end

    M.open_url(site..search_obj)
end

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
