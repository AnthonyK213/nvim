-- File:       lua-pairs.lua
-- Repository: https://github.com/AnthonyK213/nvim
-- License:    The MIT License (MIT)


local M = {}
local vim = vim
local api = vim.api
local fn  = vim.fn

local opt = {}
local lp_comm={ ["("]=")", ["["]=']', ["{"]="}", ["'"]="'", ['"']='"' }

local left  = '<C-g>U<Left>'
local right = '<C-g>U<Right>'


---------- Local functions ---------

-- Extend table b to a.
-- @param table a Table to be extended
-- @param table b Table to extend
-- @return nil
local tab_extd = function(a, b)
    for key, val in pairs(b) do a[key] = val end
end

-- Convert string to terminal codes.
-- @param string str String to be converted
-- @return string Converted string, can be used as terminal code.
local rep_term = function(str)
    return api.nvim_replace_termcodes(str, true, false, true)
end

-- Feed keys to current buffer.
-- @param string str Operation as string to feed to buffer.
-- @return nil
local feed_keys = function(str)
    api.nvim_feedkeys(rep_term(str), 'n', true)
end

-- Determine if a character is a numeric/alphabetic/CJK(NAC) character.
-- @param string(char) char A character to be tested
-- @return bool True if the character is a NAC
local function is_NAC(char)
    local nr = fn.char2nr(char)
    return char:match('[%w_]') or (nr >= 0x4E00 and nr <= 0x9FFF)
end

-- Escape regex special characters in a string by '%'.
-- @param string str String to be converted to be a regex match pattern
-- @return string Converted string
local function reg_esc(str)
    local str_list = fn.split(str, '\\zs')
    local esc_table = {
        '(', ')', '[', ']',
        '+', '-', '*', '?',
        '.', '%', '^', '$'
    }
    for i, v in ipairs(str_list) do
        if fn.index(esc_table, v) >= 0 then
            str_list[i] = '%'..v
        end
    end
    return table.concat(str_list)
end

-- Get characters around the cursor by 'mode'.
-- @param string mode Four modes to get the context
--   'l' -> Return the character before cursor
--   'n' -> Return the character after cursor
--   'b' -> Return the half line before cursor
--   'f' -> Return the half line after cursor
-- @return string Grabbed string around the cursor
local get_ctxt_arg = {
    l = { '.\\%', 'c' },
    n = { '\\%', 'c.' },
    b = { '^.*\\%', 'c' },
    f = { '\\%', 'c.*$' },
}

local function get_ctxt(mode)
    local arg_table = get_ctxt_arg[mode]
    return fn.matchstr(
    api.nvim_get_current_line(),
    arg_table[1]..fn.col('.')..arg_table[2])
end

-- Define the buffer variables.
-- @bufvar string     b:lp_last_spec No paifing if the last character matches
-- @bufvar string     b:lp_next_spec No pairing if the next character matches
-- @bufvar string     b:lp_back_spec No pairing if the left half line matches
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
-- @return nil
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
-- @param hashtable pair_table Defined pairs to index
-- @return bool True if the cursor is surrounded by pair in `pair_table`
local function is_sur(pair_table)
    local last_char = get_ctxt('l')
    return pair_table[last_char] and vim.b.lp_buf[last_char] == get_ctxt('n')
end

-- Difine buffer key maps.
-- @param string kbd Key binding
-- @param string key Key to feed to the buffer
-- @return nil
local function def_map(kbd, key)
    local k = key:match('<%u.*>') and '' or '"'..fn.escape(key, '"')..'"'
    api.nvim_buf_set_keymap(
    0, 'i', kbd,
    '<CMD>lua require("lua-pairs").lp_'..vim.b.lp_buf_map[key]..'('..k..')<CR>',
    { noremap=true, expr=false, silent=true })
end


---------- Module functions ---------

-- Clear key maps of current buffer according to `b:lp_map_list`.
-- @return nil
function M.clr_map()
    if vim.b.lp_map_list then
        for _, key in ipairs(vim.b.lp_map_list) do
            api.nvim_buf_set_keymap(0, 'i', key, key,
            { noremap=true, expr=false, silent=true })
        end
        vim.b.lp_map_list = nil
    end
end

-- Actions on <CR>.
-- Inside a pair of brackets:
--   {|} -> feed <CR> -> {
--                           |
--                       }
-- @return nil
function M.lp_enter()
    if is_sur(vim.b.lp_buf) then
        feed_keys('<CR><C-\\><C-O>O')
    elseif get_ctxt('b'):match('{%s*$') and
        get_ctxt('f'):match('^%s*}') then
        feed_keys('<C-\\><C-O>diB<CR><C-\\><C-O>O')
    else
        feed_keys('<CR>')
    end
end

