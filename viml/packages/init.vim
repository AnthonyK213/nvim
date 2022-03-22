let s:plug_bootstrap = 0
let s:plug_path = my#compat#stdpath('data') . '/site/autoload/plug.vim'
if empty(glob(s:plug_path)) && my#lib#executable('curl')
  let s:plug_bootstrap = 1
  let s:plug_dl_cmd = [
        \ 'curl',
        \ '-fLo', s:plug_path,
        \ '--create-dirs',
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        \ ]
  if exists("g:_my_dep_proxy")
    call extend(s:plug_dl_cmd, ['-x', g:_my_dep_proxy])
  endif
  call system(s:plug_dl_cmd)
endif

if exists('g:nvim_init_src')
  let s:nvim_init_src = g:nvim_init_src
elseif has_key(environ(), 'NVIM_INIT_SRC')
  let s:nvim_init_src = expand("$NVIM_INIT_SRC")
else
  let s:nvim_init_src = ""
endif

" Load plug-ins
call plug#begin(my#compat#stdpath('data') . '/plugged')

"" Display
if has("nvim")
  Plug 'glepnir/dashboard-nvim'
endif
if s:nvim_init_src !=? 'defaultlines'
  Plug 'vim-airline/vim-airline'
endif
Plug 'chrisbra/Colorizer'
"" Color scheme
Plug 'rakr/vim-one'
Plug 'morhetz/gruvbox'
"" File system
Plug 'liuchengxu/vim-clap', { 'do': {-> clap#installer#force_download()} }
"" VCS
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
"" Utilities
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-speeddating'
Plug 'dhruvasagar/vim-table-mode'
Plug 'AnthonyK213/vim-ipairs'
Plug 'andymass/vim-matchup'
Plug 'skanehira/vsession'
"" File type support
Plug 'lervag/vimtex'
Plug 'vimwiki/vimwiki', {'branch': 'dev'}
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim',
      \ {'do': {-> mkdp#util#install()}, 'for': ['markdown', 'vim-plug']}
Plug 'sotte/presenting.vim'
"" Completion; Snippet; (LSP)
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

if s:plug_bootstrap
  PlugInstall
endif

let s:colorscheme_list = [
      \ 'one',
      \ 'gruvbox'
      \ ]

if s:nvim_init_src ==? 'nano'
  call my#compat#vim_source('viml/subsrc')
  colorscheme nanovim
else
  call my#compat#vim_source_list([
    \ "packages/dashboard",
    \ "packages/indentLine",
    \ "packages/markdown-preview",
    \ "packages/vim-clap",
    \ "packages/vim-ipairs",
    \ "packages/vim-markdown",
    \ "packages/vim-signify",
    \ "packages/vim-table-mode",
    \ "packages/vimtex",
    \ "packages/vimwiki",
    \ "packages/vsession"
    \ ])
  if s:nvim_init_src !=? 'defaultlines'
    call my#compat#vim_source('viml/packages/vim-airline')
  endif
  if g:_my_use_coc
    call my#compat#vim_source_list([
      \ "packages/coc",
      \ "packages/vista"
      \ ])
  else
    call my#compat#vim_source_list([
      \ "packages/asyncomplete",
      \ "packages/nerdtree"
      \ ])
  endif
  if index(s:colorscheme_list, g:_my_tui_scheme) >= 0
    call my#compat#vim_source('viml/packages/' . g:_my_tui_scheme)
  else
    try
      exe 'colorscheme' g:_my_tui_scheme
    catch
      echomsg 'Color scheme was not found.'
    endtry
  endif
endif
