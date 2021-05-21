let g:plug_def_comp = get(g:, 'default_complete', '')
" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')
  " UI
  Plug 'ghifarit53/tokyonight-vim'
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
  Plug 'vimwiki/vimwiki'
  Plug 'plasticboy/vim-markdown'
  Plug 'sophacles/vim-processing'
  Plug 'iamcco/markdown-preview.nvim', {'do': {-> mkdp#util#install()}, 'for': ['markdown', 'vim-plug']}
  " Snippet; Completion
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
if g:plug_def_comp ==# 'asyncomplete'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-buffer.vim'
elseif g:plug_def_comp ==# 'coc'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
call plug#end()
