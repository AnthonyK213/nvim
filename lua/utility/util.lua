local M = {}
local lib = require('utility/lib')
local pub = require('utility/pub')


--- Open terminal and launch shell.
function M.terminal()
    lib.belowright_split(15)
    vim.cmd('terminal '..pub.shell)
    vim.cmd('setl nonu')
end

--- Show documents.
function M.show_doc()
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.cmd('h '..vim.fn.expand('<cword>'))
    else
        vim.lsp.buf.hover()
    end
end

--- Open and edit text file in vim.
function M.edit_file(file_path, chdir)
    local path = vim.fn.expand(file_path)
    if vim.fn.expand("%:t") == '' then
        vim.cmd('e '..path)
    else
        vim.cmd('tabnew '..path)
    end
    if chdir then
        vim.cmd('cd %:p:h')
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
    vim.cmd('!'..cmd..' '..file_path_esc)
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
    vim.cmd('!'..pub.start..' '..url_arg)
end

--- Match URL in string.
function M.match_url(str)
    local protocols = {
        [''] = 0,
        ['http://'] = 0,
        ['https://'] = 0,
        ['ftp://'] = 0
    }

    local url, prot, dom, colon, port, slash, path =
    str:match'((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'

    if (url and
        not (dom..'.'):find('%W%W') and
        protocols[prot:lower()] == (1 - #slash) * #path and
        (colon == '' or port ~= '' and port + 0 < 65536)) then
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


return M
