let s:Syntax = {}

function! s:get_vs(row, col) abort
  let l:vs = []
  for l:id in synstack(a:row, a:col)
    let l:name = synIDattr(l:id, "name")
    let l:link_id = synIDtrans(l:id)
    let l:link_name = synIDattr(l:link_id, "name")
    call add(l:vs, {
        \ 'id': l:id,
        \ 'name': l:name,
        \ 'link_id': l:link_id,
        \ 'link_name': link_name
        \ })
  endfor
  return l:vs
endfunction

function! s:Syntax.match(pattern) dict
  for l:obj in self.vs
    if obj["name"] =~ a:pattern
      return 1
    endif
  endfor
  return 0
endfunction

function! s:Syntax.show() dict
  let l:lines = []
  if !empty(self.vs)
    call add(l:lines, "# Vim_Syntax")
    for l:obj in self.vs
      call add(l:lines, "* " . l:obj["name"] . " -> **" . l:obj["link_name"] . "**")
    endfor
  endif
  if empty(l:lines)
    call add(l:lines, "* No highlight groups found.")
  endif
  echo join(l:lines, "\n")
endfunction

function! my#syn#new(row, col) abort
  let l:vs = []
  if exists("b:current_syntax")
    let l:vs = s:get_vs(a:row, a:col)
  endif
  let l:o = { 'vs': l:vs }
  call extend(l:o, s:Syntax)
  return l:o
endfunction

function! my#syn#match_here(pattern) abort
  return my#syn#new(line("."), col(".")).match(a:pattern)
endfunction
