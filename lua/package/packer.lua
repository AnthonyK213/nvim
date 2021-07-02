require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'
    -- Visual
    use {
        {'folke/tokyonight.nvim',       opt = true};
        {'hoob3rt/lualine.nvim',        opt = true};
        {'akinsho/nvim-bufferline.lua', opt = true};
        {'norcalli/nvim-colorizer.lua', opt = true};
    }
    -- File system
    use {
        'kyazdani42/nvim-tree.lua';
        {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/popup.nvim'}};
    }
    -- VCS utilities
    use {
        'tpope/vim-fugitive';
        'lewis6991/gitsigns.nvim';
    }
    -- Utilities
    use {
        'nvim-lua/plenary.nvim';
        'tpope/vim-speeddating';
        'dhruvasagar/vim-table-mode';
        {'lukas-reineke/indent-blankline.nvim', branch = 'lua'};
    }
    -- File type support
    use {
        'lervag/vimtex';
        'vimwiki/vimwiki';
        'plasticboy/vim-markdown';
        'sophacles/vim-processing';
        {
            'iamcco/markdown-preview.nvim',
            run = function() vim.fn['mkdp#util#install'](0) end
        };
    }
    -- Snippet; Completion; LSP; Treesitter
    use {
        'hrsh7th/vim-vsnip',
        'hrsh7th/nvim-compe',
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
    }
    -- Games
    use 'alec-gibson/nvim-tetris'
end)
