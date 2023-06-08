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

        local feed = { summary }
        local set_text = false
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        if not set_text then
            --- Find function definition/declaration from **next line**.
            local func_obj = lang.cpp.find_parent(bufnr, row + 1, col, function(item)
                return vim.list_contains({
                    "function_definition",
                    "declaration",
                    "field_declaration",
                    "template_declaration",
                    -- "friend_declaration",
                }, item:type())
            end)
            if func_obj and func_obj:range() == row then
                local return_type, param_list = lang.cpp.get_func_signature(func_obj, bufnr)
                if param_list and param_list:any() then
                    for _, v in param_list:iter() do
                        table.insert(feed, indent .. "/// @param " .. v .. " ")
                    end
                end
                if return_type and return_type ~= "void" then
                    table.insert(feed, indent .. "/// @return ")
                end
                set_text = true
            end
        end

        if not set_text then
            --- Find struct/class/namespace from **next line**.
            local spec_obj = lang.cpp.find_parent(bufnr, row + 1, col, function(item)
                return vim.endswith(item:type(), "_specifier")
                    or item:type() == "namespace_definition"
            end)
            if spec_obj and spec_obj:range() == row then
                set_text = true
            end
        end

        if set_text then
            vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, feed)
            vim.api.nvim_win_set_cursor(0, { row, col + #summary })
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
