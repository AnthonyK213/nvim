local M = {}
-- lua-language-server wtf: [[\一]] -> [[\一]] ???
local _p_word_first_half = [[\v([\]] .. [[u4e00-\]] .. [[u9fff0-9a-zA-Z_-]+)$]]
local _p_word_last_half = [[\v^([\]] .. [[u4e00-\]] .. [[u9fff0-9a-zA-Z_-])+]]

---Os types enum.
---@enum Os
M.Os = {
    Unknown = 0,
    Linux = 1,
    Windows = 2,
    Macos = 3,
}

---Convert `integer` to a binary string.
---(`new_work` invocable)
---@param x integer Integer to be converted.
---@param n? integer Limit of bits.
---@return string digits String of binary digits.
function M.bit_tobin(x, n)
    local digits = ""
    if x <= -1 then
        x = -x
        digits = digits .. "-"
    elseif x < 1 then
        return (n and n >= 1) and string.rep("0", n) or "0"
    end
    n = (n and n >= 1) and n - 1 or math.floor(math.log(x, 2))

    for i = n, 0, -1 do
        local current_power = 2 ^ i
        if x >= current_power then
            digits = digits .. "1"
            x = x - current_power
        else
            digits = digits .. "0"
        end
    end

    return digits
end

---Check if executable exists.
---@param exe string Executable name.
---@return boolean is_executable True if `exe` is a valid executable.
function M.executable(exe)
    if vim.fn.executable(exe) == 1 then return true end
    M.notify_err("Executable " .. exe .. " is not found.")
    return false
end

---Escape the termianl codes then feed keys to nvim.
---@see vim.api.nvim_feedkeys
---@param keys string To be typed.
---@param mode string Behavior flags, see **feedkeys()**.
---@param escape_ks boolean If true, escape K_SPECIAL bytes in `keys`.
function M.feedkeys(keys, mode, escape_ks)
    local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(k, mode, escape_ks)
end

---Get the directory of the buffer with bufnr.
---@param bufnr? integer Buffer number, default 0 (current buffer).
---@return string buf_dir Buffer directory.
function M.get_buf_dir(bufnr)
    bufnr = bufnr or 0
    return vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

---Get characters around the cursor.
---@return { b: string, f: string, p: string, n: string } context
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

---Get dynamic library extension.
---(`new_work` invocable)
---@return string?
function M.get_dylib_ext()
    return ({
        [M.Os.Windows] = ".dll",
        [M.Os.Linux] = ".so",
        [M.Os.Macos] = ".so",
    })[M.get_os_type()]
end

---Get dynamic library path in data/dylib/.
---@param dylib_name string
---@return string?
function M.get_dylib_path(dylib_name)
    local dylib_ext = M.get_dylib_ext()
    if not dylib_ext then
        M.notify_err("Unsupported OS.")
        return
    end
    local dylib_dir = _my_core_opt.path.dylib
    local dylib_file = dylib_name .. dylib_ext
    local dylib_path = M.path_append(dylib_dir, dylib_file)
    if not M.path_exists(dylib_path) then
        M.notify_err(dylib_file .. " is not found.")
        return
    end
    return dylib_path
end

---Get current branch name.
---@param git_root? string Git repository root directory.
---@return string? result Current branch name.
function M.get_git_branch(git_root)
    git_root = git_root or M.get_root([[^\.git$]], "directory")
    if not git_root then return end
    local head_file = M.path_append(git_root, "/.git/HEAD")
    local file = io.open(head_file)
    if file then
        local gitdir_line = file:read("*l")
        file:close()
        if gitdir_line then
            local branch = gitdir_line:match("^ref:%s.+/([^%s]-)$")
            if branch and #branch > 0 then
                return branch
            end
        end
    end
end

---Gets the current list of listed buffer handles.
---@return integer[] bufs Loaded buffer handles.
function M.get_listed_bufs()
    return vim.tbl_filter(function(h)
        return vim.api.nvim_buf_is_loaded(h) and vim.bo[h].buflisted
    end, vim.api.nvim_list_bufs())
end

---Get path of the dotfile (.nvimrc, etc.).
---Searching order: stdpath("config") -> home -> ...
---Use the last one was found.
---@param name string Name of the dotfile (with out '.' or '\_' at the start).
---@return boolean exists True if the option file exists.
---@return string? path Path of the option file.
function M.get_dotfile(name)
    local dir_table = {
        vim.fn.stdpath("config"),
        vim.loop.os_homedir(),
    }
    local ok_index = 0
    local file_name
    for i, dir in ipairs(dir_table) do
        if dir then
            ok_index = i
            file_name = "/." .. name
            local file_path = dir .. file_name
            if M.path_exists(file_path) then
                return true, file_path
            elseif M.has_windows() then
                file_name = "/_" .. name
                file_path = dir .. file_name
                if M.path_exists(file_path) then
                    return true, file_path
                end
            end
        end
    end
    if ok_index > 0 then
        return false, dir_table[ok_index] .. file_name
    else
        return false, nil
    end
