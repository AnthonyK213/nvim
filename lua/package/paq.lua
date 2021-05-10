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
--paq {'kyazdani42/nvim-tree.lua'}
paq {'AnthonyK213/nvim-tree.lua'}
paq {'nvim-telescope/telescope.nvim'}
-- Git utilities
paq {'TimUntersberger/neogit'}
paq {'lewis6991/gitsigns.nvim'}
-- Utilities
paq {'nvim-lua/popup.nvim'}
paq {'nvim-lua/plenary.nvim'}
paq {'tpope/vim-speeddating'}
paq {'dhruvasagar/vim-table-mode'}
-- File type support
paq {'lervag/vimtex'}
paq {'vimwiki/vimwiki'}
paq {'plasticboy/vim-markdown'}
paq {'sophacles/vim-processing'}
paq {'iamcco/markdown-preview.nvim', run=vim.fn['mkdp#util#install']}
-- Snippet; Completion; LSP; Treesitter
paq {'hrsh7th/vim-vsnip'}
paq {'hrsh7th/vim-vsnip-integ'}
paq {'hrsh7th/nvim-compe'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-treesitter/nvim-treesitter'}
