init_source('deflib')


-- CONST
--- Escape string for URL.
vim.g.lib_const_esc_url = {
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


-- Functions
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


--- autocmd!!!
function lib_lua_augroup(group, event, pattern, command)
    vim.cmd('augroup '..group)
    vim.cmd('autocmd!')
    vim.cmd('au '..event..' '..pattern..' '..command)
    vim.cmd('augroup end')
end


--- Define key maps
---- nnoremap
function lib_lua_nn(map_table)
    vim.api.nvim_set_keymap(
    'n',
    map_table.key,
    map_table.cmd,
    { noremap=true, silent=true })
end
