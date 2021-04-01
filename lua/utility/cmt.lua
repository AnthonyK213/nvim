local fn  = vim.fn
local api = vim.api
local lib = require("utility/lib")
local M = {}


local cmt_mark_tab_single = {
    c = "//",
    cpp = "//",
    cs = "//",
    rust = "//",
    java = "//",
    python = "#",
    lua = "--",
    lisp = ";;",
    vim = '"',
    perl = '#',
    tex = "%",
    vimwiki = "%% "
}

local cmt_mark_tab_multi = {
    c = { "/*", "*/" },
    cpp = { "/*", "*/" },
    cs = { "/*", "*/" },
    rust = { "/*", "*/" },
    java = { "/*", "*/" },
    python = { "'''", "'''" },
    lua = { "--[[", "]]" }
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

function M.cmt_del_norm()
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if not cmt_mark then return end
    local line_old = fn.getline('.')
    local esc_cmt_mark = lib.lua_reg_esc(cmt_mark)
    if line_old:match("^%s*"..esc_cmt_mark..".*$") then
        local l, r = line_old:match("^(%s*)"..esc_cmt_mark.."(.*)$")
        fn.setline('.', l..r)
    end
end


return M
