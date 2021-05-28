local M = {}


-- Create a below right split window.
function M.belowright_split(height)
    local term_h = math.min(height,
    math.floor(vim.api.nvim_win_get_height(0) / 2))
    vim.cmd('belowright split')
    vim.cmd('resize '..tostring(term_h))
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
        vim.api.nvim_get_current_line(),
        '.\\%'..vim.fn.col('.')..'c')
    elseif mode == 'n' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line(),
        '\\%'..vim.fn.col('.')..'c.')
    elseif mode == 'b' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line(),
        '^.*\\%'..vim.fn.col('.')..'c')
    elseif mode == 'f' then
        return vim.fn.matchstr(
        vim.api.nvim_get_current_line(),
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
    vim.cmd('silent normal! gv"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

-- Reverse a ipairs table.
function M.reverse(tab)
    local tmp = {}
    for i = #tab, 1, -1 do
        table.insert(tmp, tab[i])
    end
    return tmp
end

-- Mapping a function to table.
function M.map(tab, func)
    local res = {}
    for key, val in pairs(tab) do res[key] = func(val) end
    return res
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

-- Define highlight group.
function M.set_highlight_group(group, fg, bg, attr)
    local cmd = "highlight! "..group
    if fg   then cmd = cmd.." guifg="..fg end
    if bg   then cmd = cmd.." guibg="..bg end
    if attr then cmd = cmd.." gui="..attr end
    vim.cmd(cmd)
end

-- source vim file.
function M.vim_source(file)
    local init_viml_path
    if vim.fn.has("win32") == 1 then
        init_viml_path = vim.fn.expand("$LOCALAPPDATA/nvim/")
    elseif vim.fn.has("unix") == 1 then
        init_viml_path = vim.fn.expand('$HOME/.config/nvim/')
    end
    vim.cmd('source '..init_viml_path..file..'.vim')
end


return M
