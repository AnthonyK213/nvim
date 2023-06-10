local lib = require("utility.lib")
local syn = require("utility.syn")
local bufnr = vim.api.nvim_get_current_buf()

---Find function definition/declaration from **next line**.
---@return boolean
local function func_next_line(bufnr_, row_, col_, indent_, feed_)
    local func_obj = syn.find_parent(bufnr_, row_ + 1, col_, function(item)
        return vim.list_contains({
            "constructor_declaration",
            "field_declaration",
            "method_declaration",
            "property_declaration",
        }, item:type())
    end)
    if func_obj and func_obj:range() == row_ then
        local return_type, param_list = syn.cs.get_func_signature(func_obj, bufnr_)
        if param_list and param_list:any() then
            for _, v in param_list:iter() do
                table.insert(feed_, string.format([[%s/// <param name="%s"></param>]], indent_, v))
            end
        end
        if return_type and return_type ~= "void" then
            table.insert(feed_, indent_ .. "/// <returns></returns>")
        end
        return true
    end
    return false
end

---Find struct/class/namespace from **next line**.
---@return boolean
local function spec_next_line(bufnr_, row_, col_, _, _)
    local spec_obj = syn.find_parent(bufnr_, row_ + 1, col_, function(item)
        return vim.list_contains({
            "class_declaration",
            "struct_declaration",
            "namespace_declaration",
        }, item:type())
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

-- XML comment (///).
vim.defer_fn(function()
    require("utility.util").new_keymap("i", "/", function(fallback)
        local indent = lib.get_context().b:match("^(%s*)//$")
        if not indent then
            fallback()
            return
        end

        local summary = {
            "/ <summary>",
            indent .. "/// ",
            indent .. "/// </summary>",
        }
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ready = false

        if vim.treesitter.highlighter.active[bufnr] then
            for _, f in ipairs(find_seq) do
                if f(bufnr, row, col, indent, summary) then
                    ready = true
                    break
                end
            end
        else
            ready = true
        end

        if ready then
            vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, summary)
            vim.api.nvim_win_set_cursor(0, { row + 1, col + #summary[2] })
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
