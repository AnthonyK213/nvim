vim.cmd('packadd paq-nvim')
local paq = require('paq-nvim').paq


paq {'savq/paq-nvim', opt=true}
-- Visual
paq {'Th3Whit3Wolf/one-nvim', opt=true}
paq {'hoob3rt/lualine.nvim', opt=true}
paq {'akinsho/nvim-bufferline.lua', opt=true}
paq {'glepnir/indent-guides.nvim', opt=true}
paq {'norcalli/nvim-colorizer.lua', opt=true}
-- File system
paq {'kyazdani42/nvim-tree.lua'}
paq {'junegunn/fzf', run=vim.fn['fzf#install']}
paq {'junegunn/fzf.vim'}
-- Git utilities
paq {'mhinz/vim-signify'}
paq {'tpope/vim-fugitive'}
-- Utilities
paq {'tpope/vim-speeddating'}
paq {'dhruvasagar/vim-table-mode'}
-- File type support
paq {'lervag/vimtex'}
paq {'vimwiki/vimwiki'}
paq {'plasticboy/vim-markdown'}
paq {'sophacles/vim-processing'}
paq {'iamcco/markdown-preview.nvim', run=vim.fn['mkdp#util#install']}
-- Completion; LSP
paq {'hrsh7th/vim-vsnip'}
paq {'hrsh7th/vim-vsnip-integ'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-lua/completion-nvim'}
paq {'tjdevries/lsp_extensions.nvim'}
paq {'nvim-treesitter/nvim-treesitter'}
paq {'nvim-treesitter/completion-treesitter'}
