local core_opt = require('core/opt')

vim.g.mapleader = " "

vim.g.path_home = core_opt.path.home or vim.env.HOME
vim.g.path_cloud = core_opt.path.cloud or vim.env.ONEDRIVE or vim.g.path_home
vim.g.path_desktop = core_opt.path.desktop or vim.fn.expand(vim.g.path_home..'/Desktop')
vim.g.path_bin = core_opt.path.bin or vim.fn.expand(vim.g.path_home..'/bin')

if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = core_opt.dep.py3 or
    vim.fn.expand('$LOCALAPPDATA/Programs/Python/Python38/python')
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
if core_opt.gui then
    if core_opt.gui.font_half then
        vim.g.gui_font_half = core_opt.gui.font_half
    end
    if core_opt.gui.font_full then
        vim.g.gui_font_full = core_opt.gui.font_full
    end
    if core_opt.gui.font_size then
        vim.g.gui_font_size = core_opt.gui.font_size
    end
    if core_opt.gui.bg then
        vim.g.gui_background = core_opt.gui.bg
    end
end

-- Directional operation which won't break the history.
vim.g.const_dir_l = vim.api.nvim_replace_termcodes("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = vim.api.nvim_replace_termcodes("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = vim.api.nvim_replace_termcodes("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = vim.api.nvim_replace_termcodes("<C-G>U<Right>", true, false, true)
