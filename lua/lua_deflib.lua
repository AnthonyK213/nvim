-- CONST
--- Escape string for URL.
lib_const_esc_url = {
    [" "]  = "\\%20",
    ["!"]  = "\\%21",
    ['"']  = "\\%22",
    ["#"]  = "\\%23",
    ["$"]  = "\\%24",
    ["%"]  = "\\%25",
    ["&"]  = "\\%26",
    ["'"]  = "\\%27",
    ["("]  = "\\%28",
    [")"]  = "\\%29",
    ["*"]  = "\\%2A",
    ["+"]  = "\\%2B",
    [","]  = "\\%2C",
    ["/"]  = "\\%2F",
    [":"]  = "\\%3A",
    [";"]  = "\\%3B",
    ["<"]  = "\\%3C",
    ["="]  = "\\%3D",
    [">"]  = "\\%3E",
    ["?"]  = "\\%3F",
    ["@"]  = "\\%40",
    ["\\"] = "\\%5C",
    ["|"]  = "\\%7C",
    ["\n"] = "\\%20",
    ["\r"] = "\\%20",
    ["\t"] = "\\%20"
}
--- Directional operation which won't mess up the history.
vim.g.lib_const_l = vim.fn.nvim_replace_termcodes("<C-G>U<Left>",  true, false, true)
vim.g.lib_const_d = vim.fn.nvim_replace_termcodes("<C-G>U<Down>",  true, false, true)
vim.g.lib_const_u = vim.fn.nvim_replace_termcodes("<C-G>U<Up>",    true, false, true)
vim.g.lib_const_r = vim.fn.nvim_replace_termcodes("<C-G>U<Right>", true, false, true)


-- Functions
--- Create a below right split window.
function lib_lua_belowright_split(height)
    local term_h = math.min(height, math.floor(vim.fn.nvim_win_get_height(0) / 2))
    vim.fn.execute('belowright split')
    vim.fn.execute('resize '..tostring(term_h))
end

--- Return the <cWORD> without the noisy characters.
function lib_lua_get_clean_cWORD(del_list)
    local c_word = vim.fn.split(vim.fn.expand("<cWORD>"), "\\zs")
    while vim.fn.index(del_list, c_word[#c_word]) >= 0 and #c_word >= 2 do
        table.remove(c_word, #c_word)
    end
    while vim.fn.index(del_list, c_word[1]) >= 0 and #c_word >= 2 do
        table.remove(c_word, 1)
    end
    return table.concat(c_word)
end

--- Find the root directory of .git.
function lib_lua_get_git_root()
    local current_dir = vim.fn.expand('%:p:h')
    while true do
        if vim.fn.globpath(current_dir, ".git", 1) ~= '' then
            return current_dir
        end
        local temp_dir = current_dir
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
        if temp_dir == current_dir then break end
    end
    return false
end

--- Get the branch name.
function lib_lua_get_git_branch(git_root)
    if not git_root then return false end

    local content, branch
    if vim.fn.glob(git_root..'/.git/HEAD', 1) ~= '' then
        content = vim.fn.readfile(git_root..'/.git/HEAD')
    else
        return false
    end

    if #content > 0 then
        branch = content[1]:match('^ref:%s.+/(.-)$')
        if branch ~= '' then return branch else return false end
    else
        return false
    end
end

--- Get characters around the cursor.
function lib_lua_get_context(mode)
    if mode == 'l' then
        return vim.fn.matchstr(vim.fn.getline('.'), '.\\%'..vim.fn.col('.')..'c')
    elseif mode == 'n' then
        return vim.fn.matchstr(vim.fn.getline('.'), '\\%'..vim.fn.col('.')..'c.')
    elseif mode == 'b' then
        return vim.fn.matchstr(vim.fn.getline('.'), '^.*\\%'..vim.fn.col('.')..'c')
    elseif mode == 'f' then
        return vim.fn.matchstr(vim.fn.getline('.'), '\\%'..vim.fn.col('.')..'c.*$')
    end
end

--- Replace chars in a string according to a dictionary.
function lib_lua_escape(str, esc_table)
    local str_list = vim.fn.split(str, '\\zs')
    for i,v in ipairs(str_list) do
        if esc_table[v] then
            str_list[i] = esc_table[v]
        end
    end
    return table.concat(str_list)
end

--- Return the selections.
function lib_lua_get_visual_selection()
    local a_bak = vim.fn.getreg('a', 1)
    vim.fn.execute('normal! gv"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

--- Calculate the day of week from date.
function lib_lua_zeller(year, month, date)
    if (month < 1 or month > 12) then
        print("Not a valid month.")
        return
    end

    if (month == 2) then
        month_days_count = 28
        if ((year % 100 ~= 0 and year % 4 == 0) or
            (year % 100 == 0 and year % 400 == 0)) then
            month_days_count = month_days_count + 1
        end
    else
        month_days_count = 30
        if ((month <= 7 and month % 2 == 1) or
            (month >= 8 and month % 2 == 0)) then
            month_days_count = month_days_count + 1
        end
    end

    if (date < 1 or date > month_days_count) then
        print("Not a valid date.")
        return
    end

    if (month == 1 or month == 2) then
        year = year - 1
        month = month + 12
    end

    local c = math.floor(year / 100)
    local y = year - c * 100
    local x = math.floor(c / 4) + y + math.floor(y / 4) +
              math.floor(26 * (month + 1) / 10) + date - 2 * c - 1
    local z = x % 7
    if (z <= 0) then z = z + 7 end
    local days_list = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}

    return days_list[z]
end
