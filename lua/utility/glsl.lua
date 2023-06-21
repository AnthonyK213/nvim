local lib = require("utility.lib")
local futures = require("futures")

local M = {}

---@private
---@type table<integer, futures.Process>
M.tbl = {}

---@private
---@param bufnr integer
---@return boolean
function M.is_alive(bufnr)
    if M.tbl[bufnr] and not M.tbl[bufnr].has_exited then
        return true
    end
    return false
end

---Start glslViewer.
---@param bufnr? integer
---@param fargs? string[]
function M.start(bufnr, fargs)
    bufnr = lib.bufnr(bufnr)
    fargs = fargs or {}

    if M.is_alive(bufnr) then
        vim.notify("glslViewer is already running")
        return
    end

    local viewer = futures.Process.new("glslViewer", {
        args = fargs,
        cwd = lib.get_buf_dir(bufnr),
    }):continue_with(function() print("glslViewer: Exit") end)

    viewer.on_stdout = function(data)
        local lines = vim.split(data, "[\n\r]", {
            plain = false,
            trimempty = true,
        })
        local output = vim.tbl_filter(function(v)
            return not (vim.startswith(v, "// >") or v:match("^%s*$"))
        end, lines)
        if #output > 0 then
            vim.notify(table.concat(output, "\n"))
        end
    end

    if viewer:start() then
        M.tbl[bufnr] = viewer
        vim.api.nvim_buf_attach(bufnr, false, {
            on_detach = function(_, h) M.stop(h) end
        })
        print("glslViewer: Started")
    else
        print("glslViewer: Failed to start")
    end
end

---Stop glslViewer attached to the buffer.
---@param bufnr? integer
function M.stop(bufnr)
    bufnr = lib.bufnr(bufnr)
    if M.tbl[bufnr] then
        M.tbl[bufnr]:kill()
        M.tbl[bufnr] = nil
    end
end

---@param bufnr? integer
function M.toggle(bufnr)
    bufnr = lib.bufnr(bufnr)
    if M.is_alive(bufnr) then
        M.stop(bufnr)
    else
        M.start(bufnr, { vim.api.nvim_buf_get_name(bufnr) })
    end
end

---@param bufnr? integer
function M.input(bufnr)
    bufnr = lib.bufnr(bufnr)
    if not M.is_alive(bufnr) then
        lib.notify_err("glslViewer is not running!")
        return
    end

    futures.spawn(function()
        local data = futures.ui.input { prompt = "glslViewer", kind = "editor" }
        if not data or #data == 0 then return end
        print("// > " .. data)
        M.tbl[bufnr]:write(data .. "\r\n")
    end)
end

return M
