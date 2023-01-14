local M = {}
local lib = require("utility.lib")
local Syntax = require("utility.syn")

local space = true
local _s = space and " " or ""
local _s_pat = space and "%s?" or ""
local _k_slash = { s = "//", s_pat = "///*", d = { "/*", "*/" } }
local _k_sharp = { s = "#" }
local _k_lisps = { s = ";" }

local _cmt_table = {
    arduino = _k_slash,
    c = _k_slash,
    cmake = _k_sharp,
    cpp = _k_slash,
    dosbatch = { s = "::" },
    cs = _k_slash,
    css = { d = { "/*", "*/" } },
    fsharp = _k_slash,
    gitconfig = _k_sharp,
    html = { d = { "<!--", "-->" } },
    java = _k_slash,
    javascript = _k_slash,
    lisp = _k_lisps,
    lua = { s = "--", s_pat = "%-%-%-*" },
    make = _k_sharp,
    markdown = { s = ">" },
    rust = _k_slash,
    perl = _k_sharp,
    ps1 = _k_sharp,
    python = _k_sharp,
    scheme = _k_lisps,
    sh = _k_sharp,
    sshconfig = _k_sharp,
    tex = { s = "%" },
    toml = _k_sharp,
    typescript = _k_slash,
    vim = { s = '"' },
    yaml = _k_sharp,
    zsh = _k_sharp,
}

---Get current file type.
---@return string? filetype
local function get_ft()
    if vim.bo.ft == "vue" then
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local l = vim.api.nvim_buf_line_count(0)
        local pat_a = vim.regex [[\v^\<(script|template|style)\s?.*\>]]
        local pat_b = vim.regex [[\v^\</(script|template|style)\>]]

        if l == 0 or lnum == 1 or lnum == l
            or pat_a:match_line(0, lnum - 1)
            or pat_b:match_line(0, lnum - 1) then
            return
        end

        local s, e

        for i = lnum - 1, 1, -1 do
            if pat_a:match_line(0, i - 1) then
                local line = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
                if vim.startswith(line, "<script") then
                    s = "javascript"
                elseif vim.startswith(line, "<template") then
                    s = "html"
                else
                    s = "css"
                end
                break
            end
        end

        for j = lnum + 1, l, 1 do
            if pat_b:match_line(0, j - 1) then
                local line = vim.api.nvim_buf_get_lines(0, j - 1, j, true)[1]
                if vim.startswith(line, "</script") then
                    e = "javascript"
                elseif vim.startswith(line, "</template") then
                    e = "html"
                else
                    e = "css"
                end
                break
            end
        end

        return s == e and s or nil
    end

    return vim.bo.ft
end

---Get comment object from `cmt_table`.
---@param throw? boolean If true, notify error if error occurred.
---@return table?
---@return string?
local function get_cmt_mark(throw)
    local ft = get_ft()
    if not ft then
        if throw then
            lib.notify_err("Unsupported filetype")
        end
        return nil, nil
    end
    return _cmt_table[ft], ft
end

---Check if line(lnum) is a commented line.
---@param lnum integer Line number.
---@return string? result The un-commented line if it is commented, else nil.
local function is_cmt_line(lnum)
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    local cmt_mark = get_cmt_mark()
    if not cmt_mark then return end
    if cmt_mark.s then
        local s_pat = (cmt_mark.s_pat or vim.pesc(cmt_mark.s)) .. _s_pat
        local matched, l, r = line:match("^((%s*)" .. s_pat .. "(.*))$")
        if matched then return l .. r end
    elseif cmt_mark.d then
        local s_pat_a = (cmt_mark.d_pat and cmt_mark.d_pat[1] or vim.pesc(cmt_mark.d[1])) .. _s_pat
        local s_pat_b = _s_pat .. (cmt_mark.d_pat and cmt_mark.d_pat[2] or vim.pesc(cmt_mark.d[2]))
        local matched, l, r = line:match("^((%s*)" .. s_pat_a .. "(.-)" .. s_pat_b .. ")%s*$")
        if matched then return l .. r end
    end
end

---Determine if line is empty.
---@param lnum? integer
---@return boolean
local function is_empty_line(lnum)
    lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if line:match("^%s*$") then
        return true
    end
    return false
end

---Comment current line in normal mode.
function M.cmt_add_n()
    local cmt_mark = get_cmt_mark(true)
    if not cmt_mark then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    if cmt_mark.s then
        if is_empty_line() then return end
        local cmd = vim.api.nvim_replace_termcodes("I" .. cmt_mark.s .. _s, true, false, true)
        vim.api.nvim_feedkeys(cmd, "xn", true)
        vim.api.nvim_win_set_cursor(0, pos)
    elseif cmt_mark.d then
        local cmd_a = vim.api.nvim_replace_termcodes("I" .. cmt_mark.d[1] .. _s, true, false, true)
        vim.api.nvim_feedkeys(cmd_a, "xn", true)
        local cmd_b = vim.api.nvim_replace_termcodes("A" .. _s .. cmt_mark.d[2], true, false, true)
        vim.api.nvim_feedkeys(cmd_b, "xn", true)
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

