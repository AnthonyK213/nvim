local lib = require("utility.lib")

local M = {}

---@private
---@type table<integer, futures.Process>
M.tbl = {}

---@private
---@param bufnr? integer
---@return integer
local function _bufnr(bufnr)
    if bufnr == 0 or not bufnr then
        return vim.api.nvim_get_current_buf()
    end
    return bufnr
end

---Start glslViewer.
---@param bufnr any
function M.start(bufnr)
    bufnr = _bufnr(bufnr)

    if M.tbl[bufnr] and not M.tbl[bufnr].has_exited then
        vim.notify("glslViewer is already running")
        return
    end

    local viewer = require("futures").Process.new("glslViewer", {
        args = { vim.api.nvim_buf_get_name(bufnr) },
        cwd = lib.get_buf_dir(bufnr),
    }):continue_with(function() print("glslViewer: Exit") end)

    viewer.on_stdout = function(data)
        local lines = vim.split(data, "[\n\r]", {
            plain = false,
            trimempty = true,
        })
        local output = vim.tbl_filter(function(v)
            return not vim.startswith(v, "// >")
        end, lines)
        if #output > 0 then
            local header = "glslViewer output"
            local cnt = bit.rshift(math.max(vim.o.columns - 17, 0), 1)
            local sep = string.rep("-", cnt)
            table.insert(output, 1, sep .. header .. sep)
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
    bufnr = _bufnr(bufnr)
    if M.tbl[bufnr] then
        M.tbl[bufnr]:kill()
        M.tbl[bufnr] = nil
    end
end

---@param bufnr integer
---@param data string
function M.input(bufnr, data)
    local proc = M.tbl[_bufnr(bufnr)]
    if not proc then
        lib.notify_err("glslViewer is not running!")
        return
    end
    proc:write(data)
end

return M
