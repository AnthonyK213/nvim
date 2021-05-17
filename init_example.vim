"let g:default_shell = 'zsh'
"let g:default_c_compiler = 'clang'
"let g:default_python3 = '/usr/bin/python3'
"let g:default_home = v:null
"let g:default_cloud = v:null
"let g:default_desktop = v:null
"let g:default_complete = 'asyncomplete'
"let g:gui_font_half = 'Monospace'
"let g:gui_font_full = 'Monospace'
"let g:gui_font_size = 12

let g:coc_global_extensions = [
      \ 'coc-python',
      \ 'coc-rls',
      \ 'coc-vimlsp',
      \ 'coc-vimtex',
      \ ]


if !exists('g:init_src')
  let g:init_src = 'full'
endif

if g:init_src ==? 'clean'
  source <sfile>:h/viml/basics.vim
  source <sfile>:h/viml/custom.vim
elseif g:init_src ==? 'nano'
  source <sfile>:h/viml/basics.vim
  source <sfile>:h/viml/custom.vim
  source <sfile>:h/viml/fnutil.vim
  source <sfile>:h/viml/subsrc.vim
  set termguicolors
  set background=dark
  colorscheme nanovim
elseif g:init_src == 'full'
  source <sfile>:h/viml/a_plug.vim
  source <sfile>:h/viml/basics.vim
  source <sfile>:h/viml/custom.vim
  source <sfile>:h/viml/fnutil.vim
  source <sfile>:h/viml/plugrc.vim
  source <sfile>:h/viml/ps_opt.vim
endif
