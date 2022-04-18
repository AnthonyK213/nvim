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

---Get the branch name.
---@param git_root string Git repository root directory.
---@return string? result Current branch name.
function M.get_git_branch(git_root)
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
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end

    if head_file ~= "" and M.path_exists(head_file) then
        local ref_line = vim.fn.readfile(head_file)[1]
        if ref_line then
            local branch = ref_line:match('^ref:%s.+/(.-)$')
            if branch and branch ~= '' then
                return branch
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
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
            result = bit.band(c, 2 ^ ( 8 - seq) - 1)
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
    local len = #str
    local utf_end = 1
    return function ()
        if utf_end <= len then
            local step = vim.str_utf_end(str, utf_end)
            local result = str:sub(utf_end, utf_end + step)
            utf_end = utf_end + step + 1
            return result
        end
    end
end

---Reverse a ipairs table.
---@param tbl table Table to reverse.
---@return table result Reversed table.
function M.tbl_reverse(tbl)
    local tmp = {}
    for i = #tbl, 1, -1 do
        table.insert(tmp, tbl[i])
    end
    return tmp
end

---Define highlight group.
---@param group string Group name.
---@param fg string Foreground color.
---@param bg string Background color.
---@param attr string Attribute('bold', 'italic', 'underline', ...)
function M.set_highlight_group(group, fg, bg, attr)
    local cmd = "highlight! "..group
    if fg   then cmd = cmd.." guifg="..fg end
    if bg   then cmd = cmd.." guibg="..bg end
    if attr then cmd = cmd.." gui="..attr end
    vim.cmd(cmd)
end

---Escape vim regex(magic) special characters in a string by `backslash`.
---@param str string String of vim regex to escape.
---@return string result Escaped vim regex.
function M.vim_reg_esc(str)
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

---Syntax structure.
---@class Syntax
---@field prov string
---@field data table
local Syntax = {}

Syntax.__index = Syntax

---Constructor.
---@param provider string Provider name.
---@param data table Data table.
---@return Syntax
function Syntax:new(provider, data)
    local o = { prov = provider, data = data }
    setmetatable(o, Syntax)
    return o
end

---Get hilight group name.
---@return string name Hilight group name.
function Syntax:name()
    if self.prov == 'syn' then
        return vim.fn.synIDattr(self.data[2], "name")
    elseif self.prov == 'ts' then
        return self.data[3]
    else
        return nil
    end
end

---Show syntax information.
---@return string result Markdown style information.
function Syntax:show()
    if self.prov == 'syn' then
        local n1 = vim.fn.synIDattr(self.data[1], "name")
        local n2 = vim.fn.synIDattr(self.data[2], "name")
        return "* "..n1.." -> **"..n2.."**"
    elseif self.prov == 'ts' then
        local c, hl, general_hl, metadata = unpack(self.data)
        local line = "* **@"..c.."** -> "..hl
        if general_hl ~= hl then
            line = line.." -> **"..general_hl.."**"
        end
        if metadata.priority then
            line = line.." *(priority "..metadata.priority..")*"
        end
        return line
    else
        return nil
    end
end

---Get syntax stack.
---@param row number 1-based row number.
---@param col number 0-based column number.
---@return Syntax[] result Syntax table.
function M.get_syntax_stack(row, col)
    local syntax_table = {}
    for _, i1 in ipairs(vim.fn.synstack(row, col + 1)) do
        local i2 = vim.fn.synIDtrans(i1)
        table.insert(syntax_table, Syntax:new('syn', { i1, i2 }))
    end
    return syntax_table
end

---Get treesitter information.
---https://github.com/nvim-treesitter/playground
---@param row number 1-based row number.
---@param col number 0-based column number.
---@return Syntax[] result Syntax table.
function M.get_treesitter_info(row, col)
    local buf = vim.api.nvim_get_current_buf()
    local row_0 = row - 1

    local self = vim.treesitter.highlighter.active[buf]

    if not self then return {} end

    local syntax_table = {}

    self.tree:for_each_tree(function(tstree, tree)
        if not tstree then return end

        local root = tstree:root()
        local root_start_row, _, root_end_row, _ = root:range()

        -- Only worry about trees within the line range
        if root_start_row > row_0 or root_end_row < row_0 then return end

        local query = self:get_query(tree:lang())

        -- Some injected languages may not have highlight queries.
        if not query:query() then return end

        local iter = query:query():iter_captures(root, self.bufnr, row_0, row)

        for capture, node, metadata in iter do
            local hl = query.hl_cache[capture]

            local is_in_node_range
            local start_row, start_col, end_row, end_col = node:range()
            if row_0 >= start_row and row_0 <= end_row then
                if row_0 == start_row and row_0 == end_row then
                    is_in_node_range = col >= start_col and col < end_col
                elseif row_0 == start_row then
                    is_in_node_range = col >= start_col
                elseif row_0 == end_row then
                    is_in_node_range = col < end_col
                else
                    is_in_node_range = true
                end
            else
                is_in_node_range = false
            end

            if hl and is_in_node_range then
                -- Name of the capture in the query
                local c = query._query.captures[capture]
                if c then
                    local general_hl = query:_get_hl_from_capture(capture)
                    table.insert(syntax_table, Syntax:new('ts', {
                        c, hl, general_hl, metadata
                    }))
                end
            end
        end
    end, true)
    return syntax_table
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


return M
