call usr#misc#vim_source('viml/core/opt')

if exists('g:nvim_init_src')
  let s:init_src = g:nvim_init_src
elseif has_key(environ(), 'NVIM_INIT_SRC')
  let s:init_src = expand("$NVIM_INIT_SRC")
else
  let s:init_src = ""
endif

if s:init_src ==? 'nano'
  set bg=light
  call usr#misc#vim_source_list([
        \ 'basics',
        \ 'internal/var',
        \ 'internal/map',
        \ 'internal/cmd',
        \ 'subsrc'
        \ ])
  colorscheme nanovim
else
  call usr#misc#vim_source_list([
        \ 'packages/init',
        \ 'basics',
        \ 'internal/var',
        \ 'internal/map',
        \ 'internal/cmd',
        \ 'packages/config'
        \ ])
endif
