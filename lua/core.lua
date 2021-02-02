local lib = require("utility/lib")
local init_src = lib.get_var(vim.g.init_src, 'one')

require('package/paq')
lib.viml_source('viml/viml_basics')
lib.viml_source('viml/viml_custom')
require('internal/var')
require('internal/map')
require('internal/cmd')
require('package/config')

if (init_src == 'nano') then
    vim.o.tgc = true
    vim.o.bg  = 'dark'
    vim.cmd('colorscheme nanovim')
elseif (init_src == 'one') then
    require('package/ui')
end
