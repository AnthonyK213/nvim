local bufnr = vim.api.nvim_get_current_buf()

vim.defer_fn(function()
  require("utility.util").new_keymap("i", '"', function(fallback)
    local indent = require("utility.lib")
        .get_context().b:match('^(%s*)""$')

    if indent then
      local bufnr_ = vim.api.nvim_get_current_buf()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_text(bufnr_, row - 1, col, row - 1, col, {
        [["]],
        indent,
        indent .. [["""]],
      })
      vim.api.nvim_win_set_cursor(0, { row + 1, col + #indent })
    else
      fallback()
    end
  end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
