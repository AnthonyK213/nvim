---Set global variables according to a table.
---@param tbl table Table of configurations.
---@param prefix string Prefix for the 'g:' variable.
local function tbl_set_var(tbl, prefix)
    for k, v in pairs(tbl) do
        vim.api.nvim_set_var(prefix..k, v)
    end
end

-- Map leader.
vim.g.mapleader = " "

-- Path
tbl_set_var(_my_core_opt.path, "_my_path_")

-- GUI
tbl_set_var(_my_core_opt.gui, "_my_gui_")

-- Directional operation which won't break the history.
local rep_term = vim.api.nvim_replace_termcodes
vim.g._const_dir_l = rep_term("<C-G>U<Left>",  true, false, true)
vim.g._const_dir_d = rep_term("<C-G>U<Down>",  true, false, true)
vim.g._const_dir_u = rep_term("<C-G>U<Up>",    true, false, true)
vim.g._const_dir_r = rep_term("<C-G>U<Right>", true, false, true)

-- Misc
if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = _my_core_opt.dep.py3
    or vim.fn.expand('$LOCALAPPDATA/Programs/Python/Python38/python')
    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    vim.g.python3_host_prog = _my_core_opt.dep.py3 or '/usr/bin/python3'
    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = _my_core_opt.dep.py3 or '/usr/bin/python3'
end
