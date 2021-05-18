local M = {}
local fn  = vim.fn
local lib = require("utility/lib")


local function srd_pair(pair_a)
    local pairs = {
        ["("]=")", ["["]="]", ["{"]="}",
        ["<"]=">", [" "]=" ",
        ["《"]="》", ["“"]="”",
    }
    if pair_a:match('^[%(%[{<%s《“]+$') then
        local str_list = fn.split(pair_a, '\\zs')
        local new_list = {}
        for _, val in ipairs(str_list) do
            table.insert(new_list, 1, pairs[val])
        end
        return table.concat(new_list)
    elseif fn.matchstr(pair_a, '\\v^(\\<\\w+\\>)+$') ~= '' then
        local str_list = fn.split(pair_a, '<')
        local new_list = {}
        for _, val in ipairs(str_list) do
            table.insert(new_list, 1, val)
        end
        return '</'..table.concat(new_list, '</')
    else
        return pair_a
    end
end

function M.srd_add(mode, ...)
    local arg_list = {...}
    local pair_a
    if #arg_list > 0 then
        pair_a = arg_list[1]
    else
        pair_a = fn.input("Surrounding add: ")
    end
    local pair_b = srd_pair(pair_a)

    if mode == 'n' then
        local origin = fn.getpos('.')
        if (lib.get_context('f'):match('^.%s') or
            lib.get_context('f'):match('^.$')) then
            fn.execute('normal! a'..pair_b)
        else
            fn.execute('normal! Ea'..pair_b)
        end
        fn.setpos('.', origin)
        if (lib.get_context('l'):match('%s') or
            lib.get_context('b'):match('^$')) then
            fn.execute('normal! i'..pair_a)
        else
            fn.execute('normal! Bi'..pair_a)
        end
    elseif mode == 'v' then
        local stt_pos = fn.getpos("'<")
        local end_pos = fn.getpos("'>")
        fn.setpos('.', end_pos)
        fn.execute('normal! a'..pair_b)
        fn.setpos('.', stt_pos)
        fn.execute('normal! i'..pair_a)
    end
end

function M.srd_sub(...)
    local arg_list = {...}
    local back = lib.get_context('b')
    local fore = lib.get_context('f')
    local pair_a = fn.input("Surrounding delete: ")
    local pair_b = srd_pair(pair_a)
    local pair_a_new
    if #arg_list > 0 then
        pair_a_new = arg_list[1]
    else
        pair_a_new = fn.input("Change to: ")
    end
    local pair_b_new = srd_pair(pair_a_new)
    local search_back = '\\v.*\\zs'..lib.vim_reg_esc(pair_a)
    local search_fore = '\\v'..lib.vim_reg_esc(pair_b)

    if (fn.matchstr(back, search_back) ~= '' and
        fn.matchstr(fore, search_fore) ~= '') then
        local back_new = fn.substitute(back, search_back, pair_a_new, '')
        local fore_new = fn.substitute(fore, search_fore, pair_b_new, '')
        local line_new = back_new..fore_new
        fn.setline(fn.line('.'), line_new)
    end
end


return M
