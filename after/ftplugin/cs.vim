setlocal tabstop=4 shiftwidth=4 softtabstop=4

function s:add_summary() abort
  if my#lib#get_char('b') =~ '\v^\s*//$'
    call feedkeys("/ <summary>\n\n</summary>\<Up> ", "n")
  else
    call feedkeys("/", "n")
  endif
endfunction

inoremap <buffer><silent> / <C-\><C-O>:call <SID>add_summary()<CR>
