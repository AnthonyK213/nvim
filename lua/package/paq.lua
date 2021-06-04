vim.cmd('packadd paq-nvim')
local use = require('paq-nvim').paq

-- Package manager
use {'savq/paq-nvim'}
-- Visual
use {'folke/tokyonight.nvim',       opt = true}
use {'hoob3rt/lualine.nvim',        opt = true}
use {'akinsho/nvim-bufferline.lua', opt = true}
use {'norcalli/nvim-colorizer.lua', opt = true}
-- File system
use {'kyazdani42/nvim-tree.lua'}
use {'nvim-telescope/telescope.nvim'}
-- VCS utilities
use {'tpope/vim-fugitive'}
use {'lewis6991/gitsigns.nvim'}
-- Utilities
use {'nvim-lua/popup.nvim'}
use {'nvim-lua/plenary.nvim'}
use {'tpope/vim-speeddating'}
use {'dhruvasagar/vim-table-mode'}
use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}
-- File type support
use {'lervag/vimtex'}
use {'vimwiki/vimwiki'}
use {'plasticboy/vim-markdown'}
use {'sophacles/vim-processing'}
use {'iamcco/markdown-preview.nvim', run = vim.fn['mkdp#util#install']}
-- Snippet; Completion; LSP; Treesitter
use {'hrsh7th/vim-vsnip'}
use {'hrsh7th/nvim-compe'}
use {'neovim/nvim-lspconfig'}
use {'nvim-treesitter/nvim-treesitter'}
-- Games
use {'alec-gibson/nvim-tetris'}
