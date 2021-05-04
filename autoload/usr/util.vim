"" Mouse toggle
function! usr#util#mouse_toggle()
  if &mouse == 'a'
    set mouse=
    echom "Mouse disabled"
  else
    set mouse=a
    echom "Mouse enabled"
  endif
endfunction

"" Background toggle
function! usr#util#bg_toggle()
  let &background = &background == 'dark' ? 'light' : 'dark'
endfunction

"" Hanzi count.
function! usr#util#hanzi_count(mode)
  if a:mode ==# 'n'
    let l:content = getline(1, '$')
  elseif a:mode ==# 'v'
    let l:content = split(usr#lib#get_visual_selection(), "\n")
  else
    return
  endif

  let l:h_count = 0
  for line in l:content
    for char in split(line, '.\zs')
      if usr#lib#is_hanzi(char) | let l:h_count += 1 | endif
    endfor
  endfor

  return l:h_count
endfunction
