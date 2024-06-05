vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.textwidth = 0
vim.wo.linebreak = false
vim.wo.wrap = false
vim.b.table_mode_corner = "|"

if vim.fn.executable("marp") ~= 1 then
  vim.b.presenting_slide_separator = [[\v(^|\n)(-{3,}|\ze#{1,3}[^#])]]
end

local _opt = { noremap = true, silent = true, buffer = true }

require("utility.util").set_srd_shortcuts({
  ["<M-P>"] = { "`", [[\v(markdown|Vimwiki)Code|raw]] },
  ["<M-I>"] = { "*", [[\v(markdown|Vimwiki)Italic|italic]] },
  ["<M-B>"] = { "**", [[\v(markdown|Vimwiki)Bold|strong]] },
  ["<M-M>"] = { "***", [[\v(markdown|Vimwiki)BoldItalic|strong|italic]] },
  ["<M-U>"] = { "<u>", [[\v(html|Vimwiki)Underline]] },
}, _opt)
vim.keymap.set("n", "<F5>", "<Cmd>PresentingStart<CR>", _opt)
vim.keymap.set("n", "<leader>mt", function()
  if vim.g.vscode then
    vim.fn.VSCodeNotify("markdown.showPreviewToSide")
  elseif require("utility.marp").is_marp() then
    require("utility.marp").toggle()
  elseif vim.api.nvim_buf_get_commands(0, {}).MarkdownPreviewToggle then
    vim.cmd.MarkdownPreviewToggle()
  end
end, _opt)
