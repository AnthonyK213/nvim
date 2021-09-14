" Leader key
let g:mapleader = "\<Space>"
" Directories
let g:path_home = get(g:, 'default_home', expand('$HOME'))
let g:path_cloud = get(g:, 'default_cloud', expand('$ONEDRIVE'))
let g:path_desktop = get(g:, 'default_desktop', expand(g:path_home . '/Desktop'))
" OS
if has("win32")
  let g:python3_host_prog = get(g:, 'default_python3', $HOME . '/Appdata/Local/Programs/Python/Python38/python.EXE')
  set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
  set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
  set wildignore+=*.pyc
  set wildignore+=*.DS_Store
  set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz
elseif has("unix")
  let g:python3_host_prog = get(g:, 'default_python3', '/usr/bin/python3')
  set wildignore+=*.so
endif
" Directional operation which won't mess up the history.
let g:const_dir_l = "\<C-g>U\<Left>"
let g:const_dir_d = "\<C-g>U\<Down>"
let g:const_dir_u = "\<C-g>U\<Up>"
let g:const_dir_r = "\<C-g>U\<Right>"
