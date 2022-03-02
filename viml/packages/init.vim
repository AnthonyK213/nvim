let g:plug_use_coc = get(g:, 'default_coc', v:false)
" Load plug-ins
call plug#begin(stdpath('data') . '/plugged')

" Display
Plug 'glepnir/dashboard-nvim'
Plug 'rakr/vim-one'
Plug 'vim-airline/vim-airline'
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
if g:plug_use_coc
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
