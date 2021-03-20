-- File:       lua-pairs.lua
-- Repository: https://github.com/AnthonyK213/nvim
-- License:    The MIT License (MIT)


local M = {}
local vim = vim
local api = vim.api
local fn  = vim.fn

local opt = {}
local lp_comm={ ["("]=")", ["["]=']', ["{"]="}", ["'"]="'", ['"']='"' }


---------- Local functions ---------

-- Extend table b to a.
-- @tparam table a Table to be extended
-- @tparam table a Table to extend
-- @treturn nil
local tab_extd = function(a, b) for key, val in pairs(b) do a[key] = val end end

-- Convert string to terminal codes.
-- @tparam string str String to be converted
-- @treturn string Converted string, can be used as termianl code.
local rep_term = function(str) return api.nvim_replace_termcodes(str, true, false, true) end

-- Feed keys to current buffer.
-- @tparam string str Operation as string to feed to buffer.
-- @treturn nil
local feed_keys = function(str) api.nvim_feedkeys(rep_term(str), 'n', true) end

-- Determine if a character is a numeric/alphabetic/Chinese(NAC) character.
-- @tparam string(char) char A character to be tested
-- @treturn bool True if the character is a NAC
local function is_NAC(char)
    local nr = fn.char2nr(char)
    return char:match('[%w_]') or (nr >= 0x4E00 and nr <= 0x9fA5)
end

-- Escape regex special characters in a string by '%'.
-- @tparam string str String to be converted which can be use in a regex match patern
-- @treturn string Converted string
local function reg_esc(str)
    local str_list = vim.fn.split(str, '\\zs')
    local esc_table = { '(', ')', '[', ']', '.', '%', '+', '-', '*', '?', '^', '$' }
    for i,v in ipairs(str_list) do
        if fn.index(esc_table, v) >= 0 then
            str_list[i] = '%'..v
        end
    end
    return table.concat(str_list)
end

-- Get characters around the cursor by 'mode'.
-- @tparam string mode Four mode to get the context
--   'l' -> Return the character before cursor
--   'n' -> Return the character after cursor
--   'b' -> Return the half line before cursor
--   'f' -> Return the half line after cursor
-- @treturn string Grabbed string around the cursor
local function get_ctxt(mode)
    if mode == 'l' then
        return fn.matchstr(api.nvim_get_current_line(), '.\\%'..fn.col('.')..'c')
    elseif mode == 'n' then
        return fn.matchstr(api.nvim_get_current_line(), '\\%'..fn.col('.')..'c.')
    elseif mode == 'b' then
        return fn.matchstr(api.nvim_get_current_line(), '^.*\\%'..fn.col('.')..'c')
    elseif mode == 'f' then
        return fn.matchstr(api.nvim_get_current_line(), '\\%'..fn.col('.')..'c.*$')
    end
end

-- Define the buffer variables.
-- @bufvar string     b:lp_last_spec If the last character matches, no pairing event triggered.
-- @bufvar string     b:lp_next_spec If the next character matches, no pairing event triggered.
-- @bufvar string     b:lp_back_spec If the half line after the cursor matches, do not trigger.
-- @bufvar hashtable  b:lp_buf       { (string)pair_left = (string)pair_right }
-- @bufvar hashtable  b:lp_buf_map   { (string)key = (string)pair_type }
--   `pair_type`:
--     'enter' -> Enter/Return
--     'backs' -> Backspace
--     'supbs' -> Super backspace
--     'space' -> Space
--     'mates' -> A pair of characters consisting of different characters
--     'quote' -> A pair of characters consisting of identical characters
--     'close' -> Character to close a pair (right part of a pair)
-- @bufvar arraytable b:lp_map_list  { (string)keys_to_map }
-- @treturn nil
local function def_var()
    vim.b.lp_last_spec = "[\"'\\]"
    vim.b.lp_next_spec = "[\"']"
    vim.b.lp_back_spec = "[^%s%S]"
    local lp_buf = fn.copy(lp_comm)
    local lp_buf_map = {
        ["<CR>"]    = "enter",
        ["<BS>"]    = "backs",
        ["<M-BS>"]  = "supbs",
        ["<SPACE>"] = "space"
    }
    local lp_map_list = { "(", "[", "{", ")", "]", "}", "'", '"' }

    if vim.bo.filetype == 'vim' then
        vim.b.lp_back_spec = '^%s*$'
    elseif vim.bo.filetype == 'rust' then
        vim.b.lp_last_spec = "[\"'\\&<]"
    elseif vim.bo.filetype == 'lisp' then
        table.insert(lp_map_list, '`')
        lp_buf["'"] = nil
        lp_buf['`'] = "'"
    elseif vim.bo.filetype == 'html' then
        table.insert(lp_map_list, '<')
        table.insert(lp_map_list, '>')
        lp_buf['<'] = '>'
    end

    for key, val in pairs(lp_buf) do
        if key == val then
            if #val == 1 then
                lp_buf_map[key] = 'quote'
            else
                lp_buf_map[key] = 'mates'
            end
        else
            lp_buf_map[key] = 'mates'
            lp_buf_map[val] = 'close'
        end
    end

    vim.b.lp_buf = lp_buf
    vim.b.lp_buf_map = lp_buf_map
    vim.b.lp_map_list = lp_map_list
