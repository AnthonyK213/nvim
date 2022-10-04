vim.keymap.set("n", "c", "<Cmd>Cheat<CR>", { noremap = true, buffer = true })
vim.keymap.set("n", "u", "<Cmd>Undo<CR>", { noremap = true, buffer = true })
vim.keymap.set("n", "q", [[<Cmd>bd<CR>]], { noremap = true, buffer = true })
vim.keymap.set("n", "s", function ()
    local mode_table = { "black", "white", "manual" }
    if vim.b.runner and vim.fn.exists(":ChangeMode") == 2 then
        local mode = vim.b.runner.mode
        local index = vim.tbl_add_reverse_lookup(mode_table)[mode]
        local next = mode_table[index % 3 + 1]
        vim.cmd.ChangeMode(next)
        vim.notify("Mode changed to "..next)
    end
end, { noremap = true, buffer = true })
