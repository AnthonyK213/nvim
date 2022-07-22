local M = {}
local api = vim.api
local lib = require("utility.lib")


---Surrounding pairs.
---@param pair_a string Left side of the surrounding.
---@return string pair_b Right side of the surrounding.
local function srd_pair(pair_a)
    local pairs = {
        ["("] = ")",   ["["] = "]", ["{"] = "}",
        ["<"] = ">",   [" "] = " ",
        ["《"] = "》", ["“"] = "”",
    }
    if pair_a:match("^[%(%[{<%s《“]+$") then
        return table.concat(vim.tbl_map(function(x)
            return pairs[x]
        end, lib.tbl_reverse(lib.str_explode(pair_a))))
    elseif vim.regex([[\v^(\<\w{-}\>)+$]]):match_str(pair_a) then
        return "</"..table.concat(lib.tbl_reverse(vim.tbl_filter(function (str)
            return str ~= ""
        end, vim.split(pair_a, "<"))), "</")
    else
        return pair_a
    end
end

---Collect pairs in hashtable `tab_pair`.
---If pair_a then -1, if pair_b then 1.
---@param str string
---@param pair_a string Left side of the surrounding.
---@param pair_b string Right side of the surrounding.
---@return table<string, integer> result
local function srd_collect(str, pair_a, pair_b)
    local tab_pair = {}
    for pos in str:gmatch("()"..vim.pesc(pair_a)) do
        tab_pair[tostring(pos)] = -1
    end

    for pos in str:gmatch("()"..vim.pesc(pair_b)) do
        tab_pair[tostring(pos)] = 1
    end
    return tab_pair
end

---Locate surrounding pair in direction `dir`
---FIXME: If there are imbalanced pairs in string, how to get this work?
---@param dir integer (-1|1) -1 for backward, 1 for forward.
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

---Add surrounding.
---@param mode string \"n\"|\"v\".
---@param pair_a? string Left side of the surrounding.
function M.srd_add(mode, pair_a)
    ---Add surrounding.
    ---@param p_a string Left side of the surrounding.
    local add = function (p_a)
        if not p_a then return end
        local p_b = srd_pair(p_a)

        if mode == "n" then
            local word, s, e = lib.get_word()
            local line, col = unpack(api.nvim_win_get_cursor(0))
            api.nvim_buf_set_text(0, line - 1, s, line - 1, e, { p_a..word..p_b })
            api.nvim_win_set_cursor(0, { line, col + #p_a })
        elseif mode == "v" then
            local stt_pos = api.nvim_buf_get_mark(0, "<")
            local end_pos = api.nvim_buf_get_mark(0, ">")
            api.nvim_win_set_cursor(0, end_pos)
            vim.cmd("normal! a"..p_b)
            api.nvim_win_set_cursor(0, stt_pos)
            vim.cmd("normal! i"..p_a)
        end
    end

    if pair_a then
        add(pair_a)
    else
        vim.ui.input({ prompt = "Surrounding add: " }, function (input)
            add(input)
        end)
    end
end

---Change surrounding.
---@param pair_a_new? string Left side of the new surrounding.
---@param pair_a_old? string Left side of the old surrounding.
function M.srd_sub(pair_a_new, pair_a_old)
    ---Change surrounding.
    ---@param p_a_n string Left side of the new surrounding.
    ---@param p_a_o string Left side of the old surrounding.
    local sub = function (p_a_n, p_a_o)
        local context = lib.get_context()
        local back = context.b
        local fore = context.f
        local p_b_o = srd_pair(p_a_o)
        local p_b_n = srd_pair(p_a_n)
        local back_new, fore_new
        local pos = api.nvim_win_get_cursor(0)

        if p_a_o == p_b_o then
            local pat = vim.pesc(p_a_o)
            if back:match("^.*"..pat)
                and fore:match(pat) then
                back_new = back:gsub("^(.*)"..pat, "%1"..p_a_n, 1)
                fore_new = fore:gsub(pat, p_b_n, 1)
            end
        else
            local pos_a = srd_locate(back, p_a_o, p_b_o, -1)
            local pos_b = srd_locate(fore, p_a_o, p_b_o, 1)
            if pos_a and pos_b then
                back_new = back:sub(1, pos_a - 1)
                ..p_a_n
                ..back:sub(pos_a + p_a_o:len())
                fore_new = fore:sub(1, pos_b - 1)
                ..p_b_n
                ..fore:sub(pos_b + p_b_o:len())
            end
        end

        if back_new and fore_new then
            api.nvim_set_current_line(back_new..fore_new)
            pos[2] = pos[2] + #p_a_n - #p_a_o
            api.nvim_win_set_cursor(0, pos)
        end
    end

    if pair_a_old then
        if pair_a_new then
            sub(pair_a_new, pair_a_old)
        else
            vim.ui.input({ prompt = "Change to: " }, function (input)
                if not input then return end
                sub(input, pair_a_old)
            end)
        end
    else
        vim.ui.input({ prompt = "Surrounding delete: " }, function (pair_a)
            if not pair_a then return end
            if pair_a_new then
                sub(pair_a_new, pair_a)
            else
                vim.ui.input({ prompt = "Change to: " }, function (input)
                    if not input then return end
                    sub(input, pair_a)
                end)
            end
        end)
    end
end


return M
