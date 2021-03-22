local M = {}
local api = vim.api
local fn  = vim.fn


-- Get characters around the cursor by 'mode'.
-- @tparam string mode Four modes to get the context
--   'l' -> Return the character before cursor
--   'n' -> Return the character after cursor
--   'b' -> Return the half line before cursor
--   'f' -> Return the half line after cursor
-- @treturn string Grabbed string around the cursor
local function get_ctxt(mode)
    if mode == 'l' then
        return fn.matchstr(api.nvim_get_current_line(), '.\\%'..fn.col('.')..'c')
    elseif mode == 'n' then
        return fn.matchstr(api.nvim_get_current_line(), '\\%'..fn.col('.')..'c.')
    elseif mode == 'b' then
        return fn.matchstr(api.nvim_get_current_line(), '^.*\\%'..fn.col('.')..'c')
    elseif mode == 'f' then
        return fn.matchstr(api.nvim_get_current_line(), '\\%'..fn.col('.')..'c.*$')
    end
end

local function sur_pair(pair_a)
    local pairs = { ["("]=")", ["["]="]", ["{"]="}", ["<"]=">", [" "]=" ", ["《"]="》", ["“"]="”" }
    if pair_a:match('^[%(%[{<%s《“]+$') then
        local str_list = fn.split(pair_a, '\\zs')
        local new_list = {}
        for _,val in ipairs(str_list) do
            table.insert(new_list, 1, pairs[val])
        end
        return table.concat(new_list)
    elseif fn.matchstr(pair_a, '\\v^(\\<\\w+\\>)+$') ~= '' then
        local str_list = fn.split(pair_a, '<')
        local new_list = {}
        for _,val in ipairs(str_list) do
            table.insert(new_list, 1, val)
        end
        return '</'..table.concat(new_list, '</')
    else
        return pair_a
    end
end

function M.sur_add(mode, ...)
    local arg_list = {...}
    local pair_a
    if #arg_list > 0 then
        pair_a = arg_list[1]
    else
        pair_a = fn.input("Surrounding add: ")
    end
    local pair_b = sur_pair(pair_a)

    if mode == 'n' then
        local origin = fn.getpos('.')
        if (get_ctxt('f'):match('^.%s') or
            get_ctxt('f'):match('^.$')) then
            fn.execute('normal! a'..pair_b)
        else
            fn.execute('normal! Ea'..pair_b)
        end
        fn.setpos('.', origin)
        if (get_ctxt('l'):match('%s') or
            get_ctxt('b'):match('^$')) then
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

function M.sur_sub(...)
    local arg_list = {...}
    local back = get_ctxt('b')
    local fore = get_ctxt('f')
    local pair_a = fn.input("Surrounding delete: ")
    local pair_b = sur_pair(pair_a)
    local pair_a_new
    if #arg_list > 0 then
        pair_a_new = arg_list[1]
    else
        pair_a_new = fn.input("Change to: ")
    end
    local pair_b_new = sur_pair(pair_a_new)
    local search_back = '\\v.*\\zs'..fn.escape(pair_a, ' ()[]{}<>.+*^$')
    local search_fore = '\\v'..fn.escape(pair_b, ' ()[]{}<>.+*^$')

    if (fn.matchstr(back, search_back) ~= '' and
        fn.matchstr(fore, search_fore) ~= '') then
        local back_new = fn.substitute(back, search_back, pair_a_new, '')
        local fore_new = fn.substitute(fore, search_fore, pair_b_new, '')
        local line_new = back_new..fore_new
        fn.setline(fn.line('.'), line_new)
    end
end


return M
