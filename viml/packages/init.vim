" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')

" Display
Plug 'glepnir/dashboard-nvim'
Plug 'rakr/vim-one'
Plug 'vim-airline/vim-airline'
Plug 'chrisbra/Colorizer'
" FZF
Plug 'liuchengxu/vim-clap', { 'do': {-> clap#installer#force_download()} }
" VCS
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
" Utilities
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-speeddating'
Plug 'dhruvasagar/vim-table-mode'
Plug 'AnthonyK213/vim-ipairs'
Plug 'andymass/vim-matchup'
Plug 'skanehira/vsession'
" File type support
Plug 'lervag/vimtex'
Plug 'vimwiki/vimwiki', {'branch': 'dev'}
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim',
      \ {'do': {-> mkdp#util#install()}, 'for': ['markdown', 'vim-plug']}
Plug 'sotte/presenting.vim'
" Completion; Snippet; (LSP)
if g:_my_use_coc
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'liuchengxu/vista.vim'
else
  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-buffer.vim'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
endif

call plug#end()

if exists('g:nvim_init_src')
  let s:init_src = g:nvim_init_src
elseif has_key(environ(), 'NVIM_INIT_SRC')
  let s:init_src = expand("$NVIM_INIT_SRC")
else
  let s:init_src = ""
endif

if s:init_src ==? 'nano'
  set bg=light
  call my#compat#vim_source('viml/subsrc')
  colorscheme nanovim
else
  call my#compat#vim_source('viml/packages/config')
endif
