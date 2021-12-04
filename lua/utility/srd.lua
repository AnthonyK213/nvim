local M = {}
local api = vim.api
local lib = require("utility/lib")


local function srd_pair(pair_a)
    local pairs = {
        ["("]=")", ["["]="]", ["{"]="}",
        ["<"]=">", [" "]=" ",
        ["《"]="》", ["“"]="”",
    }
    if pair_a:match('^[%(%[{<%s《“]+$') then
        return table.concat(vim.tbl_map(function(x) return pairs[x] end,
        lib.tbl_reverse(lib.str_explode(pair_a))))
    elseif vim.regex([[\v^(\<\w{-}\>)+$]]):match_str(pair_a) then
        return '</'..table.concat(lib.tbl_reverse(vim.tbl_filter(function (str)
            return str ~= ""
        end, vim.split(pair_a, '<'))), '</')
    else
        return pair_a
    end
end

-- Collect pairs in hashtable `tab_pair`.
-- If pair_a then -1, if pair_b then 1.
local function srd_collect(str, pair_a, pair_b)
    local tab_pair = {}
    for pos in str:gmatch('()'..vim.pesc(pair_a)) do
        tab_pair[tostring(pos)] = -1
    end

    for pos in str:gmatch('()'..vim.pesc(pair_b)) do
        tab_pair[tostring(pos)] = 1
    end
    return tab_pair
end

-- Locate surrounding pair in direction `dir`
-- @param int dir -1 or 1, -1 for backward, 1 for forward.
-- FIXME: If there are imbalanced pairs in string, how to get this work?
local function srd_locate(str, pair_a, pair_b, dir)
    local tab_pair = srd_collect(str, pair_a, pair_b)
    local list_pos = {}
    local res = {}
    local sort_func

    if dir < 0 then
        sort_func = function(a, b) return a + 0 > b + 0 end
    else
        sort_func = function(a, b) return a + 0 < b + 0 end
    end

    for i in pairs(tab_pair) do
        table.insert(list_pos, i)
    end

    table.sort(list_pos, sort_func)

    for _, v in ipairs(list_pos) do
        table.insert(res, tab_pair[v])
    end

    local sum = 0
    local pair_pos

    for i, v in ipairs(res) do
        sum = sum + v
        if sum == dir then
            pair_pos = list_pos[i]
            break
        end
    end

    return pair_pos
end

function M.srd_add(mode, ...)
    local arg_list = {...}
    local pair_a
    if #arg_list > 0 then
        pair_a = arg_list[1]
    else
        pair_a = vim.fn.input("Surrounding add: ")
    end
    local pair_b = srd_pair(pair_a)

    if mode == 'n' then
        local origin = api.nvim_win_get_cursor(0)
        if (lib.get_context('f'):match('^.%s') or
            lib.get_context('f'):match('^.$')) then
            vim.cmd('normal! a'..pair_b)
        else
            vim.cmd('normal! Ea'..pair_b)
        end
        api.nvim_win_set_cursor(0, origin)
        if (lib.get_context('p'):match('%s') or
            lib.get_context('b'):match('^$')) then
            vim.cmd('normal! i'..pair_a)
        else
            vim.cmd('normal! Bi'..pair_a)
        end
        api.nvim_win_set_cursor(0, origin)
    elseif mode == 'v' then
        local stt_pos = api.nvim_buf_get_mark(0, "<")
        local end_pos = api.nvim_buf_get_mark(0, ">")
        api.nvim_win_set_cursor(0, end_pos)
        vim.cmd('normal! a'..pair_b)
        api.nvim_win_set_cursor(0, stt_pos)
        vim.cmd('normal! i'..pair_a)
    end
end

function M.srd_sub(...)
    local arg_list = {...}
    local back = lib.get_context('b')
    local fore = lib.get_context('f')
    local pair_a = vim.fn.input("Surrounding delete: ")
    local pair_b = srd_pair(pair_a)
    local pair_a_new
    if #arg_list > 0 then
        pair_a_new = arg_list[1]
    else
        pair_a_new = vim.fn.input("Change to: ")
    end
    local pair_b_new = srd_pair(pair_a_new)

    local back_new, fore_new

    if pair_a == pair_b then
        local pat = vim.pesc(pair_a)
        if (back:match('^.*'..pat) and
            fore:match(pat)) then
            back_new = back:gsub('^(.*)'..pat, '%1'..pair_a_new, 1)
            fore_new = fore:gsub(pat, pair_b_new, 1)
        end
    else
        local pos_a = srd_locate(back, pair_a, pair_b, -1)
        local pos_b = srd_locate(fore, pair_a, pair_b, 1)
        if pos_a and pos_b then
            back_new = back:sub(1, pos_a - 1)..
            pair_a_new..
            back:sub(pos_a + pair_a:len())
            fore_new = fore:sub(1, pos_b - 1)..
            pair_b_new..
            fore:sub(pos_b + pair_b:len())
        end
    end

    if back_new and fore_new then
        vim.api.nvim_set_current_line(back_new..fore_new)
    end
end


return M
