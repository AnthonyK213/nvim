setlocal tabstop=4 shiftwidth=4 softtabstop=4

"function! s:add_summary() abort
  "if my#lib#get_context()["b"] =~ '\v^\s*""$'
    "call feedkeys("\"\<CR>\"\"\"\<C-\>\<C-O>O", "ni")
  "else
    "call feedkeys('"', "ni")
  "endif
"endfunction

"function! s:def_map(id) abort
  "call my#util#set_keymap("i", '"', funcref("s:add_summary"), {"noremap": 1, "buffer": 1, "silent": 0})
"endfunction

"call my#lib#defer_fn(function("s:def_map"), 500)
