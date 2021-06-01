local M = {}
local lib = require('utility/lib')
local pub = require('utility/pub')


-- Open terminal and launch shell.
function M.terminal()
    lib.belowright_split(15)
    vim.cmd('terminal '..pub.shell)
    vim.cmd('setl nonu')
end

-- Show documents.
function M.show_doc()
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.cmd('h '..vim.fn.expand('<cword>'))
    else
        vim.lsp.buf.hover()
    end
end

-- Open and edit text file in vim.
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

-- Open file or url with system default browser.
function M.open_file_or_url(arg)
    if (not arg) or
        (vim.fn.glob(arg) == '' and not
        arg:match'^%f[%w]%a+://%w[-.%w]*:?%d*/?[%w_.~!*:@&+$/?%%#=-]*$') then
        return
    end
    local arg_esc = vim.fn.shellescape(arg, 1)
    local cmd
    if vim.fn.has('win32') == 1 then
        cmd = pub.start..' ""'
    else
        cmd = pub.start
    end
    vim.cmd('silent !'..cmd..' '..arg_esc)
end

-- Match URL in string.
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

-- Search web.
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

    M.open_file_or_url(site..search_obj)
end


return M
