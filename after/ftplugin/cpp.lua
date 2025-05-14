local bufnr = vim.api.nvim_get_current_buf()

---Check if next line needs docmentation.
---@param bufnr_ integer Buffer number.
---@param row_ integer Row (1-indexed)
---@param col_ integer Colomn (0-indexed)
---@param indent_ string Indentation.
---@return string[]|nil feed_ Lines to feed.
local function check_next_line(bufnr_, row_, col_, indent_)
  local feed_ = {
    "**",
    indent_ .. " * @brief ",
    indent_ .. " *"
  }

  local syn = require("utility.syn")
  local node = vim.treesitter.get_node {
    bufnr = bufnr_,
    pos = { row_ - 1, col_ }
  }
  local query = vim.treesitter.query.get("cpp", "cmtdoc")
  if not node or not query then
    return
  end
  local end_ = node:end_()
  local captures = syn.captures_reverse_lookup(query)
  for _, match, metadata in query:iter_matches(node, bufnr_, row_, end_, { all = true }) do
    if match[captures.type] then
      for _, root in ipairs(match[captures.type]) do
        if metadata.kind == "func_decl" then
          root = syn.Node.new(root):find_ancestor {
            "function_definition",
            "field_declaration",
            "declaration",
          }.node
        end
        if root and root:start() == row_ then
          -- No more comments after comment.
          if row_ > 1 then
            local prev = vim.treesitter.get_node {
              bufnr = bufnr_,
              pos = { row_ - 2, col_ }
            }
            if prev and prev:type() == "comment" then
              return
            end
          end

          if metadata.kind == "func_decl" and match[captures.params] then
            for _, param_list in ipairs(match[captures.params]) do
              local params = syn.cpp.extract_params(param_list, bufnr_)
              if params and params:any() then
                for _, v in params:iter() do
                  table.insert(feed_, indent_ .. " * @param " .. v .. " ")
                end
              end
              local type_ = syn.Node.new(root):find_first_child {
                "primitive_type",
                "type_identifier",
                "qualified_identifier",
                "template_type",
              }
              -- TODO: `void` return type should not insert the `@return` field.
              if not type_:is_nil() then
                table.insert(feed_, indent_ .. " * @return ")
              end
            end
          end
          table.insert(feed_, indent_ .. " */")
          return feed_
        end
      end
    end
  end
end

-- Add doxygen comment.
vim.defer_fn(function()
  require("utility.util").new_keymap("i", "/", function(fallback)
    local bufnr_ = vim.api.nvim_get_current_buf()

    if not vim.treesitter.highlighter.active[bufnr_] then
      fallback()
      return
    end

    local indent = require("utility.lib").get_half_line(-1).b:match("^(%s*)//$")
    if not indent then
      fallback()
      return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local summary = check_next_line(bufnr_, row, col, indent)
    if not summary then
      fallback()
      return
    end

    vim.api.nvim_buf_set_text(bufnr_, row - 1, col - 1, row - 1, col, summary)
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #summary[2] })
  end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
