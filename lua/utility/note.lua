local M = {}
local lib = require('utility/lib')


-- Hanzi count.
function M.hanzi_count(mode)
    local content
    if mode == "n" then
        content = vim.fn.getline(1, '$')
    elseif mode == "v" then
        content = vim.fn.split(lib.get_visual_selection(), "\n")
    end

    local h_count = 0
    for _, line in ipairs(content) do
        if not
            ((vim.bo.filetype == 'markdown' and
            (line:match('^%s*>%s') or
            line:match('^#+%s') or
            line:match('^%s*!?%[.+%]%(.+%)'))) or
            (vim.bo.filetype == 'tex' and
            (line:match('^%s*%%')))) then
            for _, char in ipairs(vim.fn.split(line, "\\zs")) do
                local code = vim.fn.char2nr(char)
                if code >= 0x4E00 and code <= 0x9FA5 then
                    h_count = h_count + 1
                end
            end
        end
    end

    if h_count == 0 then
        print("No Chinese characters was found.")
    else
        print("The number of Chinese characters is "..tostring(h_count)..'.')
    end
end

-- Markdown number bullet
local function md_check_line(lnum)
    local lstr = vim.fn.getline(lnum)
    local _, indent = lstr:find('^%s*', 1, false)
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

function M.md_insert_bullet()
    local c_num = vim.fn.line('.')
    local c_det, _, c_bul, c_ind = md_check_line('.')
    local l_det = 0
    local l_bul, l_ind

    if (c_det == 0) then
        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, _, b_bul, b_ind = md_check_line(b_num)
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
        vim.api.nvim_input('<C-O>o')
    else
        local f_num = c_num + 1
        local move_stp = 0
        local move_rec = {}
        while (f_num <= vim.fn.line('$')) do
            local f_det, f_str, f_bul, f_ind = md_check_line(f_num)
            if (f_det == l_det and f_ind == l_ind) then
                table.insert(move_rec, move_stp)
                if (l_det == 1) then
                    break
                elseif (l_det == 2 and f_det == 2) then
                    local f_new = f_str:gsub(
                    tostring(f_bul), tostring(f_bul + 1), 1)
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
        local count_d, l_bul_new
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
        local feed_string = vim.api.nvim_replace_termcodes(string.rep('<Down>',
        count_d)..'<C-O>o<C-O>i'..string.rep('<SPACE>', l_ind)..l_bul_new,
        true, false, true)
        vim.api.nvim_feedkeys(feed_string, 'in', true)
    end
end

function M.md_sort_num_bullet()
    local c_num = vim.fn.line('.')
    local c_det, _, _, c_ind = md_check_line('.')

    if (c_det == 2) then
        local b_num_list = { c_num }
        local f_num_list = {}

        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, _, _, b_ind = md_check_line(b_num)
            if (b_det == 2) then
                if (b_ind == c_ind) then
                    table.insert(b_num_list, b_num)
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
            local f_det, _, _, f_ind = md_check_line(f_num)
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

        local b_len = #b_num_list
        for i, u in ipairs(b_num_list) do
            local lb_new = vim.fn.getline(u):gsub(
            '%d+', tostring(b_len - i + 1), 1)
            vim.fn.setline(u, lb_new)
        end

        for j, v in ipairs(f_num_list) do
            local lf_new = vim.fn.getline(v):gsub('%d+', tostring(j + b_len), 1)
            vim.fn.setline(v, lf_new)
        end
    else
        print("Not in a line of any numbered lists.")
    end
end


return M
