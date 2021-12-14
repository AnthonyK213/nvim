local M = {}


-- Create a below right split window.
function M.belowright_split(height)
    local term_h = math.min(height,
    math.floor(vim.api.nvim_win_get_height(0) * 0.382))
    vim.cmd('belowright split')
    vim.cmd('resize '..tostring(term_h))
end

-- Return the <cWORD> without the noisy characters.
function M.get_clean_cWORD(del_list)
    local c_word = M.str_explode(vim.fn.expand("<cWORD>"))
    while vim.tbl_contains(del_list, c_word[#c_word]) and #c_word >= 2 do
        table.remove(c_word, #c_word)
    end
    while vim.tbl_contains(del_list, c_word[1]) and #c_word >= 2 do
        table.remove(c_word, 1)
    end
    return table.concat(c_word)
end

-- Find the root directory contains pattern `pat`.
function M.get_root(pat)
    local current_dir = vim.fn.expand('%:p:h')
    while true do
        if vim.fn.globpath(current_dir, pat, 1) ~= '' then
            return current_dir
        end
        local temp_dir = current_dir
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
        if temp_dir == current_dir then break end
    end
    return false
end

-- Get the branch name.
function M.get_git_branch(git_root)
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
local get_context_pat = {
    p = { [[.\%]], [[c]] },
    n = { [[\%]], [[c.]] },
    b = { [[^.*\%]], 'c' },
    f = { [[\%]], 'c.*$' }
}

function M.get_context(mode)
    local pat = get_context_pat[mode]
    local line = vim.api.nvim_get_current_line()
    local s, e = vim.regex(
    pat[1]..(vim.api.nvim_win_get_cursor(0)[2] + 1)..pat[2]):match_str(line)
    if s then
        return line:sub(s + 1, e)
    else
        return ""
    end
end

-- Replace chars in a string according to a dictionary.
function M.str_escape(str, esc_table)
    local str_list = M.str_explode(str)
    for i, v in ipairs(str_list) do
        if esc_table[v] then
            str_list[i] = esc_table[v]
        end
    end
    return table.concat(str_list)
end

-- Split string at '\zs'.
function M.str_explode(str)
    local result = {}
    while true do
        ::str_explode_loop::
        local len = str:len()
        for i = 1, len, 1 do
            local u_index = vim.str_utfindex(str, i)
            if u_index ~= 1 then
                table.insert(result, str:sub(1, i - 1))
                str = str:sub(i)
                goto str_explode_loop
            end
        end
        table.insert(result, str)
        break
    end
    return result
end

-- Escape vim regex(magic) special characters in a string by '\'.
function M.vim_reg_esc(str)
    return vim.fn.escape(str, ' ()[]{}<>.+*^$')
end

-- Return the selections.
function M.get_visual_selection()
    local a_bak = vim.fn.getreg('a', 1)
    vim.cmd('silent normal! gv"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

-- Reverse a ipairs table.
function M.tbl_reverse(tbl)
    local tmp = {}
    for i = #tbl, 1, -1 do
        table.insert(tmp, tbl[i])
    end
    return tmp
end

-- Define auto command group.
function M.set_augroup(name, ...)
    vim.cmd('augroup '..name)
    vim.cmd('autocmd!')
    for _, cmd in ipairs({...}) do
        vim.cmd('au '..cmd)
    end
    vim.cmd('augroup end')
end

-- Define highlight group.
function M.set_highlight_group(group, fg, bg, attr)
    local cmd = "highlight! "..group
    if fg   then cmd = cmd.." guifg="..fg end
    if bg   then cmd = cmd.." guibg="..bg end
    if attr then cmd = cmd.." gui="..attr end
    vim.cmd(cmd)
end

-- Source vim file.
function M.vim_source(file)
    local init_viml_path
    if vim.fn.has("win32") == 1 then
        init_viml_path = vim.fn.expand("$LOCALAPPDATA/nvim/")
    elseif vim.fn.has("unix") == 1 then
        init_viml_path = vim.fn.expand('$HOME/.config/nvim/')
    end
    vim.cmd('source '..init_viml_path..file..'.vim')
end

-- Encode URL.
function M.encode_url(str)
    local res = str:gsub("([^%w%.%-%s])", function(x)
        return string.format("%%%02X", string.byte(x))
    end):gsub(" ", "%%20")
    return res
end


return M
