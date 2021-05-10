vim.cmd('packadd paq-nvim')
local use = require('paq-nvim').paq

-- Package manager
use {'savq/paq-nvim', opt = true}
-- Visual
use {'Th3Whit3Wolf/one-nvim',       opt = true}
use {'hoob3rt/lualine.nvim',        opt = true}
use {'akinsho/nvim-bufferline.lua', opt = true}
use {'glepnir/indent-guides.nvim',  opt = true}
use {'norcalli/nvim-colorizer.lua', opt = true}
-- File system
--paq {'kyazdani42/nvim-tree.lua'}
use {'AnthonyK213/nvim-tree.lua'}
use {'nvim-telescope/telescope.nvim'}
-- Git utilities
use {'TimUntersberger/neogit'}
use {'lewis6991/gitsigns.nvim'}
-- Utilities
use {'nvim-lua/popup.nvim'}
use {'nvim-lua/plenary.nvim'}
use {'tpope/vim-speeddating'}
use {'dhruvasagar/vim-table-mode'}
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
