-- vim-ipairs
-- -- File:       lua-pairs.lua
-- -- Repository: https://github.com/AnthonyK213/lua-pairs
-- -- License:    The MIT License (MIT)


local M = {}


local vim = vim
local api = vim.api
local fn  = vim.fn

local lp_comm = {
    ["("] = ")",
    ["["] = ']',
    ["{"] = "}",
    ["'"] = "'",
    ['"'] = '"'
}

local opt = {}


local function tab_extd(a, b)
    for key, val in pairs(b) do
        a[key] = val
    end
end

local function rep_term(str)
    return api.nvim_replace_termcodes(str, true, false, true)
end

local function feed_keys(str)
    return api.nvim_feedkeys(rep_term(str), 'n', true)
end

local function is_alphanumchar(char)
    local nr = fn.char2nr(char)
    return char:match('[%w_]') or (nr >= 0x4E00 and nr <= 0x9fA5)
end

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

local function is_sur(pair_table)
    local last_char = get_ctxt('l')
    return pair_table[last_char] and vim.b.lp_buf[last_char] == get_ctxt('n')
end

function M.lp_enter()
    if is_sur(vim.b.lp_buf) then
        feed_keys('<CR><C-O>O')
    else
        feed_keys('<CR>')
    end
end

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

function M.lp_space()
    local keys = is_sur({ ['{']='}' }) and '<SPACE><SPACE><C-g>U<Left>' or '<SPACE>'
    feed_keys(keys)
end

function M.lp_mates(pair_a)
    local keys
    if is_alphanumchar(get_ctxt('n')) then
        keys = pair_a
    else
        local pair_b = vim.b.lp_buf[pair_a]
        keys = pair_a..pair_b..string.rep('<C-g>U<Left>', #pair_b)
    end
    feed_keys(keys)
end

function M.lp_close(pair_b)
    local keys = get_ctxt('n') == pair_b and '<C-g>U<Right>' or pair_b
    feed_keys(keys)
end

function M.lp_quote(quote)
    local last_char = get_ctxt('l')
    local next_char = get_ctxt('n')
    local keys
    if (next_char == quote and
        (last_char == quote or
        is_alphanumchar(last_char))) then
        keys = '<C-g>U<Right>'
    elseif (last_char == quote or
        is_alphanumchar(last_char) or
        is_alphanumchar(next_char) or
        last_char:match(vim.b.lp_last_spec) or
        next_char:match(vim.b.lp_next_spec) or
        get_ctxt('b'):match(vim.b.lp_back_spec)) then
        keys = quote
    else
        keys = quote..quote..'<C-g>U<Left>'
    end
    feed_keys(keys)
end

function M.clr_map()
    if vim.b.lp_map_list then
        for _,key in ipairs(vim.b.lp_map_list) do
            api.nvim_exec('ino <buffer> '..key..' '..key, false)
        end
        vim.b.lp_map_list = nil
    end
end

local function def_map(kbd, key)
    local k = key:match('<%u.*>') and '' or '"'..fn.escape(key, '"')..'"'
    api.nvim_buf_set_keymap(
    0, 'i', kbd,
    [[<CMD>lua require('utility/lua-pairs').lp_]]..vim.b.lp_buf_map[key]..'('..k..')<CR>',
    { noremap=true, expr=false, silent=true })
end

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

function M.setup(option)

    opt = option

    vim.cmd('augroup pairs_update_buffer')
    vim.cmd('autocmd!')
    vim.cmd('au BufEnter * lua require("utility/lua-pairs").def_all()')
    vim.cmd('au FileType * lua require("utility/lua-pairs").clr_map() require("utility/lua-pairs").def_all()')
    vim.cmd('augroup end')
end


return M
