local lib = {}


-- Get global variable.
function lib.get_var(get_var, set_var)
    if get_var ~= nil then return get_var else return set_var end
end

-- Create a below right split window.
function lib.belowright_split(height)
    local term_h = math.min(height, math.floor(vim.fn.nvim_win_get_height(0) / 2))
    vim.fn.execute('belowright split')
    vim.fn.execute('resize '..tostring(term_h))
end

-- Return the <cWORD> without the noisy characters.
function lib.get_clean_cWORD(del_list)
    local c_word = vim.fn.split(vim.fn.expand("<cWORD>"), "\\zs")
    while vim.fn.index(del_list, c_word[#c_word]) >= 0 and #c_word >= 2 do
        table.remove(c_word, #c_word)
    end
    while vim.fn.index(del_list, c_word[1]) >= 0 and #c_word >= 2 do
        table.remove(c_word, 1)
    end
    return table.concat(c_word)
end

-- Find the root directory of .git.
function lib.get_git_root()
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

-- Get the branch name.
function lib.get_git_branch(git_root)
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

-- Get characters around the cursor.
function lib.get_context(mode)
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

-- Replace chars in a string according to a dictionary.
function lib.str_escape(str, esc_table)
    local str_list = vim.fn.split(str, '\\zs')
    for i,v in ipairs(str_list) do
        if esc_table[v] then
            str_list[i] = esc_table[v]
        end
    end
    return table.concat(str_list)
end

-- Return the selections.
function lib.get_visual_selection()
    local a_bak = vim.fn.getreg('a', 1)
    vim.fn.execute('normal! gv"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

-- Calculate the day of week from date.
function lib.zeller(year, month, date)
    if (month < 1 or month > 12) then
        print("Not a valid month.")
        return
    end

    local month_days_count
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

-- Mapping.
function lib.map(f, t)
    local t2 = {}
    for key,val in pairs(t) do t2[key] = f(val) end
    return t2
end


return lib
