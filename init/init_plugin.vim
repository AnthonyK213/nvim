""" Load plugins
call plug#begin(stdpath('data').'/plugged')
    Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'preservim/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'tpope/vim-fugitive'
    Plug 'mhinz/vim-signify'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
    Plug 'dhruvasagar/vim-table-mode'
    Plug 'tpope/vim-speeddating'
    Plug 'jceb/vim-orgmode'
    Plug 'lervag/vimtex'
    Plug 'sophacles/vim-processing'
    Plug 'Yggdroot/indentLine'
call plug#end()
