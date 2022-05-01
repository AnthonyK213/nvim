local bit = require("bit")
local M = {}


---Get characters around the cursor.
---@return table<string, string> context Context table with keys below:
---  - *p* -> The character before cursor (previous);
---  - *n* -> The character after cursor  (next);
---  - *b* -> The half line before cursor (backward);
---  - *f* -> The half line after cursor  (forward).
function M.get_context()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local back = line:sub(1, col)
    local fore = line:sub(col + 1, #line)
    return {
        b = back,
        f = fore,
        p = M.str_sub(back, -1),
        n = M.str_sub(fore, 1, 1)
    }
end

---Find the root directory contains pattern `pat`.
---@param pat string Root pattern.
---@return string? result Root directory path.
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
    return nil
end

---Get current branch name.
---@param git_root? string Git repository root directory.
---@return string? result Current branch name.
function M.get_git_branch(git_root)
    git_root = git_root or M.get_root(".git")
    if not git_root then return nil end

    git_root = git_root:gsub('[\\/]$', '')

    local head_file
    local dot_git = git_root..'/.git'
    local dot_git_stat = vim.loop.fs_stat(dot_git)

    if dot_git_stat.type == "directory" then
        head_file = git_root..'/.git/HEAD'
    elseif dot_git_stat.type == "file" then
        local gitdir_line = vim.fn.readfile(dot_git)[1]
        if gitdir_line then
            local gitdir = gitdir_line:match('^gitdir:%s(.+)$')
            if gitdir then
                head_file = git_root..'/'..gitdir..'/HEAD'
            end
        end
    end

    if head_file and head_file ~= "" and M.path_exists(head_file) then
        local ref_line = vim.fn.readfile(head_file)[1]
        if ref_line then
            local branch = ref_line:match('^ref:%s.+/(.-)$')
            if branch and branch ~= "" then
                return branch
            end
        end
    end
end

---Get the visual selections.
---@return string result Visual selection.
function M.get_visual_selection()
    local mode = vim.api.nvim_get_mode().mode
    local in_vis = vim.tbl_contains({'v', 'V', ''}, mode)
    local a_bak = vim.fn.getreg('a', 1)
    vim.cmd('silent normal! '..(in_vis and '' or 'gv')..'"ay')
    local a_val = vim.fn.getreg('a')
    vim.fn.setreg('a', a_bak)
    return a_val
end

---Get the word and its position under the cursor.
---@return string word Word under the cursor.
---@return integer start Start index of the line (0-based, included).
---@return integer end End index of the line (0-based, not included).
function M.get_word()
    local context = M.get_context()
    local b = context.b
    local f = context.f
    local s_a, _ = vim.regex([[\v([\u4e00-\u9fff0-9a-zA-Z_-]+)$]]):match_str(b)
    local _, e_b = vim.regex([[\v^([\u4e00-\u9fff0-9a-zA-Z_-])+]]):match_str(f)
    local p_a = ''
    local p_b = ''
    if e_b then
        p_a = s_a and b:sub(s_a + 1) or ''
        p_b = f:sub(1, e_b)
    end
    local word = p_a..p_b
    if word == '' then
        word = context.n
        p_b = word
    end
    return word, #b - #p_a, #b + #p_b
end

---Return number value of the first char in `str`.
---@param str string
---@return integer
function M.str_char2nr(str)
    local char = M.str_sub(str, 1, 1)
    local result
    local seq = 0
    for i = 1, #char do
        local c = string.byte(char, i)
        if seq == 0 then
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
            c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
            error("invalid UTF-8 character.")
            result = bit.band(c, 2 ^ (8 - seq) - 1)
        else
            result = bit.bor(bit.lshift(result, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    return result
end

---String UTF-32 length.
---@param str string
---@return integer
function M.str_len(str)
    local length = vim.str_utfindex(str)
    return length
end

---Get UTF-32 sub-string from a string.
---@see string.sub
---@param str string
---@param i integer
---@param j? integer
---@return string
function M.str_sub(str, i, j)
    local length = vim.str_utfindex(str)
    if i < 0 then i = i + length + 1 end
    if (j and j < 0) then j = j + length + 1 end
    local u = (i > 0) and i or 1
    local v = (j and j <= length) and j or length
    if (u > v) then return "" end
    local s = vim.str_byteindex(str, u - 1)
    local e = vim.str_byteindex(str, v)
    return str:sub(s + 1, e)
end

---Replace chars in a string according to a dictionary.
---@param str string String to replace.
---@param esc_table table<string, string> Replace dictionary.
---@return string result Replaced string.
function M.str_replace(str, esc_table)
    local str_list = M.str_explode(str)
    for i, v in ipairs(str_list) do
        if esc_table[v] then
            str_list[i] = esc_table[v]
        end
    end
    return table.concat(str_list)
end

---Split string into a utfchar table.
---@param str string String to explode.
---@return table result Exploded string table.
function M.str_explode(str)
    local str_len = #str
    local result = {}
    local utf_end = 1
    while utf_end <= str_len do
        local step = vim.str_utf_end(str, utf_end)
        table.insert(result, str:sub(utf_end, utf_end + step))
        utf_end = utf_end + step + 1
    end
    return result
end

---Split string into a utfchar iterator.
---@param str string String to explode.
---@return Iterator result Exploded string iterator.
function M.str_gexplode(str)
    local str_len = #str
    local utf_end = 1
    return function ()
        if utf_end <= str_len then
            local step = vim.str_utf_end(str, utf_end)
            local result = str:sub(utf_end, utf_end + step)
            utf_end = utf_end + step + 1
            return result
        end
    end
end

---Reverse a ipairs table.
---@param tbl table Table to reverse.
---@return table? result Reversed table if reversible.
function M.tbl_reverse(tbl)
    if vim.tbl_islist(tbl) then
        local tmp = {}
        for i = #tbl, 1, -1 do
            table.insert(tmp, tbl[i])
        end
        return tmp
    end
end

---Escape vim regex(magic) special characters in a pattern by `backslash`.
---@param str string String of vim regex to escape.
---@return string result Escaped vim regex.
function M.vim_pesc(str)
    return vim.fn.escape(str, ' ()[]{}<>.+*^$')
end

---Source a vim file.
---@param file string Vim script path.
function M.vim_source(file)
    local full_path = vim.fn.stdpath('config')..'/'..file..'.vim'
    vim.cmd('source '..vim.fn.fnameescape(full_path))
end

---Encode URL.
---@param str string URL string to encode.
---@return string result Encoded url.
function M.encode_url(str)
    local res = str:gsub("([^%w%.%-%s])", function(x)
        return string.format("%%%02X", string.byte(x))
    end):gsub("[\n\r\t%s]", "%%20")
    return res
end

---Match URL in a string.
---@param str string
---@return boolean is_url True if the input `str` is a URL itself.
---@return string url Matched URL.
function M.match_url(str)
    local url_pat = '((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
    local protocols = {
        [''] = 0,
        ['http://'] = 0,
        ['https://'] = 0,
        ['ftp://'] = 0
    }

    local url, prot, dom, colon, port, slash, path = str:match(url_pat)

    if (url
        and not (dom..'.'):find('%W%W')
        and protocols[prot:lower()] == (1 - #slash) * #path
        and (colon == '' or port ~= '' and port + 0 < 65536)) then
        return #url == #str, url
    end

    return false, nil
end

---Create a below right split window.
---@param height number Window height.
function M.belowright_split(height)
    local term_h = math.min(height,
    math.floor(vim.api.nvim_win_get_height(0) * 0.382))
    vim.cmd('belowright new')
    vim.api.nvim_win_set_height(0, term_h)
end

---Check if file/directory exists.
---@param path string File/directory path.
---@param cwd? string The working directory.
---@return boolean
function M.path_exists(path, cwd)
    local is_rel = true
    path = vim.fn.expand(path)
    if M.has_windows() then
        if path:match('^%a:[\\/]') then is_rel = false end
    else
        if path:match('^/') then is_rel = false end
    end
    if is_rel then
        cwd = cwd or vim.loop.cwd()
        cwd = cwd:gsub('[\\/]$', '')
        path = cwd..'/'..path
    end
    local stat = vim.loop.fs_stat(path)
    return (stat and stat.type) or false
end

---Os types enum.
---@class Os
M.Os = {
    UNKNOWN = 0,
    LINUX = 1,
    WINDOWS = 2,
    MACOS = 3
}

---Get OS type.
---@return Os
function M.get_os_type()
    local name = vim.loop.os_uname().sysname
    if name == 'Linux' then
        return M.Os.LINUX
    elseif name == 'Windows_NT' then
        return M.Os.WINDOWS
    elseif name == 'Darwin' then
        return M.Os.MACOS
    else
        return M.Os.UNKNOWN
    end
end

---Check if os is `Windows`.
---@return boolean result
function M.has_windows()
    return M.get_os_type() == M.Os.WINDOWS
end

---Notify the error message to neovim.
---@param err string Error message.
function M.notify_err(err)
    vim.notify(err, vim.log.levels.ERROR, nil)
end

---Use `pcall()` to catch error and display it.
---@param func function The function to test.
---@param ... any Function arguments.
function M.try(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        local msg = err:match('(E%d+:%s.+)$')
        M.notify_err(msg and msg or "Error occured!")
    end
end

---Check if executable exists.
---@param exe string Executable name.
---@return boolean
function M.executable(exe)
    if vim.fn.executable(exe) == 1 then return true end
    M.notify_err('Executable '..exe..' is not found.')
    return false
end

---Escape the termianl codes then feed keys to nvim.
---@see vim.api.nvim_feedkeys
---@param keys string
---@param mode string
---@param escape_ks boolean
function M.feedkeys(keys, mode, escape_ks)
    local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(k, mode, escape_ks)
end

---Check if current filetype has `filetype`.
---@param filetype string
---@return boolean result
function M.has_filetype(filetype)
    return vim.tbl_contains(vim.split(vim.bo.ft, '%.'), filetype)
end


return M