---Comment selected lines in visual mode.
function M.cmt_add_v()
    local cmt_mark = get_cmt_mark(true)
    if not cmt_mark then return end
    local pos_s = vim.api.nvim_buf_get_mark(0, "<")
    local pos_e = vim.api.nvim_buf_get_mark(0, ">")
    local lnum_s = pos_s[1]
    local lnum_e = pos_e[1]
    if cmt_mark.s then
        local s_lpat = vim.pesc(cmt_mark.s)
        for i = lnum_s, lnum_e, 1 do
            local line_old = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
            if not line_old:match("^%s*$") then
                local line_new = line_old:gsub("^(%s*)(.*)$", "%1" .. s_lpat .. _s .. "%2")
                vim.api.nvim_buf_set_lines(0, i - 1, i, true, { line_new })
            end
        end
    elseif cmt_mark.d then
        local s_lpat_a = vim.pesc(cmt_mark.d[1])
        local s_lpat_b = vim.pesc(cmt_mark.d[2])
        if lnum_s == lnum_e then
            local line_old = vim.api.nvim_buf_get_lines(0, lnum_s - 1, lnum_s, true)[1]
            if not line_old:match("^%s*$") then
                local line_new = line_old:gsub("^(%s*)(.*)$", "%1" .. s_lpat_a .. _s .. "%2" .. _s .. s_lpat_b)
                vim.api.nvim_buf_set_lines(0, lnum_s - 1, lnum_s, true, { line_new })
            end
        else
            local line_old_s = vim.api.nvim_buf_get_lines(0, lnum_s - 1, lnum_s, true)[1]
            local line_new_s = line_old_s:gsub("^(%s*)(.*)$", "%1" .. s_lpat_a .. _s .. "%2")
            vim.api.nvim_buf_set_lines(0, lnum_s - 1, lnum_s, true, { line_new_s })
            local line_old_e = vim.api.nvim_buf_get_lines(0, lnum_e - 1, lnum_e, true)[1]
            local line_new_e = line_old_e .. _s .. cmt_mark.d[2]
            vim.api.nvim_buf_set_lines(0, lnum_e - 1, lnum_e, true, { line_new_e })
        end
    end
end

---Uncomment code line/block at point in normal mode.
function M.cmt_del_n()
    local cmt_mark = get_cmt_mark(true)
    if not cmt_mark then return end
    local line_new = is_cmt_line(vim.api.nvim_win_get_cursor(0)[1])
    if line_new then
        vim.api.nvim_set_current_line(line_new)
        return
    end

    if not cmt_mark.d or not Syntax.match_here("[Cc]omment") then return end
    local lnum_c = vim.api.nvim_win_get_cursor(0)[1]

    local cmt_mark_a = cmt_mark.d[1]
    local cmt_mark_b = cmt_mark.d[2]
    local lua_cmt_mark_a = (cmt_mark.d_pat and cmt_mark.d_pat[1] or vim.pesc(cmt_mark_a)) .. _s_pat
    local lua_cmt_mark_b = _s_pat .. (cmt_mark.d_pat and cmt_mark.d_pat[2] or vim.pesc(cmt_mark_b))

    for i = lnum_c, 1, -1 do
        local line_p = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
        if line_p:match("^%s*" .. lua_cmt_mark_a .. ".*$") then
            if line_p:match("^%s*" .. lua_cmt_mark_a .. "%s*$") then
                vim.api.nvim_buf_set_lines(0, i - 1, i, true, { "" })
            else
                line_p = line_p:gsub(lua_cmt_mark_a, "", 1)
                vim.api.nvim_buf_set_lines(0, i - 1, i, true, { line_p })
            end
            break
        end
    end

    for i = lnum_c, vim.api.nvim_buf_line_count(0), 1 do
        local line_n = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
        if line_n:match(lua_cmt_mark_b .. "$") then
            if line_n:match("^%s*" .. lua_cmt_mark_b .. "$") then
                vim.api.nvim_buf_set_lines(0, i - 1, i, true, { "" })
            else
                line_n = line_n:gsub(lua_cmt_mark_b, "")
                vim.api.nvim_buf_set_lines(0, i - 1, i, true, { line_n })
            end
            break
        end
    end
end

---Uncomment selected lines in visual mode.
function M.cmt_del_v()
    local lnum_s = vim.api.nvim_buf_get_mark(0, "<")[1]
    local lnum_e = vim.api.nvim_buf_get_mark(0, ">")[1]
    for i = lnum_s, lnum_e, 1 do
        local line_new = is_cmt_line(i)
        if line_new then
            vim.api.nvim_buf_set_lines(0, i - 1, i, true, { line_new })
        end
    end
end

return M
