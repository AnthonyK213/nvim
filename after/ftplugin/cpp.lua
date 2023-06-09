local lib = require("utility.lib")
local syn = require("utility.syn")
local bufnr = vim.api.nvim_get_current_buf()

---Find function definition/declaration from **next line**.
---@return boolean
local function func_next_line(bufnr_, row_, col_, indent_, feed_)
    local func_obj = syn.find_parent(bufnr_, row_ + 1, col_, function(item)
        return vim.list_contains({
            "function_definition",
            "declaration",
            "field_declaration",
            "template_declaration",
            -- "friend_declaration",
        }, item:type())
    end)
    if func_obj and func_obj:range() == row_ then
        local return_type, param_list = syn.cpp.get_func_signature(func_obj, bufnr)
        if param_list and param_list:any() then
            for _, v in param_list:iter() do
                table.insert(feed_, indent_ .. "/// @param " .. v .. " ")
            end
        end
        if return_type and return_type ~= "void" then
            table.insert(feed_, indent_ .. "/// @return ")
        end
        return true
    end
    return false
end

---Find struct/class/namespace from **next line**.
---@return boolean
local function spec_next_line(bufnr_, row_, col_, _, _)
    local spec_obj = syn.find_parent(bufnr_, row_ + 1, col_, function(item)
        return vim.endswith(item:type(), "_specifier")
            or item:type() == "namespace_definition"
    end)
    if spec_obj and spec_obj:range() == row_ then
        return true
    end
    return false
end

---@type (fun(bufnr: integer, row: integer, col: integer, indent?: string, feed?: string[]):boolean)[]
local find_seq = {
    func_next_line,
    spec_next_line,
}

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
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        for _, f in ipairs(find_seq) do
            if f(bufnr, row, col, indent, feed) then
                vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, feed)
                vim.api.nvim_win_set_cursor(0, { row, col + #summary })
                return
            end
        end

        fallback()
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
