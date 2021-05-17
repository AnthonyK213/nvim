local fn = vim.fn
local core_opt = require('core/opt')
local rep_term = vim.api.nvim_replace_termcodes

vim.g.mapleader = " "

local path = core_opt.path or {}
vim.g.path_home = path.home or fn.expand('$HOME')
vim.g.path_cloud = path.cloud or fn.expand('$ONEDRIVE')
vim.g.path_desktop = path.desktop or fn.expand(vim.g.path_home..'/Desktop')

if fn.has("win32") == 1 then
    vim.g.python3_host_prog =
    core_opt.py3 or
    fn.expand('$LOCALAPPDATA/Programs/Python/Python38/python')
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif fn.has("unix") == 1 then
    vim.g.python3_host_prog = core_opt.py3 or '/usr/bin/python3'
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif fn.has("mac") == 1 then
    vim.g.python3_host_prog = core_opt.py3 or '/usr/bin/python3'
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

-- Directional operation which won't mess up the history.
vim.g.const_dir_l = rep_term("<C-G>U<Left>",  true, false, true)
vim.g.const_dir_d = rep_term("<C-G>U<Down>",  true, false, true)
vim.g.const_dir_u = rep_term("<C-G>U<Up>",    true, false, true)
vim.g.const_dir_r = rep_term("<C-G>U<Right>", true, false, true)
