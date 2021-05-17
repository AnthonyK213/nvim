-- Source .vim file in configuration directory.
local function vsource(file)
    local init_viml_path
    if (vim.fn.has("win32") == 1) then
        init_viml_path = vim.fn.expand("$localappdata/nvim/")
    elseif (vim.fn.has("unix") == 1) then
        init_viml_path = '~/.config/nvim/'
    end
    vim.cmd('source '..init_viml_path..file..'.vim')
end


-- Vim script
vsource('viml/basics')

-- Internal settings
require('internal/var')
require('internal/map')
require('internal/cmd')

-- Package configurations
require('package/paq')
require('package/config')
require('package/inter')

-- Color scheme
vim.o.bg = require('core/opt').tui.bg or 'dark'
local init_src = vim.g.init_src or 'one'

if init_src == 'nano' then
    vim.o.tgc = true
    vim.cmd('colorscheme nanovim')
elseif init_src == 'one' then
    require('package/ui')
end
