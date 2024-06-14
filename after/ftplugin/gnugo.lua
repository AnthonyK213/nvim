vim.keymap.set("n", "c", "<Cmd>Cheat<CR>", { noremap = true, buffer = true })
vim.keymap.set("n", "u", "<Cmd>Undo<CR>", { noremap = true, buffer = true })
vim.keymap.set("n", "q", [[<Cmd>bd<CR>]], { noremap = true, buffer = true })
vim.keymap.set("n", "s", function()
  local mode_enum = { black = 1, white = 2, manual = 3 }
  if vim.b.runner and vim.api.nvim_buf_get_commands(0, {}).ChangeMode then
    local mode = vim.b.runner.mode
    local index = mode_enum[mode]
    local next = mode_enum[index % 3 + 1]
    vim.cmd.ChangeMode(next)
    vim.notify("Mode changed to " .. next)
  end
end, { noremap = true, buffer = true })
