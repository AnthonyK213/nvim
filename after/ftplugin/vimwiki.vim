setlocal textwidth=0 nowrap nolinebreak
let b:table_mode_corner = '|'
let b:presenting_slide_separator_default = '\v(^|\n)\ze#{1,2}[^#]'

function! s:vimwiki_tab(fallback) abort
  if my#syn#match_here("Weblink")
    return a:fallback()
  elseif foldlevel(".") > 0
    return "za"
  endif
endfunction

function! s:vimwiki_cr(fallback) abort
  if foldclosed(".") >= 0 || my#syn#match_here("Header")
    return "za"
  else
    return a:fallback()
  endif
endfunction

call my#compat#md_kbd()
call my#util#new_keymap("n", "<Tab>", funcref("s:vimwiki_tab"), {"buffer": 1, "silent": 1})
call my#util#set_keymap("n", "<S-Tab>", "zA", {"buffer": 1, "silent": 1})
call my#util#new_keymap("n", "<CR>", funcref("s:vimwiki_cr"), {"buffer": 1, "silent": 1})
