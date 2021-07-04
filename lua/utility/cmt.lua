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
    lisp = ";",
    perl = "#",
    python = "#",
    sh = "#",
    tex = "%",
    vim = '"',
    vimwiki = "%% ",
    markdown = "> ",
    sshconfig = "#",
    gitconfig = "#",
    yaml = "#",
}

local cmt_mark_tab_multi = {
    c = { "/*", "*/" },
    cpp = { "/*", "*/" },
    cs = { "/*", "*/" },
    java = { "/*", "*/" },
    lua = { "--[[", "]]" },
    rust = { "/*", "*/" },
}

function M.cmt_add_norm()
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark then
        local pos = fn.getpos('.')
        local cmd = api.nvim_replace_termcodes("I"..cmt_mark, true, false, true)
        api.nvim_feedkeys(cmd, 'xn', true)
        fn.setpos('.', pos)
    else
        print("Have no idea how to comment "..vim.bo.filetype.." file.")
    end
end

function M.cmt_add_vis()
    local cmt_mark_single = cmt_mark_tab_single[vim.bo.filetype]
    local cmt_mark_multi  = cmt_mark_tab_multi[vim.bo.filetype]
    local pos_s = fn.getpos("'<")
    local pos_e = fn.getpos("'>")
    if cmt_mark_multi then
        local cmd_s = api.nvim_replace_termcodes(
        "O"..cmt_mark_multi[1], true, false, true)
        local cmd_e = api.nvim_replace_termcodes(
        "o"..cmt_mark_multi[2], true, false, true)
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
                local line_new = line_old:gsub("^(%s*)(.*)$",
                "%1"..cmt_mark_single.."%2")
                fn.setline(i, line_new)
            end
        end
    else
        print("Have no idea how to comment "..vim.bo.filetype.." file.")
    end
end

local function is_cmt_line(lnum)
    local line = fn.getline(lnum)
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark then
        local esc_cmt_mark = lib.lua_reg_esc(cmt_mark)
        if line:match("^%s*"..esc_cmt_mark..".*$") then
            local l, r = line:match("^(%s*)"..esc_cmt_mark.."(.*)$")
            return true, l..r
        end
    end
    return false, line
end

local function del_cmt_block()
    local lnum_c = fn.line('.')
    --[[
    local c_line_b = lib.get_context('b')
    local c_line_f = lib.get_context('f')
    ]]
    local cmt_mark = cmt_mark_tab_multi[vim.bo.filetype]

    if not cmt_mark then return end

    local cmt_mark_a = cmt_mark[1]
    local cmt_mark_b = cmt_mark[2]
    local lua_cmt_mark_a = lib.lua_reg_esc(cmt_mark_a)
    local lua_cmt_mark_b = lib.lua_reg_esc(cmt_mark_b)
    --local sub_b, sub_f = false, false

    --[[
    if c_line_b:match(lua_cmt_mark_a..".-$") then
        local pos_a = c_line_b:find(lua_cmt_mark_a..".-$")
        if c_line_b:match(lua_cmt_mark_b..".-$") then
            local pos_b = c_line_b:find(lua_cmt_mark_b..".-$")
            if pos_a < pos_b then
                goto c_line_b_end
            end
        end
        c_line_b = c_line_b:gsub(lua_cmt_mark_a, "")
        sub_b = true
    end
    ::c_line_b_end::
    ]]

    for i = lnum_c - 1, 1, -1 do
        local line_p = fn.getline(i)
        if (line_p:match(lua_cmt_mark_b..".-$") and not
            line_p:match(lua_cmt_mark_a..".-$")) then
            return
        end
        if line_p:match(lua_cmt_mark_a..".-$") then
            local pos_a = line_p:find(lua_cmt_mark_a..".-$")
            if line_p:match(lua_cmt_mark_b..".-$") then
                local pos_b = line_p:find(lua_cmt_mark_b..".-$")
                if pos_a < pos_b then
                    return
                end
            end
            if line_p:match("^%s*"..lua_cmt_mark_a.."%s*$") then
                vim.cmd(i.."d")
                lnum_c = lnum_c - 1
            else
                line_p = line_p:gsub(lua_cmt_mark_a, "")
                fn.setline(i, line_p)
            end
            break
        end
    end

    --[[
    if c_line_f:match("^.-"..lua_cmt_mark_b) then
        local pos_b = c_line_f:find(lua_cmt_mark_b..".+$")
        if c_line_f:match("^.-"..lua_cmt_mark_a) then
            local pos_a = c_line_f:find(lua_cmt_mark_a..".+$")
            if pos_a < pos_b then
                goto c_line_f_end
            end
        end
        c_line_f = c_line_f:gsub(lua_cmt_mark_b, "")
        sub_f = true
    end
    ::c_line_f_end::
    ]]

    --[[
    if sub_b and sub_f then
        fn.setline(lnum_c, c_line_b..c_line_f)
    end
    ]]

    for i = lnum_c + 1, fn.line('$'), 1 do
        local line_n = fn.getline(i)
        if line_n:match(lua_cmt_mark_b..".*$") then
            local pos_b = line_n:find(lua_cmt_mark_b..".*$")
            if line_n:match(lua_cmt_mark_a..".*$") then
                local pos_a = line_n:find(lua_cmt_mark_a..".*$")
                if pos_a < pos_b then
                    return
                end
            end
            if line_n:match("^%s*"..lua_cmt_mark_b.."%s*$") then
                vim.cmd(i.."d")
            else
                line_n = line_n:gsub(lua_cmt_mark_b, "")
                fn.setline(i, line_n)
            end
            break
        end
    end
end

function M.cmt_del_norm()
    if not cmt_mark_tab_single[vim.bo.filetype] then return end
    local cmt_line, line_new = is_cmt_line('.')
    if cmt_line then
        vim.api.nvim_set_current_line(line_new)
        return
    end
    del_cmt_block()
end

function M.cmt_del_vis()
    local lnum_s = fn.getpos("'<")[2]
    local lnum_e = fn.getpos("'>")[2]
    for i = lnum_s, lnum_e, 1 do
        local cmt_line, line_new = is_cmt_line(i)
        if cmt_line then
            fn.setline(i, line_new)
        end
    end
end


return M
