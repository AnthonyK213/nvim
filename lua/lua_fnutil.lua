-- Functions
-- Hanzi count.
function util_lua_hanzi_count(mode)
    if (mode == "n") then
        content = vim.fn.getline(1, '$')
    elseif (mode == "v") then
        content = vim.fn.split(vim.fn.Lib_Get_Visual_Selection(), "\n")
    else
        return
    end

    local h_count = 0
    for i, line in ipairs(content) do
        for j, char in ipairs(vim.fn.split(line, "\\zs")) do
            local code = vim.fn.char2nr(char)
            if code >= 0x4E00 and code <= 0x9FA5 then
                h_count = h_count + 1
            end
        end
    end

    return h_count
end

-- Calculate the day of week from a date(yyyy-mm-dd).
function util_lua_append_day_from_date()
    local str = vim.fn.expand("<cWORD>")
    if str:match('^$') then return end
    local str_date, m2, m3, m4 = str:match('^.*((%d%d%d%d)%-(%d%d)%-(%d%d)).*$')
    if (str_date) then
        int_a = tonumber(m2)
        int_m = tonumber(m3)
        int_d = tonumber(m4)
    else
        print("Not a valid date expression.")
        return
    end

    local day_of_week = lib_lua_zeller(int_a, int_m, int_d)
    if (day_of_week) then
        local line = vim.fn.getline('.')
        local cursor_pos = vim.fn.col('.')
        local match_start = 0
        while (true) do
            match_cword = vim.fn.matchstrpos(line, str, match_start)
            if (match_cword[2] <= cursor_pos and
                match_cword[3] >= cursor_pos) then
                break
            end
            match_start = match_cword[3]
        end
        local cword_stt = match_cword[2]
        local cword_end = vim.fn.matchstrpos(line, str_date, cword_stt)[3]
        vim.fn.setpos('.', {0, vim.fn.line('.'), cword_end})
        vim.cmd(string.format("silent exe 'normal! a ' . %q", day_of_week))
    end
end


-- Keymaps
-- Hanzi count.
vim.api.nvim_set_keymap(
    'n',
    '<leader>cc',
    ":echo 'Chinese characters count: ' . v:lua.util_lua_hanzi_count('n')<CR>",
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'v',
    '<leader>cc',
    ":<C-u>echo 'Chinese characters count: ' . v:lua.util_lua_hanzi_count('v')<CR>",
    { noremap = true, silent = true })

-- Append day of week after the date
vim.api.nvim_set_keymap(
    'n',
    '<leader>dd',
    ":call v:lua.util_lua_append_day_from_date()<CR>",
    { noremap = true, silent = true })
