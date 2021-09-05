"" Surround
function! s:sur_pair(pair_a)
  let l:pairs = {
        \ "(": ")", "[": "]", "{": "}",
        \ "<": ">", " ": " ",
        \ "《": "》", "“": "”"
        \ }
  if a:pair_a =~ '\v^(\(|\[|\{|\<|\s|《|“)+$'
    return join(reverse(map(split(a:pair_a, '.\zs'),
          \ {idx, val -> l:pairs[val]})), '')
  elseif a:pair_a =~ '\v^(\<\w+\>)+$'
    return '</' . join(reverse(split(a:pair_a, '<')), '</')
  else
    return a:pair_a
  endif
endfunction

function! usr#srd#sur_add(mode, ...)
  let l:pair_a = a:0 ? a:1 : input("Surrounding add: ")
  let l:pair_b = s:sur_pair(l:pair_a)

  if a:mode ==# 'n'
    let l:org = getpos('.')
    if usr#lib#get_char('f') =~ '\v^.\s' ||
     \ usr#lib#get_char('f') =~ '\v^.$'
      exe "normal! a" . l:pair_b
    else
      exe "normal! Ea" . l:pair_b
    endif
    call setpos('.', l:org)
    if usr#lib#get_char('p') =~ '\v\s' ||
     \ usr#lib#get_char('b') =~ '\v^$'
      exe "normal! i" . l:pair_a
    else
      exe "normal! Bi" . l:pair_a
    endif
  elseif a:mode ==# 'v'
    let l:stt = [0] + getpos("'<")[1:2]
    let l:end = [0] + getpos("'>")[1:2]
    call setpos('.', l:end)
    exe "normal! a" . l:pair_b
    call setpos('.', l:stt)
    exe "normal! i" . l:pair_a
  endif
endfunction

function! usr#srd#sur_sub(...)
  let l:back = usr#lib#get_char('b')
  let l:fore = usr#lib#get_char('f')
  let l:pair_a = input("Surrounding delete: ")
  let l:pair_b = s:sur_pair(l:pair_a)
  let l:pair_a_new = a:0 ? a:1 : input("Change to: ")
  let l:pair_b_new = s:sur_pair(l:pair_a_new)

  let l:search_back = '\v.*\zs' . escape(l:pair_a, ' ()[]{}<>.+*')
  let l:search_fore = '\v' . escape(l:pair_b, ' ()[]{}<>.+*')

  if l:back =~ l:search_back && l:fore =~ l:search_fore
    let l:back_new = substitute(l:back, l:search_back, l:pair_a_new, '')
    let l:fore_new = substitute(l:fore, l:search_fore, l:pair_b_new, '')
    let l:line_new = l:back_new . l:fore_new
    call setline(line('.'), l:line_new)
  endif
endfunction
