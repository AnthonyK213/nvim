local M = {}
local lib = require("utility.lib")
local futures = require("futures")
local spawn, Process = futures.spawn, futures.Process
local _bufnr, _winnr = -1, -1

local function try_focus()
    if vim.api.nvim_buf_is_valid(_bufnr)
        and vim.api.nvim_win_is_valid(_winnr) then
        vim.api.nvim_set_current_win(_winnr)
    end
end

local function preview(result)
    local def = result.definition:gsub("^[\n\r]%*", "\r")
    def = string.format("# %s\r\n__%s__\n%s", result.dict, result.word, def)
    local contents = vim.split(def, "[\r\n]")
    _bufnr, _winnr = vim.lsp.util.open_floating_preview(contents, "markdown", {
        max_height = 20,
        max_width = 50,
        wrap = true,
        border = _my_core_opt.tui.border,
    })
end

local function on_stdout(data)
    local ok, results = pcall(vim.json.decode, data)
    if not ok then
        lib.notify_err(results)
        return
    end
    if #results == 0 then
        print("No information available")
    elseif #results == 1 then
        preview(results[1])
    else
        spawn(function()
            local choice, indice = futures.ui.select(results, {
                prompt = "Select one result:",
                format_item = function(item)
                    return item.word
                end
            })
            if not choice then return end
            preview(results[indice])
        end)
    end
end

function M.stardict(word)
    if not lib.executable("sdcv") then return end
    try_focus()
    local p = Process.new("sdcv", { args = { "-n", "-j", word } })
    p.on_stdout = on_stdout
    p:start()
end

return M
