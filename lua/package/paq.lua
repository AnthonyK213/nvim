vim.cmd('packadd paq-nvim')
local paq = require('paq-nvim').paq


paq {'savq/paq-nvim', opt=true}
-- Visual
paq {'rakr/vim-one', opt=true}
paq {'akinsho/nvim-bufferline.lua', opt=true}
paq {'norcalli/nvim-colorizer.lua', opt=true}
paq {'hoob3rt/lualine.nvim', opt=true}
-- Tree manager
paq {'preservim/nerdtree'}
-- FZF
paq {'junegunn/fzf', hook=vim.fn['fzf#install']}
paq {'junegunn/fzf.vim'}
-- Git utilities
paq {'mhinz/vim-signify'}
paq {'tpope/vim-fugitive'}
paq {'Xuyuanp/nerdtree-git-plugin'}
-- Utilities
paq {'Yggdroot/indentLine'}
paq {'tpope/vim-speeddating'}
paq {'AnthonyK213/vim-ipairs'}
paq {'dhruvasagar/vim-table-mode'}
-- File type support
paq {'lervag/vimtex'}
paq {'jceb/vim-orgmode'}
paq {'plasticboy/vim-markdown'}
paq {'sophacles/vim-processing'}
paq {'iamcco/markdown-preview.nvim', hook=vim.fn['mkdp#util#install']}
-- Completion; LSP
paq {'hrsh7th/vim-vsnip'}
paq {'hrsh7th/vim-vsnip-integ'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-lua/completion-nvim'}
paq {'tjdevries/lsp_extensions.nvim'}
paq {'nvim-treesitter/nvim-treesitter'}
paq {'nvim-treesitter/completion-treesitter'}
