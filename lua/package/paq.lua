vim.cmd('packadd paq-nvim')
local paq = require('paq-nvim').paq


paq {'savq/paq-nvim', opt=true}
-- Visual
paq {'rakr/vim-one', opt=true}
paq {'glepnir/galaxyline.nvim', branch='main', opt=true}
paq {'akinsho/nvim-bufferline.lua', opt=true}
paq {'norcalli/nvim-colorizer.lua', opt=true}
-- Tree manager
paq {'preservim/nerdtree'}
-- Git utilities
paq {'tpope/vim-fugitive'}
paq {'mhinz/vim-signify'}
paq {'Xuyuanp/nerdtree-git-plugin'}
-- Utilities
paq {'AnthonyK213/vim-ipairs', branch='dev'}
paq {'Yggdroot/indentLine'}
paq {'tpope/vim-speeddating'}
paq {'dhruvasagar/vim-table-mode'}
paq {'nvim-treesitter/nvim-treesitter'}
-- File type support
paq {'lervag/vimtex'}
paq {'jceb/vim-orgmode'}
paq {'plasticboy/vim-markdown'}
paq {'sophacles/vim-processing'}
paq {'iamcco/markdown-preview.nvim', hook=vim.fn['mkdp#util#install']}
-- Completion; LSP
paq {'SirVer/ultisnips'}
paq {'honza/vim-snippets'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-lua/completion-nvim'}
paq {'tjdevries/lsp_extensions.nvim'}
paq {'nvim-treesitter/completion-treesitter'}
