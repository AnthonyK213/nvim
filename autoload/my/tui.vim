let s:nvim_init_src = ""
if exists('g:nvim_init_src')
  let s:nvim_init_src = g:nvim_init_src
elseif has_key(environ(), 'NVIM_INIT_SRC')
  let s:nvim_init_src = expand('$NVIM_INIT_SRC')
endif

function! my#tui#use_nano() abort
  return s:nvim_init_src ==# 'nano' || g:_my_tui_scheme ==# 'nanovim'
endfunction

function! my#tui#nano_setup() abort
  let g:_my_theme_switchable = 1
  let g:nano_transparent = g:_my_tui_transparent ? 1 : 0
  let g:_my_tui_scheme = 'nanovim'
  call my#compat#set_theme(g:_my_tui_theme)
  colorscheme nanovim
endfunction

function! my#tui#load_3rd_ui() abort
  return s:nvim_init_src != 'neatUI' && !my#tui#use_nano()
endfunction

function! my#tui#set_color_scheme(exclude) abort
  let g:_my_theme_switchable = 0
  if has("termguicolors")
    set termguicolors
  endif
  if my#tui#use_nano()
    call my#tui#nano_setup()
  elseif has_key(a:exclude, g:_my_tui_scheme)
    return
  else
    try
      exe 'colorscheme' g:_my_tui_scheme
    catch
      echomsg 'Color scheme was not found.'
    endtry
  endif
endfunction
