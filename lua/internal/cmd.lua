-- Echo time(May be useful in full screen?)
vim.cmd('command! Time :echo strftime("%Y-%m-%d %a %T")')
-- LaTeX
vim.cmd('command! Xe1 lua require("utility/util").latex_xelatex()')
vim.cmd('command! Xe2 lua require("utility/util").latex_xelatex2()')
vim.cmd('command! Bib lua require("utility/util").latex_biber()')
vim.cmd('command! PDF lua require("utility/util").open(vim.fn.expand("%:r")..".pdf")')
-- Run or compile
vim.cmd('command! -nargs=? CodeRun lua require("utility/util").run_or_compile(<q-args>)')
-- Git push all
vim.cmd('command! -nargs=* PushAll lua require("utility/util").git_push_all(<f-args>)')


-- vim-orgmode
vim.cmd('command! OrgAgenda :exe ":tabnew" g:org_agenda_path')
-- vimtex
vim.cmd('augroup completion_nvim_enable_all')
vim.cmd('autocmd!')
vim.cmd('au BufEnter * lua require("completion").on_attach()')
vim.cmd('augroup end')
-- nvim-lspconfig
vim.cmd('augroup lsp_diagnositic_on_hold')
vim.cmd('autocmd!')
vim.cmd('au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')
vim.cmd('augroup end')
