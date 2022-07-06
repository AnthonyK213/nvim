vim.bo.textwidth = 0
vim.wo.wrap = false
vim.wo.linebreak = false
vim.b.table_mode_corner = "|"

local srd_table = {
    P = {"`", "\\vmarkdown(Code|TSLiteral)"},
    I = {"*", "\\vmarkdown(Italic|TSEmphasis)"},
    B = {"**", "\\vmarkdown(Bold|TSStrong)"},
    M = {"***", "markdownBoldItalic"},
    U = {"<u>", "htmlUnderline"}
}
local _opt = { noremap = true, silent = true, buffer = true }
for key, val in pairs(srd_table) do
    vim.keymap.set({ "n", "v" }, "<M-"..key..">", function ()
        local m = vim.api.nvim_get_mode().mode
        local mode
        if m == "n" then mode = "n"
        elseif vim.tbl_contains({ "v", "V", "" }, m) then mode = "v"
        else return end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        if require("utility.syn").new(row, col):match(val[2]) then
            require("utility.srd").srd_sub("", val[1])
        else
            require("utility.srd").srd_add(mode, val[1])
        end
    end, _opt)
end
vim.keymap.set("n", "<F5>", "<Cmd>PresentingStart<CR>", _opt)
vim.keymap.set("n", "<leader>mt", function ()
    if vim.fn.exists("g:vscode") > 0 then
        vim.fn.VSCodeNotify("markdown.showPreviewToSide")
    elseif vim.fn.exists(":MarkdownPreviewToggle") > 0 then
        vim.cmd[[MarkdownPreviewToggle]]
    end
end, _opt)
