local lib = require("utility.lib")
local util = require("utility.util")
local futures = require("futures")
local Process = futures.Process

---@type futures.Process|nil
local _marp

local M = {}

---Check if current file can use marp.
---@return boolean
function M.is_marp()
    local line_count = vim.api.nvim_buf_line_count(0)

    if line_count < 3
        or not vim.bo.filetype
        or vim.tbl_contains(vim.split(vim.bo.filetype, "."), "markdown")
        or vim.trim(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]) ~= "---" then
        return false
    end

    local sep = vim.regex [[\v^\-{3,}\s*$]]
    local m = vim.regex [[\v^marp:\s*true\s*$]]

    for i = 1, line_count - 1, 1 do
        if m:match_line(0, i) then
            return true
        elseif sep:match_line(0, i) then
            return false
        end
    end

    return false
end

---@private
function M.start()
    _marp = Process.new("marp", {
        args = {
            "--html",
            "--server",
            lib.get_buf_dir()
        },
        cwd = lib.get_buf_dir(),
    }):continue_with(function()
        print("Marp: Exit")
    end)

    _marp.on_stderr = function (data)
        local m = data:match("Start server listened at (http://localhost:%d+/)")
        if not m then return end
        if util.sys_open(m) then
            print("Marp: Connected")
        else
            print("Marp: Failed to connect")
        end
    end

    if _marp:start() then
        print("Marp: started")
    else
        _marp = nil
        print("Marp: Failed to start")
    end
end

---@private
function M.stop()
    if _marp then
        _marp:kill()
        _marp = nil
    end
end

---Toggle marp server.
function M.toggle()
    if _marp then
        M.stop()
    else
        M.start()
    end
end

return M
