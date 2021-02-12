" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')
  " Visual
  Plug 'joshdick/onedark.vim'
  Plug 'vim-airline/vim-airline'
  " Tree manager
  Plug 'preservim/nerdtree'
  " Git utilities
  Plug 'tpope/vim-fugitive'
  Plug 'mhinz/vim-signify'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  " Utilities
  Plug 'Yggdroot/indentLine'
  Plug 'tpope/vim-speeddating'
  Plug 'AnthonyK213/vim-ipairs', {'branch': 'master'}
  Plug 'dhruvasagar/vim-table-mode'
  " File type support
  Plug 'lervag/vimtex'
  Plug 'jceb/vim-orgmode'
  Plug 'plasticboy/vim-markdown'
  Plug 'sophacles/vim-processing'
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
  " Completion; LSP
call plug#end()