end

---Get the visual selections (`gv`).
---@return string result Visual selection.
function M.get_gv()
    local mode = vim.api.nvim_get_mode().mode
    local in_vis = vim.tbl_contains({ "v", "V", "" }, mode)
    local a_bak = vim.fn.getreg("a", 1)
    vim.cmd.normal {
        (in_vis and "" or "gv") .. [["ay]],
        mods = {
            silent = true
        }
    }
    local a_val = vim.fn.getreg("a")
    vim.fn.setreg("a", a_bak)
    return a_val
end

---Get the start and end positions (zero-based) of visual selection.
---@param bufnr? integer Buffer number, default 0 (current buffer).
---@return integer row_s Start row.
---@return integer col_s Start column.
---@return integer row_e End row.
---@return integer col_e End column.
function M.get_gv_mark(bufnr)
    bufnr = bufnr or 0
    local s = vim.api.nvim_buf_get_mark(bufnr, "<")
    local e = vim.api.nvim_buf_get_mark(bufnr, ">")
    local l = #vim.api.nvim_buf_get_lines(bufnr, e[1] - 1, e[1], true)[1]
    if e[2] >= l then e[2] = math.max(0, l - 1) end
    local d = #M.str_sub(vim.api.nvim_buf_get_text(bufnr, e[1] - 1, e[2], e[1] - 1, -1, {})[1], 1, 1)
    return s[1] - 1, s[2], e[1] - 1, e[2] + d
end

---Get OS type.
---(`new_work` invocable)
---@return Os os_type_enum Type of current operating system.
function M.get_os_type()
    local name = vim.loop.os_uname().sysname
    if name == "Linux" then
        return M.Os.Linux
    elseif name == "Windows_NT" then
        return M.Os.Windows
    elseif name == "Darwin" then
        return M.Os.Macos
    else
        return M.Os.Unknown
    end
end

---Find the root directory contains `pattern`.
---@param pattern string Root pattern (vim regex in `magic` mode).
---@param item_type? "directory"|"file" Type of the item to find.
---@return string? result Root directory path.
function M.get_root(pattern, item_type)
    if item_type and not (item_type == "file" or item_type == "directory") then
        M.notify_err [[Type must be "file" or "directory".]]
        return
    end

    local re = vim.regex("\\v" .. pattern)

    local result = vim.fs.find(function(name)
        return re:match_str(name) and true or false
    end, {
        path = M.get_buf_dir(),
        upward = true,
        type = item_type,
        limit = 1,
    })

    if not vim.tbl_isempty(result) then
        return vim.fs.dirname(result[1])
    end
end

---Get the word and its position under the cursor.
---@return string word Word under the cursor.
---@return integer start_column Start index of the line (0-based, included).
---@return integer end_column End index of the line (0-based, not included).
function M.get_word()
    local context = M.get_context()
    local b = context.b
    local f = context.f
    local s_a, _ = vim.regex(_p_word_first_half):match_str(b)
    local _, e_b = vim.regex(_p_word_last_half):match_str(f)
    local p_a = ""
    local p_b = ""
    if e_b then
        p_a = s_a and b:sub(s_a + 1) or ""
        p_b = f:sub(1, e_b)
    end
    local word = p_a .. p_b
    if word == "" then
        word = context.n
        p_b = word
    end
    return word, #b - #p_a, #b + #p_b
end

---Check if `filetype` has `dst`.
---@param dst string Destination file type.
---@param filetype? string File type to be checked, default *filetype* of current buffer.
---@return boolean result True if `filetype` has `dst`.
function M.has_filetype(dst, filetype)
    filetype = filetype or vim.bo.filetype
    if not filetype then return false end
    return vim.tbl_contains(vim.split(filetype, "%."), dst)
end

---Check if os is **Windows**.
---(`new_work` invocable)
---@return boolean result True if current os is **Windows**.
function M.has_windows()
    return M.get_os_type() == M.Os.Windows
end

---Decode json from file path.
---(`new_work` invocable)
---@param path string Path of file to decode.
---@param strictly? boolean If false, try to ignore comment lines, possibly including trailing commas(discouraged).
---@return 0|1|2 code Code, 0: ok, 1: json is invalid, 2: file does not exist.
---@return table? result Decode result.
function M.json_decode(path, strictly)
    local content = M.read_all_text(path)
    if not content then return 2, nil end

    ---@type (fun(chunk:string):string)[]
    local filters = {
        ---Remove comment lines.
        ---@param chunk string
        ---@return string
        function(chunk)
            local lines = vim.split(chunk, "[\n\r]", {
                plain = false,
                trimempty = true,
            })
            return table.concat(vim.tbl_filter(function(v)
                if vim.startswith(vim.trim(v), "//") then
                    return false
                end
                return true
            end, lines))
        end,
        ---Remove trailing commas.
        ---@param chunk string
        ---@return string
        ---@return integer
        function(chunk)
            return chunk:gsub(",%s*([%]%}])", "%1")
        end,
    }

    local ok, result;
    local i = 0;
    local n = #filters

    while true do
        ok, result = pcall(vim.json.decode, content)
        if ok then
            return 0, result
        elseif strictly or i == n then
            break
        end
        i = i + 1
        content = filters[i](content)
    end

    return 1, nil
end

---Create a new split window.
---@param position "aboveleft"|"belowright"|"topleft"|"botright"
---@param option? { split_size: integer, ratio_max: number, vertical: boolean, hide_number: boolean } Split options:
---  - *split_size*: Split size;
---  - *ratio_max*: real_split_size <= real_win_size \* ratio_max;
---  - *vertical*: If true, split vertically.
---  - *hide_number*: If true, hide line number in split window.
---@return boolean ok True if split window successfully.
---@return integer winnr New split window number, -1 on failure.
---@return integer bufnr New split buffer number, -1 on failure.
function M.new_split(position, option)
    option = option or {}
    if not vim.tbl_contains({
        "aboveleft", "belowright", "topleft", "botright"
    }, position) then
        print(position)
        M.notify_err("Invalid position.")
        return false, -1, -1
    end
    local vertical = option.vertical
    if type(vertical) ~= "boolean" then
        vertical = false
    end
    local size_this = vertical and vim.api.nvim_win_get_height(0) or vim.api.nvim_win_get_width(0)
    local split_size = option.split_size
    if type(split_size) ~= "number" or split_size <= 0 then
        split_size = 15
    end
    local ratio_max = option.ratio_max
    if type(ratio_max) ~= "number" or ratio_max <= 0 or ratio_max >= 1 then
        ratio_max = 0.382
    end
    local hide_number = option.hide_number
    if type(hide_number) ~= "boolean" then
        hide_number = true
    end
    local term_size = math.min(split_size, math.floor(size_this * ratio_max))
    vim.cmd.new {
        mods = {
            split = position,
            vertical = vertical,
        }
    }
    if hide_number then
        vim.api.nvim_win_set_option(0, "number", false)
    end
    if vertical then
        vim.api.nvim_win_set_width(0, term_size)
    else
        vim.api.nvim_win_set_height(0, term_size)
    end
    return true, vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
end

---Notify the error message.
---@param err string Error message.
function M.notify_err(err)
    vim.notify(err, vim.log.levels.ERROR, nil)
end

---Parse the argument part of a command.
---(`new_work` invocable)
---@param cmd_args string Argument part of a command.
---@return table<string, string> result Table of "parameter: argument".
function M.parse_args(cmd_args)
    local pos = {}
    local result = {}
    local cmd_args_spc = " " .. cmd_args .. " "
    local iter = cmd_args_spc:gmatch("%s+()(-+%w+)()%s+")
    for s, v, e in iter do
        table.insert(pos, { s, v, e })
    end
    for i, item in ipairs(pos) do
        local _end = i == #pos and #cmd_args_spc or pos[i + 1][1] - 1
        local value = vim.trim(cmd_args_spc:sub(item[3], _end))
        if #value > 0 then
            result[item[2]] = value
        end
    end

    return result
end

---Append file/directory/sub-path to a path.
---@param path string Path to be appended.
---@param item string Item to append to the path.
---@return string
function M.path_append(path, item)
    local path_trim = path:gsub("[\\/]+$", "")
    local item_trim = item:gsub("^[\\/]+", "")
    return vim.fs.normalize(path_trim .. "/" .. item_trim)
end

---Check if file/directory exists.
---@param path string File/directory path.
---@param cwd? string The working directory.
---@return boolean exists True if path exists.
---@return string? full_path
function M.path_exists(path, cwd)
    if type(path) ~= "string" then return false, nil end
    local is_rel = true
    local _path = vim.fs.normalize(path)
    if M.has_windows() then
        if _path:match("^%a:[\\/]") then is_rel = false end
    else
        if _path:match("^/") then is_rel = false end
    end
    if is_rel then
        _path = M.path_append(cwd or vim.loop.cwd(), _path)
    end
    local stat = vim.loop.fs_stat(_path)
    return (stat and stat.type) or false, _path
end

---Opens a text file, reads all the text in the file into a string,
---and then closes the file.
---@param path string The file to open for reading.
---@return string? content A string containing all the text in the file.
function M.read_all_text(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
end

---Return number value of the first char in `str`.
---@param str string
---@return integer
function M.str_char2nr(str)
    if #str == 0 then return 0 end
    local char = M.str_sub(str, 1, 1)
    local result
    ---@type integer?
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

---Split string into a utfchar table.
---@param str string String to explode.
---@return string[] result Exploded string list.
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
---@return fun():string|nil result Exploded string iterator.
function M.str_gexplode(str)
    local str_len = #str
    local utf_end = 1
    return function()
        if utf_end <= str_len then
            local step = vim.str_utf_end(str, utf_end)
            local result = str:sub(utf_end, utf_end + step)
            utf_end = utf_end + step + 1
            return result
        end
    end
end

---String length in unicode.
---@param str string
---@return integer length Length of the unicode string.
function M.str_len(str)
    return vim.str_utfindex(str)
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

---Returns the Unicode substring of the string that starts at `i` and continues until `j`.
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

---Find the first item with the value `val`.
---(`new_work` invocable)
---@param tbl any[] A list-like table.
---@param val any Value to find.
---@return integer index The first index of value `val`, 0 for not found.
function M.tbl_find_first(tbl, val)
    if vim.tbl_islist(tbl) then
        for i, v in ipairs(tbl) do
            if v == val then
                return i
            end
        end
    end
    return 0
end

---Find the last item with the value `val`.
---(`new_work` invocable)
---@param tbl any[] A list-like table.
---@param val any Value to find.
---@return integer index The last index of value `val`, 0 for not found.
function M.tbl_find_last(tbl, val)
    if vim.tbl_islist(tbl) then
        for i = #tbl, 1, -1 do
            if tbl[i] == val then
                return i
            end
        end
    end
    return 0
end

---Inserts element `value` at position `pos` in the packed table `pack`.
---@param pack table
---@param pos integer
---@param value any
function M.tbl_insert(pack, pos, value)
    for i = pack.n, pos, -1 do
        pack[i + 1] = pack[i]
    end
    pack[pos] = value
    pack.n = pack.n + 1
end

---@see table.pack https://www.lua.org/manual/5.4/manual.html#pdf-table.pack
---@param ... any
---@return table
function M.tbl_pack(...)
    local pack = {}
    local n = select("#", ...)
    for i = 1, n do
        local v = select(i, ...)
        pack[i] = v
    end
    pack.n = n
    return pack
end

---Reverse a ipairs table.
---(`new_work` invocable)
---@param tbl table Table to reverse.
---@return table result Reversed table if reversible.
function M.tbl_reverse(tbl)
    if vim.tbl_islist(tbl) then
        local tmp = {}
        for i = #tbl, 1, -1 do
            table.insert(tmp, tbl[i])
        end
        return tmp
    end
    return tbl
end

---Unpack a packed table.
---@param pack table Packed table.
---@param i? integer
function M.tbl_unpack(pack, i)
    return unpack(pack, i or 1, pack.n)
end

---Use **pcall()** to catch error and display it.
---@param func function The function to test.
---@param ... any Function arguments.
---@return boolean ok True if error free.
function M.try(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        local msg = err:match("(E%d+:%s.+)$")
        M.notify_err(msg and msg or "Error occured!")
    end
    return ok
end

---Encode `str` into URL format.
---(`new_work` invocable)
---@param str string URL string to encode.
---@return string result Encoded url.
function M.url_encode(str)
    local result = str:gsub("([^%w%.%-%s])", function(x)
        return string.format("%%%02X", string.byte(x))
    end):gsub("[\n\r\t%s]", "%%20")
    return result
end

---Match URL inside a string.
---(`new_work` invocable)
---@param str string String to be matched.
---@return boolean is_url True if the input `str` is a URL itself.
---@return string? url Matched URL.
function M.url_match(str)
    local url_pat = "((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"
    local protocols = {
        [""] = 0,
        ["http://"] = 0,
        ["https://"] = 0,
        ["ftp://"] = 0
    }

    local url, prot, dom, colon, port, slash, path = str:match(url_pat)

    if (url
        and not (dom .. "."):find("%W%W")
        and protocols[prot:lower()] == (1 - #slash) * #path
        and (colon == "" or port ~= "" and port + 0 < 65536)) then
        return #url == #str, url
    end

    return false, nil
end

---Escape vim regex(magic) special characters in a pattern by **backslash**.
---@param str string String of vim regex to escape.
---@return string result Escaped vim regex.
function M.vim_pesc(str)
    return vim.fn.escape(str, " ()[]{}<>.+*^$")
end

---Source a vim file.
---@param file string Vim script path.
function M.vim_source(file)
    local full_path = vim.fn.stdpath("config") .. "/" .. file .. ".vim"
    if M.path_exists(full_path) then
        vim.cmd.source(full_path)
    else
        M.notify_err("File `" .. file .. ".vim` is not found")
    end
end

return M
