require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'
    -- Display
    use {
        {'goolord/alpha-nvim',          opt = true};
        {'folke/tokyonight.nvim',       opt = true};
        {'nvim-lualine/lualine.nvim',   opt = true};
        {'akinsho/bufferline.nvim',     opt = true};
        {'norcalli/nvim-colorizer.lua', opt = true};
    }
    -- File system
    use {
        {
            'kyazdani42/nvim-tree.lua',
            config = function() require('packages.nvim-tree') end
        };
        {
            'nvim-telescope/telescope.nvim',
            config = function() require('packages.telescope') end
        };
    }
    -- VCS
    use {
        {
            'TimUntersberger/neogit',
            config = function() require('packages.neogit') end
        };
        {
            'lewis6991/gitsigns.nvim',
            config = function() require('packages.gitsigns') end
        };
    }
    -- Utilities
    use {
        'nvim-lua/plenary.nvim';
        'tpope/vim-speeddating';
        {
            'dhruvasagar/vim-table-mode',
            config = function() require('packages.vim-table-mode') end
        };
        {
            'lukas-reineke/indent-blankline.nvim',
            config = function() require('packages.indent-blankline') end
        };
        {
            'AnthonyK213/lua-pairs',
            config = function() require('packages.lua-pairs') end
        };
        {
            'andymass/vim-matchup'
        };
        {
            'Shatur/neovim-session-manager',
            config = function() require('packages.neovim-session-manager') end
        };
        {
            'stevearc/dressing.nvim',
            config = function() require('packages.dressing') end
        };
    }
    -- File type support
    use {
        {
            'lervag/vimtex',
            config = function() require('packages.vimtex') end
        };
        {
            'vimwiki/vimwiki',
            branch = 'dev',
            config = function() require('packages.vimwiki') end
        };
        {
            'iamcco/markdown-preview.nvim',
            run = function() vim.fn['mkdp#util#install'](0) end,
            config = function() require('packages.markdown-preview') end
        };
        'sotte/presenting.vim';
    }
    -- Completion; Snippet; LSP; Treesitter
    use {
        {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-omni',
                'hrsh7th/cmp-path',
                'hrsh7th/vim-vsnip',
                'hrsh7th/cmp-vsnip',
            },
            config = function() require('packages.nvim-cmp') end
        };
        {
            'neovim/nvim-lspconfig',
            config = function() require('packages.nvim-lspconfig') end
        };
        {
            'nvim-treesitter/nvim-treesitter',
            config = function() require('packages.nvim-treesitter') end
        };
        {
            'stevearc/aerial.nvim',
            config = function() require('packages.aerial') end
        };
        {
            'SmiteshP/nvim-gps',
            config = function() require('packages.nvim-gps') end
        };
    }
    -- Games
    use 'alec-gibson/nvim-tetris'
end)


-- Built-in plugins.
local core_opt = require('core.opt')
if core_opt.plug then
    if not core_opt.plug.matchit then vim.g.loaded_matchit = 1 end
    if not core_opt.plug.matchparen then vim.g.loaded_matchparen = 1 end
end
