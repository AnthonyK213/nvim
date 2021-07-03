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
        {
            'kyazdani42/nvim-tree.lua',
            config = function() require('package/nvim-tree') end
        };
        {
            'nvim-telescope/telescope.nvim',
            requires = {'nvim-lua/popup.nvim'},
            config = function() require('package/telescope') end
        };
    }
    -- VCS utilities
    use {
        'tpope/vim-fugitive';
        {
            'lewis6991/gitsigns.nvim',
            config = function() require('package/gitsigns') end
        };
    }
    -- Utilities
    use {
        'nvim-lua/plenary.nvim';
        'tpope/vim-speeddating';
        {
            'dhruvasagar/vim-table-mode',
            config = function() require('package/vim-table-mode') end
        };
        {
            'lukas-reineke/indent-blankline.nvim',
            config = function() require('package/indent-blankline') end
        };
    }
    -- File type support
    use {
        {
            'lervag/vimtex',
            config = function() require('package/vimtex') end
        };
        {
            'vimwiki/vimwiki',
            config = function() require('package/vimwiki') end
        };
        {
            'plasticboy/vim-markdown',
            config = function() require('package/vim-markdown') end
        };
        'sophacles/vim-processing';
        {
            'iamcco/markdown-preview.nvim',
            run = function() vim.fn['mkdp#util#install'](0) end,
            config = function() require('package/markdown-preview') end
        };
    }
    -- Snippet; Completion; LSP; Treesitter
    use {
        {
            'hrsh7th/nvim-compe',
            requires = {'hrsh7th/vim-vsnip'};
            config = function() require('package/nvim-compe') end
        };
        {
            'neovim/nvim-lspconfig',
            config = function() require('package/nvim-lspconfig') end
        };
        {
            'nvim-treesitter/nvim-treesitter',
            config = function() require('package/nvim-treesitter') end
        };
    }
    -- Games
    use 'alec-gibson/nvim-tetris'
end)
