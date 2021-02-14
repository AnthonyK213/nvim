local init_src = vim.g.init_src or 'one'


-- Source .vim file in configuration directory.
local function vsource(file)
    if (vim.fn.has("win32") == 1) then
        init_viml_path = vim.fn.expand("$localappdata")..'/nvim/'
    elseif (vim.fn.has("unix") == 1) then
        init_viml_path = '~/.config/nvim/'
    end
    local src_cmd = 'source '..init_viml_path..file..'.vim'
    vim.api.nvim_exec(src_cmd, false)
end


vsource('viml/basics')
require('internal/var')
require('internal/map')
require('internal/cmd')
require('package/paq')
require('package/config')
require('package/inter')

if (init_src == 'nano') then
    vim.o.tgc = true
    vim.o.bg  = 'dark'
    vim.cmd('colorscheme nanovim')
elseif (init_src == 'one') then
    require('package/ui')
end
