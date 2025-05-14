local bufnr = vim.api.nvim_get_current_buf()

---Check if next line needs docmentation.
---@param bufnr_ integer Buffer number.
---@param row_ integer Row (1-indexed)
---@param col_ integer Colomn (0-indexed)
---@param indent_ string Indentation.
---@return string[]|nil feed_ Lines to feed.
local function check_next_line(bufnr_, row_, col_, indent_)
  local feed_ = {
    "/ <summary>",
    indent_ .. "/// ",
    indent_ .. "/// </summary>",
  }

  local syn = require("utility.syn")
  local node = vim.treesitter.get_node {
    bufnr = bufnr_,
    pos = { row_ - 1, col_ }
  }
  local query = vim.treesitter.query.get("c_sharp", "cmtdoc")
  if not node or not query then
    return
  end
  local end_ = node:end_()
  local captures = syn.captures_reverse_lookup(query)
  for _, match, metadata in query:iter_matches(node, bufnr_, row_, end_, { all = true }) do
    if match[captures.type] then
      for _, root in ipairs(match[captures.type]) do
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
          if metadata.kind == "function" then
            -- FIXME: `return-type` does not work.
            local type_ = match[captures.returns] and match[captures.returns][1]
            local param_list = match[captures.params][1]
            local params = syn.cs.extract_params(param_list, bufnr_)
            if params and params:any() then
              for _, v in params:iter() do
                table.insert(feed_,
                  string.format([[%s/// <param name="%s"></param>]],
                    indent_, v))
              end
            end
            if type_ and vim.treesitter.get_node_text(type_, bufnr_) ~= "void" then
              table.insert(feed_, indent_ .. "/// <returns></returns>")
            end
          end
          return feed_
        end
      end
    end
  end
end

-- XML comment (///).
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

    vim.api.nvim_buf_set_text(bufnr_, row - 1, col, row - 1, col, summary)
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #summary[2] })
  end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
