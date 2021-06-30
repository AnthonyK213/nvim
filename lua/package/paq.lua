vim.cmd('packadd paq-nvim')
require('paq-nvim') {
    -- Package manager
    'savq/paq-nvim';
    -- Visual
    {'folke/tokyonight.nvim',       opt = true};
    {'hoob3rt/lualine.nvim',        opt = true};
    {'akinsho/nvim-bufferline.lua', opt = true};
    {'norcalli/nvim-colorizer.lua', opt = true};
    -- File system
    'kyazdani42/nvim-tree.lua';
    'nvim-telescope/telescope.nvim';
    -- VCS utilities
    'tpope/vim-fugitive';
    'lewis6991/gitsigns.nvim';
    -- Utilities
    'nvim-lua/popup.nvim';
    'nvim-lua/plenary.nvim';
    'tpope/vim-speeddating';
    'dhruvasagar/vim-table-mode';
    {'lukas-reineke/indent-blankline.nvim', branch = 'lua'};
    -- File type support
    'lervag/vimtex';
    'vimwiki/vimwiki';
    'plasticboy/vim-markdown';
    'sophacles/vim-processing';
    {'iamcco/markdown-preview.nvim', run = vim.fn['mkdp#util#install']};
    -- Snippet; Completion; LSP; Treesitter
    'hrsh7th/vim-vsnip';
    'hrsh7th/nvim-compe';
    'neovim/nvim-lspconfig';
    'nvim-treesitter/nvim-treesitter';
    -- Games
    'alec-gibson/nvim-tetris';
}
