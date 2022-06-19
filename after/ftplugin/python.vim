setlocal tabstop=4 shiftwidth=4 softtabstop=4

function! s:add_summary(fallback) abort
  if my#lib#get_context()["b"] =~ '\v^\s*""$'
    return "\"\<CR>\"\"\"\<C-\>\<C-O>O"
  else
    return a:fallback()
  endif
endfunction

function! s:def_map(id) abort
  call my#util#new_keymap("i", '"', funcref("s:add_summary"), {"noremap": 1, "buffer": 1, "silent": 1})
endfunction

call my#lib#defer_fn(function("s:def_map"), 500)
