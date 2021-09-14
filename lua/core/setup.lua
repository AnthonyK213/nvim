-- Vim script
require('utility/lib').vim_source('viml/basics')

-- Internal settings
require('internal/var')
require('internal/map')
require('internal/cmd')

-- Package configurations
require('packages')

-- Color scheme
vim.o.bg = require('core/opt').tui.bg or 'dark'
local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC

vim.o.tgc = true
if nvim_init_src == 'nano' then
    vim.cmd('colorscheme nanovim')
else
    require('packages/ui')
end
