vim.g.mapleader = " "

vim.g.path_home = core_opt.path.home
vim.g.path_cloud = core_opt.path.cloud
vim.g.path_desktop = core_opt.path.desktop
vim.g.path_bin = core_opt.path.bin

if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = core_opt.dep.py3
    or vim.fn.expand('$LOCALAPPDATA/Programs/Python/Python38/python')
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    vim.g.python3_host_prog = core_opt.dep.py3 or '/usr/bin/python3'
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = core_opt.dep.py3 or '/usr/bin/python3'
end

-- GUI
vim.g.gui_font_half  = core_opt.gui.font_half
vim.g.gui_font_full  = core_opt.gui.font_full
vim.g.gui_font_size  = core_opt.gui.font_size
vim.g.gui_background = core_opt.gui.theme
vim.g.gui_opacity    = core_opt.gui.opacity

-- Directional operation which won't break the history.
vim.g.const_dir_l = vim.api.nvim_replace_termcodes("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = vim.api.nvim_replace_termcodes("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = vim.api.nvim_replace_termcodes("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = vim.api.nvim_replace_termcodes("<C-G>U<Right>", true, false, true)
