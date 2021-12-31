local M = {}
local api = vim.api
local lib = require('utility.lib')


local cmt_mark_tab_single = {
    c = "//",
    cmake = "#",
    cpp = "//",
    cs = "//",
    dosbatch = "::",
    gitconfig = "#",
    java = "//",
    lisp = ";",
    lua = "--",
    markdown = "> ",
    rust = "//",
    perl = "#",
    python = "#",
    sh = "#",
    sshconfig = "#",
    tex = "%",
    toml = "#",
    vim = '"',
    vimwiki = "%% ",
    yaml = "#",
}

local cmt_mark_tab_multi = {
    c = { "/*", "*/" },
    cpp = { "/*", "*/" },
    cs = { "/*", "*/" },
    java = { "/*", "*/" },
    rust = { "/*", "*/" },
    lua = { "--[[", "]]" }
}

---Comment current line in normal mode.
function M.cmt_add_norm()
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark then
        local pos = api.nvim_win_get_cursor(0)
        local cmd = api.nvim_replace_termcodes("I"..cmt_mark, true, false, true)
        api.nvim_feedkeys(cmd, 'xn', true)
        api.nvim_win_set_cursor(0, pos)
    else
        lib.notify_err("File type "..vim.bo.filetype.." is not supported yet.")
    end
end

---Comment selected lines in visual mode.
function M.cmt_add_vis()
    local pos_s = api.nvim_buf_get_mark(0, "<")
    local pos_e = api.nvim_buf_get_mark(0, ">")
    local cmt_mark_single = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark_single then
        local lnum_s = pos_s[1]
        local lnum_e = pos_e[1]
        local cmt_mark_single_esc = vim.pesc(cmt_mark_single)
        for i = lnum_s, lnum_e, 1 do
            local line_old = api.nvim_buf_get_lines(0, i - 1, i, true)[1]
            if not line_old:match("^%s*$") then
                local line_new = line_old:gsub("^(%s*)(.*)$",
                "%1"..cmt_mark_single_esc.."%2")
                api.nvim_buf_set_lines(0, i - 1, i, true, {line_new})
            end
        end
    else
        print("Have no idea how to comment "..vim.bo.filetype.." file.")
    end
end

---Check if line(lnum) is a commented line.
---@param lnum integer Line number.
---@return string result The un-commented line it is commented, else nil.
local function is_cmt_line(lnum)
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    local cmt_mark = cmt_mark_tab_single[vim.bo.filetype]
    if cmt_mark then
        local esc_cmt_mark = vim.pesc(cmt_mark)
        local matched, l, r = line:match("^((%s*)"..esc_cmt_mark.."(.*))$")
        if matched then return l..r end
    end
    return nil
end

---Un-comment code block.
local function del_cmt_block()
    local lnum_c = api.nvim_win_get_cursor(0)[1]
    local cmt_mark = cmt_mark_tab_multi[vim.bo.filetype]

    if not cmt_mark then return end

    local cmt_mark_a = cmt_mark[1]
    local cmt_mark_b = cmt_mark[2]
    local lua_cmt_mark_a = vim.pesc(cmt_mark_a)
    local lua_cmt_mark_b = vim.pesc(cmt_mark_b)

    for i = lnum_c - 1, 1, -1 do
        local line_p = api.nvim_buf_get_lines(0, i - 1, i, true)[1]
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
                api.nvim_buf_set_lines(0, i - 1, i, true, {line_p})
            end
            break
        end
    end

    for i = lnum_c + 1, api.nvim_buf_line_count(0), 1 do
        local line_n = api.nvim_buf_get_lines(0, i - 1, i, true)[1]
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
                api.nvim_buf_set_lines(0, i - 1, i, true, {line_n})
            end
            break
        end
    end
end

---Un-comment current line in normal mode.
function M.cmt_del_norm()
    if not cmt_mark_tab_single[vim.bo.filetype] then return end
    local line_new = is_cmt_line(api.nvim_win_get_cursor(0)[1])
    if line_new then
        vim.api.nvim_set_current_line(line_new)
        return
    end
    del_cmt_block()
end

---Un-comment selected lines in visual mode.
function M.cmt_del_vis()
    local lnum_s = api.nvim_buf_get_mark(0, "<")[1]
    local lnum_e = api.nvim_buf_get_mark(0, ">")[1]
    for i = lnum_s, lnum_e, 1 do
        local line_new = is_cmt_line(i)
        if line_new then
            api.nvim_buf_set_lines(0, i - 1, i, true, {line_new})
        end
    end
end


return M
