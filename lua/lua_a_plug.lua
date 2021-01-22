vim.cmd('packadd paq-nvim')
local paq = require('paq-nvim').paq


paq {'savq/paq-nvim', opt=true}
-- Visual
paq {'joshdick/onedark.vim'}
paq {'vim-airline/vim-airline'}
-- Tree manager
paq {'preservim/nerdtree'}
-- Git utilities
paq {'tpope/vim-fugitive'}
paq {'mhinz/vim-signify'}
paq {'Xuyuanp/nerdtree-git-plugin'}
-- Utilities
paq {'AnthonyK213/vim-ipairs'}
paq {'norcalli/nvim-colorizer.lua'}
paq {'Yggdroot/indentLine'}
paq {'tpope/vim-speeddating'}
paq {'dhruvasagar/vim-table-mode'}
-- File type support
paq {'lervag/vimtex'}
paq {'jceb/vim-orgmode'}
paq {'plasticboy/vim-markdown'}
paq {'sophacles/vim-processing'}
paq {'iamcco/markdown-preview.nvim', hook='cd app && yarn install'}
--  Completion; LSP
paq {'neoclide/coc.nvim', branch='release'}
