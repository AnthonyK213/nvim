" Source vim files.
function! usr#misc#vsource(file_list)
  if has("win32")
    let l:init_viml_path = expand("$localappdata/nvim/")
  elseif has("unix")
    let l:init_viml_path = expand('~/.config/nvim/')
  endif
  for l:file in a:file_list
    exe 'source' l:init_viml_path . 'viml/' . l:file . '.vim'
  endfor
endfunction

" Source vim file.
function! usr#misc#vim_source(file) abort
  if has("win32")
    let l:init_viml_path = expand("$localappdata/nvim/")
  elseif has("unix")
    let l:init_viml_path = expand('~/.config/nvim/')
  endif
  exe 'source' l:init_viml_path .  a:file . '.vim'
endfunction

" Background toggle.
function! usr#misc#bg_toggle()
  let &bg = &bg ==# 'dark' ? 'light' : 'dark'
endfunction

" Mouse toggle.
function! usr#misc#mouse_toggle()
  if &mouse ==# 'a'
    let &mouse = ''
    echom "Mouse disabled"
  else
    let &mouse = 'a'
    echom "Mouse enabled"
  endif
endfunction

" Run code complete option list.
function! usr#misc#run_code_option(arglead, cmdline, cursorpos) abort
  let l:option_table = {
        \ 'c'    : "build\ncheck",
        \ 'cs'   : "exe\nwinexe\nlibrary\nmodule",
        \ 'rust' : "build\nclean\ncheck\nrustc",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return l:option_table[&filetype]
  else
    return ''
  endif
endfunction

"" Set background according to time.
function! s:background_checker(bg_timer)
  let l:hour = str2nr(strftime('%H'))
  let l:bg = l:hour >= 6 && l:hour < 18 ? 'light' : 'dark'
  if &bg != l:bg | let &bg = l:bg | endif
endfunction

function! usr#misc#time_background()
  let bg_timer = timer_start(
        \ 60000,
        \ function('<SID>background_checker'),
        \ { 'repeat': -1 })
  call s:background_checker(bg_timer)
endfunction

" vim-markdown toggle math display.
function! usr#misc#vim_markdown_math_toggle()
  let g:vim_markdown_math = 1 - g:vim_markdown_math
  syntax off | syntax on
endfunction

" Show table of contents.
function! usr#misc#show_toc()
  if &ft ==? 'markdown'
    if exists(':Tocv')
      Tocv
      vertical resize 50
    endif
  elseif &ft ==? 'tex'
    if exists(':VimtexTocToggle')
      VimtexTocToggle
    endif
  else
    echo 'No Toc support for current filetype.'
  endif
endfunction
