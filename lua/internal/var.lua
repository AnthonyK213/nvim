vim.g.mapleader = " "

if vim.fn.glob(vim.fn.expand('$ONEDRIVE')) ~= '' then
    vim.g.onedrive_path = vim.fn.expand('$ONEDRIVE')
    vim.g.usr_desktop = vim.fn.expand(vim.fn.fnamemodify(vim.g.onedrive_path, ':h')..'/Desktop')
else
    vim.g.onedrive_path = vim.fn.expand('$HOME')
    vim.g.usr_desktop = vim.fn.expand('$HOME/Desktop')
end

if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = vim.g.python3_exec_path or vim.fn.expand('$HOME/Appdata/Local/Programs/Python/Python38/python')
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    vim.g.python3_host_prog = vim.g.python3_exec_path or '/usr/bin/python3'
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = vim.g.python3_exec_path or '/usr/bin/python3'
end

-- Directional operation which won't mess up the history.
vim.g.const_dir_l = vim.api.nvim_replace_termcodes("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = vim.api.nvim_replace_termcodes("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = vim.api.nvim_replace_termcodes("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = vim.api.nvim_replace_termcodes("<C-G>U<Right>", true, false, true)
