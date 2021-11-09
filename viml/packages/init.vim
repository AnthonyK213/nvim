let g:plug_def_comp = get(g:, 'default_complete', '')
" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')
  " UI
  Plug 'morhetz/gruvbox'
  Plug 'vim-airline/vim-airline'
  " Tree manager
  Plug 'preservim/nerdtree'
  " FZF
  Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
  Plug 'junegunn/fzf.vim'
  " VCS utilities
  Plug 'tpope/vim-fugitive'
  Plug 'mhinz/vim-signify'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  " Utilities
  Plug 'Yggdroot/indentLine'
  Plug 'tpope/vim-speeddating'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'AnthonyK213/vim-ipairs'
  " File type support
  Plug 'lervag/vimtex'
  Plug 'vimwiki/vimwiki', {'branch': 'dev'}
  Plug 'plasticboy/vim-markdown'
  Plug 'sophacles/vim-processing'
  Plug 'iamcco/markdown-preview.nvim',
        \ {'do': {-> mkdp#util#install()}, 'for': ['markdown', 'vim-plug']}
  " Snippet; Completion
if g:plug_def_comp ==# 'asyncomplete'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-buffer.vim'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
elseif g:plug_def_comp ==# 'coc'
  call usr#lsp#setup()
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'liuchengxu/vista.vim'
endif
call plug#end()
