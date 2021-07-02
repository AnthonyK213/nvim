-- Vim script
require('utility/lib').vim_source('viml/basics')

-- Internal settings
require('internal/var')
require('internal/map')
require('internal/cmd')

-- Package configurations
require('package/packer')
require('package/config')
require('package/inter')

-- Color scheme
vim.o.bg = require('core/opt').tui.bg or 'dark'
local nvim_init_src = vim.g.nvim_init_src or vim.fn.expand('$NVIM_INIT_SRC')

if nvim_init_src == 'nano' then
    vim.o.tgc = true
    vim.cmd('colorscheme nanovim')
else
    require('package/ui')
end
