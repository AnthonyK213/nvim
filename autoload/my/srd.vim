"" Surround
function! s:srd_pair(pair_a) abort
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

" Collect pairs in hashtable `tab_pair`.
" If pair_a then -1, if pair_b then 1.
function! s:srd_collect(str, pair_a, pair_b) abort
  let l:tab_pair = []
  for l:i in range(strlen(a:str))
    call add(l:tab_pair, 0)
  endfor
  let l:start = 0
  let l:pat_a = '\v' . my#lib#vim_pesc(a:pair_a)
  let l:pat_b = '\v' . my#lib#vim_pesc(a:pair_b)
  while 1
    let l:match_a = match(a:str, l:pat_a, l:start)
    let l:match_b = match(a:str, l:pat_b, l:start)
    if l:match_a < 0 && l:match_b < 0
      break
    endif
    if l:match_a >= 0 && (l:match_b < 0 || l:match_a <= l:match_b)
      let l:tab_pair[l:match_a] = -1
      let l:start = l:match_a + 1
    else
      let l:tab_pair[l:match_b] = 1
      let l:start = l:match_b + 1
    endif
  endwhile
  return l:tab_pair
endfunction

" Locate surrounding pair in direction `dir`
" @param int dir -1 or 1, -1 for backward, 1 for forward.
" FIXME: If there are imbalanced pairs in string, how to get this work?
function! s:srd_locate(str, pair_a, pair_b, dir) abort
  let l:tab_pair = s:srd_collect(a:str, a:pair_a, a:pair_b)
  let l:list_pos = []
  let l:res = []
  if a:dir < 0
    call reverse(l:tab_pair)
  endif
  let l:sum = 0
  for l:i in range(len(l:tab_pair))
    let l:sum = l:sum + l:tab_pair[l:i]
    if l:sum == a:dir
      return a:dir > 0 ? l:i : len(l:tab_pair) - 1 - l:i
    endif
  endfor
  return -1
endfunction

function! my#srd#srd_add(mode, ...) abort
  let l:pair_a = a:0 ? a:1 : input("Surrounding add: ")
  let l:pair_b = s:srd_pair(l:pair_a)
  if a:mode ==# 'n'
    let [l:word, l:s, l:e] = my#lib#get_word()
    let l:line = getline('.')
    let l:l_a = l:s == 0 ? '' : l:line[0:(l:s - 1)]
    let l:line_new = l:l_a . l:pair_a . l:word . l:pair_b . l:line[(l:e):]
    call setline('.', l:line_new)
  elseif a:mode ==# 'v'
    let l:stt = [0] + getpos("'<")[1:2]
    let l:end = [0] + getpos("'>")[1:2]
    call setpos('.', l:end)
    exe "normal! a" . l:pair_b
    call setpos('.', l:stt)
    exe "normal! i" . l:pair_a
  endif
endfunction

function! my#srd#srd_sub(...) abort
  let l:back = my#lib#get_context()['b']
  let l:fore = my#lib#get_context()['f']
  let l:pair_a = input("Surrounding delete: ")
  let l:pair_b = s:srd_pair(l:pair_a)
  let l:pair_a_new = a:0 ? a:1 : input("Change to: ")
  let l:pair_b_new = s:srd_pair(l:pair_a_new)
  if l:pair_a ==# l:pair_b
    let l:pat = my#lib#vim_pesc(l:pair_a)
    if l:back =~# '\v.*\zs' . l:pat && l:fore =~# '\v' . l:pat
      let l:back_new = substitute(l:back, '\v.*\zs' . l:pat, l:pair_a_new, '')
      let l:fore_new = substitute(l:fore, '\v' . l:pat, l:pair_b_new, '')
      call setline(line('.'), l:back_new . l:fore_new)
    endif
  else
    let l:pos_a = s:srd_locate(l:back, l:pair_a, l:pair_b, -1)
    let l:pos_b = s:srd_locate(l:fore, l:pair_a, l:pair_b, 1)
    if l:pos_a >= 0 && l:pos_b >= 0
      let l:back_new = (l:pos_a > 0 ? l:back[0:(l:pos_a - 1)] : "") .
            \ l:pair_a_new .
            \ l:back[(l:pos_a + strlen(l:pair_a)):]
      let l:fore_new = (l:pos_b > 0 ? l:fore[0:(l:pos_b - 1)] : "") .
            \ l:pair_b_new .
            \ l:fore[(l:pos_b + strlen(l:pair_b)):]
      call setline(line('.'), l:back_new . l:fore_new)
    endif
  endif
endfunction
