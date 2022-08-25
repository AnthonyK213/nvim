let s:plug_bootstrap = 0
let s:plug_config_list = []
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

function! s:plug(repo, config = v:null, option = {})
  if !empty(a:option)
    call plug#(a:repo, a:option)
  else
    call plug#(a:repo)
  endif
  if type(a:config) == v:t_func
    call add(s:plug_config_list, a:config)
  endif
endfunction

" Load plug-ins
call plug#begin(my#compat#stdpath('data') . '/plugged')
call s:plug('rakr/vim-one')
call s:plug('morhetz/gruvbox')
call s:plug('liuchengxu/vim-clap', function("my#config#vim_clap"), { 'do': {-> clap#installer#force_download()} })
call s:plug('tpope/vim-fugitive', function("my#config#vim_fugitive"))
call s:plug('mhinz/vim-signify', function("my#config#vim_signify"))
call s:plug('tpope/vim-speeddating')
call s:plug('AnthonyK213/vim-ipairs', function("my#config#vim_ipairs"))
call s:plug('andymass/vim-matchup')
call s:plug('voldikss/vim-floaterm', function("my#config#vim_floatterm"))
call s:plug('dhruvasagar/vim-table-mode', function("my#config#vim_table_mode"))
call s:plug('lervag/vimtex', function("my#config#vimtex"))
call s:plug('vimwiki/vimwiki', function("my#config#vimwiki"), {'branch': 'dev'})
call s:plug('iamcco/markdown-preview.nvim', function("my#config#markdown_preview"), {'do': {-> mkdp#util#install()}})
call s:plug('sotte/presenting.vim')
call s:plug('editorconfig/editorconfig-vim')
call s:plug('AndrewRadev/gnugo.vim')
call s:plug('skanehira/vsession', function("my#config#vsession"))

if has("termguicolors")
  set termguicolors
endif
let s:colorscheme_table = {
      \ 'one': 'one',
      \ 'onedark': 'one',
      \ 'gruvbox': 'gruvbox'
      \ }
let g:_my_theme_switchable = 0
let &bg = g:_my_tui_theme
if s:nvim_init_src ==? 'nano'
  let g:_my_theme_switchable = 1
  colorscheme nanovim
else
  if has_key(s:colorscheme_table, g:_my_tui_scheme)
    call add(s:plug_config_list, function("my#config#" . s:colorscheme_table[g:_my_tui_scheme]))
  else
    try
      exe 'colorscheme' g:_my_tui_scheme
    catch
      echomsg 'Color scheme was not found.'
    endtry
  endif
  if s:nvim_init_src !=? "neatUI"
    call s:plug('mhinz/vim-startify', function("my#config#vim_startify"))
    call s:plug('vim-airline/vim-airline', function("my#config#vim_airline"))
    call s:plug('chrisbra/Colorizer')
    call s:plug('Yggdroot/indentLine', function("my#config#indentLine"))
  endif
endif

if g:_my_use_coc
  call s:plug('neoclide/coc.nvim', function("my#config#coc"), {'branch': 'release'})
else
  call s:plug('prabirshrestha/asyncomplete.vim', function("my#config#asyncomplete"))
  call s:plug('prabirshrestha/asyncomplete-buffer.vim')
  call s:plug('hrsh7th/vim-vsnip')
  call s:plug('hrsh7th/vim-vsnip-integ')
  call s:plug('preservim/nerdtree', function("my#config#nerdtree"))
  call s:plug('Xuyuanp/nerdtree-git-plugin')
endif

call s:plug('liuchengxu/vista.vim', function("my#config#vista"))
call plug#end()

if s:plug_bootstrap
  PlugInstall
else
  for s:conf in s:plug_config_list
    call s:conf()
  endfor
endif
