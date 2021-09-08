"let g:default_shell = 'zsh'
"let g:default_c_compiler = 'clang'
"let g:default_python3 = '/usr/bin/python3'

"let g:default_home = v:null
"let g:default_cloud = v:null
"let g:default_desktop = v:null

"let g:gui_background = 'light'
"let g:gui_font_half = 'Monospace'
"let g:gui_font_full = 'Monospace'
"let g:gui_font_size = 12

"let g:default_complete = 'asyncomplete'

let g:coc_global_extensions = [
      \ 'coc-jedi',
      \ 'coc-rls',
      \ 'coc-vimlsp',
      \ 'coc-vimtex',
      \ 'coc-snippets',
      \ ]


if !exists('g:init_src')
  let g:init_src = 'full'
endif

if g:init_src ==? 'nano'
  call usr#misc#vim_source_list([
        \ 'basics', 'custom',
        \ 'fnutil', 'subsrc'
        \ ])
  set tgc bg=dark
  colorscheme nanovim
elseif g:init_src == 'full'
  call usr#misc#vim_source_list([
        \ 'a_plug', 'basics', 'custom',
        \ 'fnutil', 'plugrc', 'ps_opt'
        \ ])
endif
