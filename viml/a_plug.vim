" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')
  " UI
  Plug 'kaicataldo/material.vim', {'branch': 'main'}
  Plug 'vim-airline/vim-airline'
  " Tree manager
  Plug 'preservim/nerdtree'
  " FZF
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'
  " Git utilities
  Plug 'tpope/vim-fugitive'
  Plug 'mhinz/vim-signify'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  " Utilities
  Plug 'Yggdroot/indentLine'
  Plug 'tpope/vim-speeddating'
  Plug 'AnthonyK213/vim-ipairs'
  Plug 'dhruvasagar/vim-table-mode'
  " File type support
  Plug 'lervag/vimtex'
  Plug 'plasticboy/vim-markdown'
  Plug 'sophacles/vim-processing'
  Plug 'iamcco/markdown-preview.nvim', {'do': {-> mkdp#util#install()}, 'for': ['markdown', 'vim-plug']}
  " Snippet; Completion
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
if g:default_complete ==# 'asyncomplete'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-buffer.vim'
elseif g:default_complete ==# 'coc'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
call plug#end()
