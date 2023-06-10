local lib = require("utility.lib")
local syn = require("utility.syn")
local bufnr = vim.api.nvim_get_current_buf()

---Check if next line needs docmentation.
---@param bufnr_ integer
---@param row_ integer
---@param col_ integer
---@param indent_ string
---@param feed_ collections.List
---@return boolean
local function check_next_line(bufnr_, row_, col_, indent_, feed_)
    local node = vim.treesitter.get_node()
    local query = vim.treesitter.query.get("cpp", "cmtdoc")
    local end_ = node:end_()
    for _, match, metadata in query:iter_matches(node, bufnr_, row_, end_) do
        if match[1]:start() == row_ then
            if metadata.kind == "func_decl" then
                local params = syn.cpp.extract_params(match[3], bufnr_)
                if params and params:any() then
                    for _, v in params:iter() do
                        table.insert(feed_, indent_ .. "/// @param " .. v .. " ")
                    end
                end
                -- TODO: Find the `function` ancestor.
                table.insert(feed_, indent_ .. "/// @return ")
            end
            return true
        end
    end
    return false
end

-- Doxygen comment (///).
vim.defer_fn(function()
    require("utility.util").new_keymap("i", "/", function(fallback)
        local indent = lib.get_context().b:match("^(%s*)//$")
        local summary = { "/ @brief " }
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        if indent and (check_next_line(bufnr, row, col, indent, summary)
            or not vim.treesitter.highlighter.active[bufnr]) then
            vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, summary)
            vim.api.nvim_win_set_cursor(0, { row, col + #summary[1] })
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
