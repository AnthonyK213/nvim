local fn  = vim.fn
local api = vim.api
local lib = require("utility/lib")
local M = {}


local cmt_mark_tab_single = {
    c = "//",
    cpp = "//",
    cs = "//",
    java = "//",
    lua = "--",
    rust = "//",
    -- No multiline comment marks;
    -- Or something stupid like python.
    lisp = ";;",
    perl = '#',
    python = "#",
    tex = "%",
    vim = '"',
    vimwiki = "%% "
}

local cmt_mark_tab_multi = {
    c = { "/*", "*/" },
    cpp = { "/*", "*/" },
    cs = { "/*", "*/" },
    rust = { "/*", "*/" },
    java = { "/*", "*/" },
    lua = { "--[[", "]]" },
    --python = { "'''", "'''" },
}

function M.cmt_add_norm()
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark then
        local pos = fn.getpos('.')
        local cmd = api.nvim_replace_termcodes("I"..cmt_mark, true, false, true)
        api.nvim_feedkeys(cmd, 'x', true)
        fn.setpos('.', pos)
    else
        print("Unfortunately, neovim have no idea how to comment "..vim.bo.filetype.." file.")
    end
end

function M.cmt_add_vis()
    local cmt_mark_single = cmt_mark_tab_single[vim.bo.filetype]
    local cmt_mark_multi  = cmt_mark_tab_multi[vim.bo.filetype]
    local pos_s = fn.getpos("'<")
    local pos_e = fn.getpos("'>")
    if cmt_mark_multi then
        local cmd_s = api.nvim_replace_termcodes("O"..cmt_mark_multi[1], true, false, true)
        local cmd_e = api.nvim_replace_termcodes("o"..cmt_mark_multi[2], true, false, true)
        fn.setpos('.', pos_e)
        api.nvim_feedkeys(cmd_e, 'xn', true)
        fn.setpos('.', pos_s)
        api.nvim_feedkeys(cmd_s, 'xn', true)
    elseif cmt_mark_single then
        local lnum_s = pos_s[2]
        local lnum_e = pos_e[2]
        for i = lnum_s, lnum_e, 1 do
            local line_old = fn.getline(i)
            if not line_old:match("^%s*$") then
                local l, r = line_old:match("^(%s*)(.*)$")
                local line_new = l..cmt_mark_single..r
                fn.setline(i, line_new)
            end
        end
    else
        print("Unfortunately, neovim have no idea how to comment "..vim.bo.filetype.." file.")
    end
end

local function is_cmt_line()
    local line = api.nvim_get_current_line()
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    local esc_cmt_mark = lib.lua_reg_esc(cmt_mark)
    if line:match("^%s*"..esc_cmt_mark..".*$") then
        local l, r = line:match("^(%s*)"..esc_cmt_mark.."(.*)$")
        return true, l..r
    end
    return false, line
end

--[[
local function is_cmt_block()
    local lnum_c = fn.line('.')
    local c_line_b = lib.get_context('b')
    local c_line_f = lib.get_context('f')
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    local esc_cmt_mark = lib.lua_reg_esc(cmt_mark)
    if c_line_b:match("") then
    end
    if c_line_f:mathc("") then
    end
    while lnum_c > 0 do
        lnum_c = lnum_c - 1
    end
    while lnum_c <= fn.line('$') do
        lnum_c = lnum_c + 1
    end
end
]]

function M.cmt_del_norm()
    if not cmt_mark_tab_single[vim.bo.filetype] then return end
    local cmt_line, line_new = is_cmt_line()
    if cmt_line then
        fn.setline('.', line_new)
        return
    end
    --[[
    local cmt_block = is_cmt_block()
    if cmt_block then

    end
    ]]
end


return M
