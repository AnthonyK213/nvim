local M = {}


-- Get global variable.
function M.get_var(get_var, set_var)
    if get_var ~= nil then return get_var else return set_var end
end

-- Create a below right split window.
function M.belowright_split(height)
    local term_h = math.min(height,
    math.floor(vim.api.nvim_win_get_height(0) / 2))
    vim.fn.execute('belowright split')
    vim.fn.execute('resize '..tostring(term_h))
end

-- Return the <cWORD> without the noisy characters.
function M.get_clean_cWORD(del_list)
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
function M.get_git_root()
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
function M.get_context(mode)
    if mode == 'l' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line('.'),
        '.\\%'..vim.fn.col('.')..'c')
    elseif mode == 'n' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line('.'),
        '\\%'..vim.fn.col('.')..'c.')
    elseif mode == 'b' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line('.'),
        '^.*\\%'..vim.fn.col('.')..'c')
    elseif mode == 'f' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line('.'),
        '\\%'..vim.fn.col('.')..'c.*$')
    end
end

-- Replace chars in a string according to a dictionary.
function M.str_escape(str, esc_table)
    local str_list = vim.fn.split(str, '\\zs')
    for i, v in ipairs(str_list) do
        if esc_table[v] then
            str_list[i] = esc_table[v]
        end
    end
    return table.concat(str_list)
end

-- Escape lua regex special characters in a string by '%'.
function M.lua_reg_esc(str)
    local str_list = vim.fn.split(str, '\\zs')
    local esc_table = {
        '(', ')', '[', ']',
        '+', '-', '*', '?',
        '.', '%', '^', '$'
    }
    for i, v in ipairs(str_list) do
        if vim.fn.index(esc_table, v) >= 0 then
            str_list[i] = '%'..v
        end
    end
    return table.concat(str_list)
end

-- Escape vim regex(magic) special characters in a string by '\'.
function M.vim_reg_esc(str)
    return vim.fn.escape(str, ' ()[]{}<>.+*^$')
end

-- Return the selections.
function M.get_visual_selection()
    local a_bak = vim.fn.getreg('a', 1)
    vim.fn.execute('normal! gv"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

-- Mapping a function to table.
function M.map(f, t)
    local t2 = {}
    for key, val in pairs(t) do t2[key] = f(val) end
    return t2
end

-- Define auto command group.
function M.set_au_group(name, ...)
    vim.cmd('augroup '..name)
    vim.cmd('autocmd!')
    for _, cmd in ipairs({...}) do
        vim.cmd('au '..cmd)
    end
    vim.cmd('augroup end')
end


return M
