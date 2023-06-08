local lib = require("utility.lib")
local lang = require("utility.lang")
local bufnr = vim.api.nvim_get_current_buf()

-- Doxygen comment (///).
vim.defer_fn(function()
    require("utility.util").new_keymap("i", "/", function(fallback)
        local indent = lib.get_context().b:match("^(%s*)//$")
        if not indent then
            fallback()
            return
        end
        local summary = "/ @brief "
        if not vim.treesitter.highlighter.active[bufnr] then
            lib.feedkeys(summary, "n", true)
            return
        end
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        --- Find function definition from **next line**.
        local func_def = lang.cpp.find_parent(bufnr, row + 1, col, "function_definition")
        if not func_def or func_def:range() ~= row then
            fallback()
            return
        end
        local return_type, param_list = lang.cpp.get_func_def(func_def, bufnr)
        local feed = { summary }
        if param_list and param_list:any() then
            for _, v in param_list:iter() do
                table.insert(feed, indent .. "/// @param " .. v .. " ")
            end
        end
        if return_type and return_type ~= "void" then
            table.insert(feed, indent .. "/// @return ")
        end
        vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, feed)
        vim.api.nvim_win_set_cursor(0, { row, col + #summary })
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
