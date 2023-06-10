local bufnr = vim.api.nvim_get_current_buf()

---Check if next line needs docmentation.
---@param bufnr_ integer Buffer number.
---@param row_ integer Row (1-indexed)
---@param _ integer Colomn (0-indexed)
---@param indent_ string Indentation.
---@param feed_ collections.List List to feed.
---@return boolean
local function check_next_line(bufnr_, row_, _, indent_, feed_)
    local syn = require("utility.syn")
    local node = vim.treesitter.get_node()
    local query = vim.treesitter.query.get("cpp", "cmtdoc")
    local end_ = node:end_()
    for _, match, metadata in query:iter_matches(node, bufnr_, row_, end_) do
        local root = match[1]
        if metadata.kind == "func_decl" then
            root = syn.Node.new(root):find_ancestor {
                "function_definition",
                "function_declaration",
                "declaration",
            }.node
        end
        if root and root:start() == row_ then
            if metadata.kind == "func_decl" then
                local param_list = match[3]
                local params = syn.cpp.extract_params(param_list, bufnr_)
                if params and params:any() then
                    for _, v in params:iter() do
                        table.insert(feed_, indent_ .. "/// @param " .. v .. " ")
                    end
                end
                local type_ = syn.Node.new(root):find_first_child {
                    "primitive_type",
                    "type_identifier",
                    "qualified_identifier",
                }
                -- TODO: After any comment should not insert the doxygen comment.
                -- TODO: `void` return type should not insert the `@return` field.
                if not type_:is_nil() then
                    table.insert(feed_, indent_ .. "/// @return ")
                end
            end
            return true
        end
    end
    return false
end

-- Doxygen comment (///).
vim.defer_fn(function()
    require("utility.util").new_keymap("i", "/", function(fallback)
        local indent = require("utility.lib").get_context().b:match("^(%s*)//$")
        local summary = { "/ @brief " }
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local bufnr_ = vim.api.nvim_get_current_buf()

        if indent and (not vim.treesitter.highlighter.active[bufnr_]
                or check_next_line(bufnr_, row, col, indent, summary)) then
            vim.api.nvim_buf_set_text(bufnr_, row - 1, col, row - 1, col, summary)
            vim.api.nvim_win_set_cursor(0, { row, col + #summary[1] })
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)