end

-- Check the surrounding characters of the cursor.
-- @tparam hashtable pair_table Defined pairs to index
-- @treturn bool True if the cursor is surrounded by one of the pairs in `pair_table`
local function is_sur(pair_table)
    local last_char = get_ctxt('l')
    return pair_table[last_char] and vim.b.lp_buf[last_char] == get_ctxt('n')
end

-- Difine buffer key maps.
-- @tparam string kbd Key binding
-- @tparam string key Key to feed to the buffer
-- @treturn nil
local function def_map(kbd, key)
    local k = key:match('<%u.*>') and '' or '"'..fn.escape(key, '"')..'"'
    api.nvim_buf_set_keymap(
    0, 'i', kbd,
    [[<CMD>lua require('utility/lua-pairs').lp_]]..vim.b.lp_buf_map[key]..'('..k..')<CR>',
    { noremap=true, expr=false, silent=true })
end


---------- Module functions ---------

-- Clear key maps of current buffer according to `b:lp_map_list`.
-- @treturn nil
function M.clr_map()
    if vim.b.lp_map_list then
        for _,key in ipairs(vim.b.lp_map_list) do
            api.nvim_exec('ino <buffer> '..key..' '..key, false)
        end
        vim.b.lp_map_list = nil
    end
end

-- Actions on <CR>.
-- Inside a pair of brackets:
--   {|} -> feed <CR> -> {
--                           |
--                       }
-- @treturn nil
function M.lp_enter()
    if is_sur(vim.b.lp_buf) then
        feed_keys('<CR><C-O>O')
    else
        feed_keys('<CR>')
    end
end

-- Actions on <BS>.
-- Inside a defined pair(1 character):
--   (|) -> feed <BS> -> |
-- Inside a pair of barces with one space:
--   { | } -> feed <BS> -> {|}
-- @treturn nil
function M.lp_backs()
    local back = get_ctxt('b')
    local fore = get_ctxt('f')
    if back:match('{%s$') and fore:match('^%s}') then
        feed_keys('<C-g>U<Left><C-\\><C-o>2x')
        return
    end
    if is_sur(vim.b.lp_buf) then
        feed_keys('<C-g>U<Right><BS><BS>')
    else
        feed_keys('<BS>')
    end
end

