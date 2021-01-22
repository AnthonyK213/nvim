vim.api.nvim_exec([[
    " let g:default_shell = 'zsh'
    " let g:default_c_compiler = 'clang'
    " let g:python3_exec_path = '/usr/bin/python3'
    ]])


if not vim.g.init_src then
    init_src = 'full'
else
    init_src = vim.g.init_src
end

local function init_source(file)
    local init_path = vim.fn.expand("$localappdata")..'/nvim/init/init_'
    local src_cmd = 'source '..init_path..file..'.vim'
    vim.api.nvim_exec(src_cmd, false)
end

if (init_src == 'clean') then
    init_source('basics')
    init_source('custom')
elseif (init_src == 'nano') then
    init_source('basics')
    init_source('custom')
    require('lua_deflib')
    init_source('deflib')
    require('lua_fnutil')
    init_source('fnutil')
    init_source('subsrc')
    vim.api.nvim_exec([[
        set termguicolors
        set background=dark
        colorscheme nanovim
    ]], false)
elseif (init_src == 'full') then
    require('lua_a_plug')
    init_source('basics')
    init_source('custom')
    require('lua_deflib')
    init_source('deflib')
    require('lua_fnutil')
    init_source('fnutil')
    init_source('plugrc')
end
