setlocal tabstop=4 shiftwidth=4 softtabstop=4

function! s:add_summary() abort
  if my#lib#get_context()["b"] =~ '\v^\s*//$'
    call feedkeys("/ <summary>\n\n</summary>\<Up> ", "n")
  else
    call feedkeys("/", "n")
  endif
endfunction

function! s:def_map(id) abort
  inoremap <buffer><silent> / <C-\><C-O>:call <SID>add_summary()<CR>
endfunction

call my#lib#defer_fn(function("s:def_map"), 500)
