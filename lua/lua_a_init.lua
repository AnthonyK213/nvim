if (vim.g.init_src) then
    init_src = vim.g.init_src
else
    init_src = 'one'
end

if (vim.fn.has("win32") == 1) then
    init_viml_path = vim.fn.expand("$localappdata")..'/nvim/viml/viml_'
elseif (vim.fn.has("unix") == 1) then
    init_viml_path = '~/.config/nvim/viml/viml_'
end


function init_source(file)
    local src_cmd = 'source '..init_viml_path..file..'.vim'
    vim.api.nvim_exec(src_cmd, false)
end


require('lua_a_plug')
init_source('basics')
init_source('custom')
require('lua_deflib')
require('lua_fnutil')
require('lua_plugrc')

if (init_src == 'nano') then
    vim.o.tgc = true
    vim.o.bg  = 'dark'
    vim.cmd('colorscheme nanovim')
elseif (init_src == 'one') then
    require('lua_uiconf')
end
