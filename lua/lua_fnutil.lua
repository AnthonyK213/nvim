-- Functions
--- Hanzi count.
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

--- Calculate the day of week from a date(yyyy-mm-dd).
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

--- Markdown number bullet
local function util_lua_md_check_line(lnum)
    local lstr = vim.fn.getline(lnum)
    local start, indent = lstr:find('^%s*', 1, false)
    local detect = 0
    local bullet
    if (lstr:match('^%s*[%+%-%*]%s+.*$')) then
        detect = 1
        bullet = lstr:match('^%s*([%+%-%*])%s+.*$')
    elseif (lstr:match('^%s*%d+%.%s+.*$')) then
        detect = 2
        bullet = lstr:match('^%s*(%d+)%.%s+.*$')
    end
    return detect, lstr, bullet, indent
end

function util_lua_md_insert_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = util_lua_md_check_line('.')
    local l_det = 0
    local l_bul
    local l_ind = 0

    if (c_det == 0) then
        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = util_lua_md_check_line(b_num)
            if (b_ind < c_ind and b_det ~= 0) then
                l_det = b_det
                l_bul = b_bul
                l_ind = b_ind
                break
            end
            b_num = b_num - 1
        end
    else
        l_det = c_det
        l_bul = c_bul
        l_ind = c_ind
    end

    if (l_det == 0) then
        vim.cmd("call feedkeys(\"\\<C-o>o\")")
    else
        local f_num = c_num + 1
        local move_stp = 0
        local move_rec = {}
        while (f_num <= vim.fn.line('$')) do
            local f_det, f_str, f_bul, f_ind = util_lua_md_check_line(f_num)
            if (f_det == l_det and f_ind == l_ind) then
                table.insert(move_rec, move_stp)
                if (l_det == 1) then
                    break
                elseif (l_det == 2 and f_det == 2) then
                    local f_new = f_str:gsub(tostring(f_bul), tostring(f_bul + 1), 1)
                    vim.fn.setline(f_num, f_new)
                end
            elseif (f_ind <= l_ind) then
                table.insert(move_rec, move_stp)
                break
            elseif (f_num == vim.fn.line('$')) then
                table.insert(move_rec, move_stp + 1)
                break
            end
            f_num = f_num + 1
            move_stp  = move_stp + 1
        end
        if (#move_rec == 0) then
            count_d = 0
        else
            count_d = move_rec[1]
        end
        if (l_det == 2) then
            l_bul_new = tostring(l_bul + 1)..". "
        else
            l_bul_new = l_bul.." "
        end
        vim.cmd("call feedkeys(\""..string.rep("\\<C-g>U\\<Down>", count_d)..
            "\\<C-o>o\\<C-o>0"..string.rep("\\<SPACE>", l_ind)..l_bul_new.."\")")
    end
end

function util_lua_md_sort_num_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = util_lua_md_check_line('.')

    if (c_det == 2) then
        local b_num_list = { c_num }
        local f_num_list = {}

        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = util_lua_md_check_line(b_num)
            if (b_det == 2) then
                if (b_ind == c_ind) then
                    table.insert(b_num_list, 1, b_num)
                elseif (b_ind < c_ind) then
                    break
                end
            elseif (b_det ~= 2 and b_ind <= c_ind) then
                break
            end
            b_num = b_num - 1
        end

        local f_num = c_num + 1
        while (f_num <= vim.fn.line('$')) do
            local f_det, f_str, f_bul, f_ind = util_lua_md_check_line(f_num)
            if (f_det == 2) then
                if (f_ind == c_ind) then
                    table.insert(f_num_list, f_num)
                elseif (f_ind < c_ind) then
                    break
                end
            elseif (f_det ~= 2 and f_ind <= c_ind) then
                break
            end
            f_num = f_num + 1
        end

        for i, u in ipairs(f_num_list) do
            table.insert(b_num_list, u)
        end

        for j, v in ipairs(b_num_list) do
            local l_new = vim.fn.getline(v):gsub('%d+', tostring(j), 1)
            vim.fn.setline(v, l_new)
        end
    else
        print("Not in a line of any numbered lists.")
    end
end


-- Key maps
--- Hanzi count.
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
--- Append day of week after the date
vim.api.nvim_set_keymap(
    'n',
    '<leader>dd',
    ":call v:lua.util_lua_append_day_from_date()<CR>",
    { noremap = true, silent = true })
--- Insert an orgmode-style timestamp at the end of the line
vim.api.nvim_set_keymap(
    'n',
    '<leader>ds',
    "A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>",
    { noremap = true, silent = true })
--- List bullets
vim.api.nvim_set_keymap(
    'i',
    '<M-CR>',
    "<C-o>:call v:lua.util_lua_md_insert_bullet()<CR>",
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>ml',
    ":call v:lua.util_lua_md_sort_num_bullet()<CR>",
    { noremap = true, silent = true })
