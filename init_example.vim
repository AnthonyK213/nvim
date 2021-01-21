" let g:default_shell = 'zsh'
" let g:default_c_compiler = 'clang'
" let g:python3_exec_path = '/usr/bin/python3'


if !exists('g:init_src')
  let g:init_src = 'full'
endif

if g:init_src ==? 'clean'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
elseif g:init_src ==? 'nano'
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_subsrc.vim
  set background=dark
  colorscheme nanovim
elseif g:init_src == 'full'
  source <sfile>:h/init/init_a_plug.vim
  source <sfile>:h/init/init_basics.vim
  source <sfile>:h/init/init_custom.vim
  source <sfile>:h/init/init_deflib.vim
  source <sfile>:h/init/init_fnutil.vim
  source <sfile>:h/init/init_plugrc.vim
endif
