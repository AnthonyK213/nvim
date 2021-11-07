function! usr#eval#text_eval()
  let l:origin_pos = getpos('.')
  exe 'normal! F`'
  let l:back = usr#lib#get_char('b')
  let l:fore = usr#lib#get_char('f')
  let l:expr = matchlist(l:fore, '\v^`(.{-})`.*$')[1]

  try
    let l:result = eval(l:expr)
    let l:fore_new = substitute(fore, '\v^`(.{-}`)', string(l:result), '')
    call setline('.', back . fore_new)
  catch
    call setpos('.', l:origin_pos)
    echo 'No valid expression found.'
  endtry
endfunction