-- Actions on <BS>.
-- Inside a defined pair(1 character):
--   (|) -> feed <BS> -> |
-- Inside a pair of barces with one space:
--   { | } -> feed <BS> -> {|}
-- @return nil
function M.lp_backs()
    if is_sur(vim.b.lp_buf) then
        feed_keys(right..'<BS><BS>')
    elseif get_ctxt('b'):match('{%s$') and
        get_ctxt('f'):match('^%s}') then
        feed_keys('<C-\\><C-O>diB')
    else
        feed_keys('<BS>')
    end
end

-- Super backspace.
-- Inside a defined pair(no length limit):
--   <u>|</u> -> feed <M-BS> -> |
-- Kill a word:
--   Kill a word| -> feed <M-BS> -> Kill a |
-- @return nil
function M.lp_supbs()
    local back = get_ctxt('b')
    local fore = get_ctxt('f')
    local res = { false, 0, 0 }
    for key, val in pairs(vim.b.lp_buf) do
        if (back:match(reg_esc(key)..'$') and
            fore:match('^'..reg_esc(val)) and
            #key + #val > res[2] + res[3]) then
            res = { true, #key, #val }
        end
    end
    if res[1] then
        feed_keys(string.rep(left, res[2])..
        string.rep('<Del>', res[2] + res[3]))
    elseif back:match('{%s*$') and fore:match('^%s*}') then
        feed_keys('<C-\\><C-O>diB')
    else
        feed_keys('<C-\\><C-O>db')
    end
end

-- Actions on <SPACE>.
-- Inside a pair of braces:
--   {|} -> feed <SPACE> -> { | }
-- @return nil
function M.lp_space()
    local keys = is_sur({ ['{']='}' }) and
    '<SPACE><SPACE>'..left or '<SPACE>'
    feed_keys(keys)
end

-- Complete 'mates':
--   | -> feed ( -> (|)
--   | -> feed defined_kbd -> pair_a|pair_b
-- Before a NAC character:
--   |a -> feed ( -> (|a
-- @param string pair_a Left part of a pair of 'mates'
-- @return nil
function M.lp_mates(pair_a)
    local keys
    if is_NAC(get_ctxt('n')) then
        keys = pair_a
    else
        local pair_b = vim.b.lp_buf[pair_a]
        keys = pair_a..pair_b..string.rep(left, #pair_b)
    end
    feed_keys(keys)
end

-- Inside a defined pair:
--   (|) -> feed ) -> ()|
-- @param string pair_b Right part of a pair of 'mates'
-- @return nil
function M.lp_close(pair_b)
    local keys = get_ctxt('n') == pair_b and right or pair_b
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
-- @param string quote Left part of a pair of 'quote'.
-- @return nil
function M.lp_quote(quote)
    local last_char = get_ctxt('l')
    local next_char = get_ctxt('n')
    local keys
    if (next_char == quote and
        (last_char == quote or
        is_NAC(last_char))) then
        keys = right
    elseif (last_char == quote or
        is_NAC(last_char) or
        is_NAC(next_char) or
        last_char:match(vim.b.lp_last_spec) or
        next_char:match(vim.b.lp_next_spec) or
        get_ctxt('b'):match(vim.b.lp_back_spec)) then
        keys = quote
    else
        keys = quote..quote..left
    end
    feed_keys(keys)
end

-- Define variables and key maps in current buffer.
-- @return nil
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
        '<Plug>(lua_pairs_enter)',
        '<CMD>lua require("lua-pairs").lp_enter()<CR>',
        { silent=true, expr=false, noremap=true })
    end

    if opt.bak then
        def_map("<BS>", "<BS>")
        def_map("<M-BS>", "<M-BS>")
    end

    if opt.spc then
        def_map("<SPACE>", "<SPACE>")
    end

    for _, key in ipairs(vim.b.lp_map_list) do
        def_map(key, key)
    end

    if opt.extd_map then
        for key, val in pairs(opt.extd_map) do
            def_map(key, val)
        end
    end
end

-- Set up lua-pairs.
-- @param hashtable option User configuration
--   bool      ret      True to map <CR>
--   bool      bak      True to map <BS> and <M-BS>
--   bool      spc      True to map <SPACE>
--   hashtable extd     To extend the default pairs
--   hashtable extd_map To define key bindings of extend pairs
-- @return nil
function M.setup(option)
    opt = option
    vim.cmd('augroup lp_buffer_update')
    vim.cmd('autocmd!')
    vim.cmd('au BufEnter * lua require("lua-pairs").def_all()')
    vim.cmd([[au FileType * lua ]]..
    [[require("lua-pairs").clr_map() ]]..
    [[require("lua-pairs").def_all()]])
    vim.cmd('augroup end')
end


return M