-- Super backspace.
-- Inside a defined pair(no length limit):
--   <u>|</u> -> feed <M-BS> -> |
-- @treturn nil
function M.lp_supbs()
    local back = get_ctxt('b')
    local fore = get_ctxt('f')
    local res = { false, 0, 0 }
    for key, val in pairs(vim.b.lp_buf) do
        if (back:match(reg_esc(key)..'$') and
            '^'..fore:match(reg_esc(val)) and
            #key + #val > res[2] + res[3]) then
            res = { true, #key, #val }
        end
    end
    if res[1] then
        feed_keys(string.rep('<C-g>U<Left>', res[2])..
        '<C-\\><C-O>'..tostring(res[2] + res[3])..'x')
    else
        feed_keys('<BS>')
    end
end

-- Actions on <SPACE>.
-- Inside a pair of braces:
--   {|} -> feed <SPACE> -> { | }
-- @treturn nil
function M.lp_space()
    local keys = is_sur({ ['{']='}' }) and '<SPACE><SPACE><C-g>U<Left>' or '<SPACE>'
    feed_keys(keys)
end

-- Complete 'mates':
--   | -> feed ( -> (|)
--   | -> feed defind_kbd -> pair_a|pair_b
-- Before a NAC character:
--   |a -> feed ( -> (|a
-- @tparam string pair_a Left part of a pair of 'mates'
-- @treturn nil
function M.lp_mates(pair_a)
    local keys
    if is_NAC(get_ctxt('n')) then
        keys = pair_a
    else
        local pair_b = vim.b.lp_buf[pair_a]
        keys = pair_a..pair_b..string.rep('<C-g>U<Left>', #pair_b)
    end
    feed_keys(keys)
end

-- Inside a defined pair:
--   (|) -> feed ) -> ()|
-- @tparam string pair_b Right part of a pair of 'mates'
-- @treturn nil
function M.lp_close(pair_b)
    local keys = get_ctxt('n') == pair_b and '<C-g>U<Right>' or pair_b
    feed_keys(keys)
end

-- Complete 'quote':
--   | -> feed " -> "|"
-- Inside a pair of 'quote':
--   "|" -> feed " -> ""|
-- After the escape character("\"), a 'quote' character or a NAC character:
--   \| -> feed " -> \"|
--   "| -> feed " -> ""|
--   a| -> feed " -> a"|
-- Before a NAC character:
--   |a -> feed " -> "|a
-- @tparam string quote Left part of a pair of 'quote'.
-- @treturn nil
function M.lp_quote(quote)
    local last_char = get_ctxt('l')
    local next_char = get_ctxt('n')
    local keys
    if (next_char == quote and
        (last_char == quote or
        is_NAC(last_char))) then
        keys = '<C-g>U<Right>'
    elseif (last_char == quote or
        is_NAC(last_char) or
        is_NAC(next_char) or
        last_char:match(vim.b.lp_last_spec) or
        next_char:match(vim.b.lp_next_spec) or
        get_ctxt('b'):match(vim.b.lp_back_spec)) then
        keys = quote
    else
        keys = quote..quote..'<C-g>U<Left>'
    end
    feed_keys(keys)
end

-- Define variables and key maps in current buffer.
-- @treturn nil
function M.def_all()
    if vim.b.lp_map_list then return end

    if opt.extd then
        tab_extd(lp_comm, opt.extd)
    end

    def_var()

    if opt.ret then
        def_map('<CR>', '<CR>')
    else
        api.nvim_set_keymap(
        'i',
        '<Plug>(ipairs_enter)',
        '<CMD>lua require("utility/lua-pairs").lp_enter()<CR>',
        { silent=true, expr=false, noremap=true })
    end

    if opt.bak then
        def_map("<BS>", "<BS>")
        def_map("<M-BS>", "<M-BS>")
    end

    if opt.spc then
        def_map("<SPACE>", "<SPACE>")
    end

    for _,key in ipairs(vim.b.lp_map_list) do
        def_map(key, key)
    end

    if opt.extd_map then
        for key, val in pairs(opt.extd_map) do
            def_map(key, val)
        end
    end
end

-- Set up lua-pairs.
-- @tparam hashtable option User configuration
--   bool      ret      True to map <CR>
--   bool      ret      True to map <BS> and <M-BS>
--   bool      spc      True to map <SPACE>
--   hashtable extd     To extend the default pairs
--   hashtable extd_map To define key bindings of extend pairs
-- @treturn nil
function M.setup(option)
    opt = option
    vim.cmd('augroup lp_buffer_update')
    vim.cmd('autocmd!')
    vim.cmd('au BufEnter * lua require("utility/lua-pairs").def_all()')
    vim.cmd('au FileType * lua require("utility/lua-pairs").clr_map() require("utility/lua-pairs").def_all()')
    vim.cmd('augroup end')
end


return M
