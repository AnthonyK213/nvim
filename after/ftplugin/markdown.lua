vim.bo.textwidth = 0
vim.wo.wrap = false
vim.wo.linebreak = false
vim.b.table_mode_corner = "|"

local srd_table = { P = "`", I = "*", B = "**", M = "***", U = "<u>" }
local _opt = { noremap = true, silent = true, buffer = true }
for key, val in pairs(srd_table) do
    vim.keymap.set({ "n", "v" }, "<M-"..key..">", function ()
        local m = vim.api.nvim_get_mode().mode
        local mode
        if m == "n" then mode = "n"
        elseif vim.tbl_contains({ "v", "V", "" }, m) then mode = "v"
        else return end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
        require("utility.srd").srd_add(mode, val)
    end, _opt)
end
vim.keymap.set("n", "<F5>", "<Cmd>PresentingStart<CR>", _opt)
vim.keymap.set("n", "<leader>mt", "<Cmd>MarkdownPreviewToggle<CR>", _opt)
