-- Directional operation which won't mess up the history.
vim.g.const_dir_l = vim.fn.nvim_replace_termcodes("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = vim.fn.nvim_replace_termcodes("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = vim.fn.nvim_replace_termcodes("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = vim.fn.nvim_replace_termcodes("<C-G>U<Right>", true, false, true)

local lib = require("utility/lib")

if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = lib.get_var(
    vim.g.python3_exec_path, vim.fn.expand('$HOME/Appdata/Local/Programs/Python/Python38/python.EXE'))
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    vim.g.python3_host_prog = lib.get_var(vim.g.python3_exec_path, '/usr/bin/python3')
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = lib.get_var(vim.g.python3_exec_path, '/usr/bin/python3')
end