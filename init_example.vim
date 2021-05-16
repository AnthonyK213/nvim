"let g:default_shell = 'zsh'
"let g:default_c_compiler = 'clang'
"let g:python3_exec_path = '/usr/bin/python3'
"let g:default_complete = 'asyncomplete'


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
