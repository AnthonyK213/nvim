local packer_bootstrap = nil
local packer_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    if vim.fn.executable('git') > 0 then
        packer_bootstrap = vim.fn.system {
            'git',
            'clone',
            '--depth', '1',
            'https://github.com/wbthomason/packer.nvim',
            packer_path
        }
        vim.cmd[[packadd packer.nvim]]
    else
        vim.notify('Executable git is not found.', vim.log.levels.WARN, nil)
        return
    end
end

require('packer').startup(function (use)
    -- Package manager
    use 'wbthomason/packer.nvim'
    -- Display
    use {
        {'goolord/alpha-nvim',          opt = true};
        {'nvim-lualine/lualine.nvim',   opt = true};
        {'akinsho/bufferline.nvim',     opt = true};
        {'norcalli/nvim-colorizer.lua', opt = true};
    }
    -- Color scheme
    use {
        {'navarasu/onedark.nvim',    opt = true};
        {'folke/tokyonight.nvim',    opt = true};
        {'ellisonleao/gruvbox.nvim', opt = true};
    }
    -- File system
    use {
        {
            'kyazdani42/nvim-tree.lua',
            config = function () require('packages.nvim-tree') end
        };
        {
            'nvim-telescope/telescope.nvim',
            config = function () require('packages.telescope') end
        };
    }
    -- VCS
    use {
        {
            'TimUntersberger/neogit',
            config = function () require('packages.neogit') end
        };
        {
            'lewis6991/gitsigns.nvim',
            config = function () require('packages.gitsigns') end
        };
    }
    -- Utilities
    use {
        'nvim-lua/plenary.nvim';
        'tpope/vim-speeddating';
        {
            'dhruvasagar/vim-table-mode',
            config = function () require('packages.vim-table-mode') end
        };
        {
            'lukas-reineke/indent-blankline.nvim',
            config = function () require('packages.indent-blankline') end
        };
        {
            'AnthonyK213/lua-pairs',
            config = function () require('packages.lua-pairs') end
        };
        {
            'andymass/vim-matchup'
        };
        {
            'Shatur/neovim-session-manager',
            config = function () require('packages.neovim-session-manager') end
        };
        {
            'stevearc/dressing.nvim',
            config = function () require('packages.dressing') end
        };
    }
    -- File type support
    use {
        {
            'lervag/vimtex',
            config = function () require('packages.vimtex') end
        };
        {
            'vimwiki/vimwiki',
            branch = 'dev',
            config = function () require('packages.vimwiki') end
        };
        {
            'iamcco/markdown-preview.nvim',
            run = function () vim.fn['mkdp#util#install'](0) end,
            config = function () require('packages.markdown-preview') end
        };
        'sotte/presenting.vim';
        'gpanders/editorconfig.nvim';
    }
    -- Completion; Snippet; LSP; Treesitter
    use {
        {
            'hrsh7th/nvim-cmp',
            requires = {
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-omni',
                'hrsh7th/cmp-path',
                'hrsh7th/vim-vsnip',
                'hrsh7th/cmp-vsnip',
            },
            config = function () require('packages.nvim-cmp') end
        };
        {
            'neovim/nvim-lspconfig',
            config = function () require('packages.nvim-lspconfig') end,
            requires = 'williamboman/nvim-lsp-installer'
        };
        {
            'nvim-treesitter/nvim-treesitter',
            config = function () require('packages.nvim-treesitter') end
        };
        {
            'stevearc/aerial.nvim',
            config = function () require('packages.aerial') end
        };
    }
    -- Games
    use 'alec-gibson/nvim-tetris'

    if packer_bootstrap then
        require('packer').sync()
    end
end)


-- Built-in plugins.
if _my_core_opt.plug then
    if not _my_core_opt.plug.matchit then vim.g.loaded_matchit = 1 end
    if not _my_core_opt.plug.matchparen then vim.g.loaded_matchparen = 1 end
end

-- Optional packages.
local colorscheme_list = { 'onedark', 'tokyonight', 'gruvbox' }
local colorscheme = _my_core_opt.tui.scheme
vim.o.tgc = true
vim.o.bg = _my_core_opt.tui.theme or 'dark'
local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC
if nvim_init_src == 'nano' then
    vim.cmd('colorscheme nanovim')
elseif packer_bootstrap == nil then
    require('packages.alpha-nvim')
    require('packages.nvim-colorizer')
    -- Load color scheme.
    if vim.tbl_contains(colorscheme_list, colorscheme) then
        require('packages.'..colorscheme)
    else
        if not pcall(vim.cmd, 'colorscheme '..colorscheme) then
            vim.notify('Color scheme was not found.', vim.log.levels.WARN, nil)
        end
    end
    if nvim_init_src ~= 'defaultlines' then
        require('packages.bufferline')
        require('packages.lualine')
    end
end
