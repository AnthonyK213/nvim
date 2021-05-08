local core_opt = require('core/opt')
local rep_term = vim.api.nvim_replace_termcodes

vim.g.mapleader = " "

if vim.fn.glob(vim.fn.expand('$ONEDRIVE')) ~= '' then
    vim.g.onedrive_path = vim.fn.expand('$ONEDRIVE')
    vim.g.usr_desktop = vim.fn.expand(
    vim.fn.fnamemodify(vim.g.onedrive_path, ':h')..'/Desktop')
else
    vim.g.onedrive_path = vim.fn.expand('$HOME')
    vim.g.usr_desktop = vim.fn.expand('$HOME/Desktop')
end

if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog =
    core_opt.py3 or
    vim.fn.expand('$LOCALAPPDATA/Programs/Python/Python38/python')
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    vim.g.python3_host_prog = core_opt.py3 or '/usr/bin/python3'
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = core_opt.py3 or '/usr/bin/python3'
end

-- GUI
if core_opt.gui then
    vim.g.gui_font_size   = core_opt.gui.font_size
    vim.g.gui_font_family = core_opt.gui.font_family
    vim.g.gui_background  = core_opt.gui.bg or ''
end

-- Directional operation which won't mess up the history.
vim.g.const_dir_l = rep_term("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = rep_term("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = rep_term("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = rep_term("<C-G>U<Right>", true, false, true)
