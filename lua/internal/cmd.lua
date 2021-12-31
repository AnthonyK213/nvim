-- Echo time(May be useful in full screen?)
vim.cmd('command! Time echo strftime("%Y-%m-%d %a %T")')
-- Open pdf file, useful when finish the compilation of tex file.
vim.cmd('command! PDF lua require("utility.util").open_path_or_url(vim.fn.expand("%:p:r")..".pdf")')
-- Run or compile
vim.cmd('command! -nargs=? -complete=custom,usr#misc#run_code_option CodeRun lua require("utility.comp").run_or_compile(<q-args>)')
-- Git push all
vim.cmd('command! -nargs=* PushAll lua require("utility.vcs").git_push_all(<f-args>)')
-- Neovim nightly upgrade.
vim.cmd('command! -nargs=* NightlyUpgrade call usr#misc#nvim_nightly_upgrade(<f-args>)')
-- Open ssh configuration.
vim.cmd('command! SshConfig lua require("utility.util").edit_file("$HOME/.ssh/config", false)')
-- Scroll off
require('utility.lib').set_augroup('scroll_off', 'BufEnter * setlocal so=5', 'BufEnter *.md setlocal so=999')
