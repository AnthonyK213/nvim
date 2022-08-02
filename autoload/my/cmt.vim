let s:cmt_mark_tab_single = {
      \ 'arduino'   : '//',
      \ 'c'         : '//',
      \ 'cmake'     : '#',
      \ 'cpp'       : "//",
      \ 'cs'        : "//",
      \ 'dosbatch'  : "::",
      \ 'gitconfig' : '#',
      \ 'java'      : "//",
      \ 'lisp'      : ";",
      \ 'lua'       : "--",
      \ 'make'      : "#",
      \ 'markdown'  : "> ",
      \ 'rust'      : "//",
      \ 'perl'      : '#',
      \ 'python'    : "#",
      \ 'sh'        : "#",
      \ 'sshconfig' : '#',
      \ 'tex'       : "%",
      \ 'toml'      : '#',
      \ 'vim'       : '"',
      \ 'vimwiki'   : "%% ",
      \ 'yaml'      : '#',
      \ }

let s:cmt_mark_tab_multi = {
      \ 'c'    : ["/*", "*/"],
      \ 'cpp'  : ["/*", "*/"],
      \ 'cs'   : ["/*", "*/"],
      \ 'java' : ["/*", "*/"],
      \ 'lua'  : ["--[[", "]]"],
      \ 'rust' : ["/*", "*/"],
      \ }

function! my#cmt#cmt_add_norm() abort
  if has_key(s:cmt_mark_tab_single, &ft)
    let l:cmt_mark = s:cmt_mark_tab_single[&ft]
    let l:pos = getpos('.')
    call feedkeys("I" . l:cmt_mark, 'xn')
    call setpos('.', l:pos)
  else
    call my#lib#notify_err("File type " . &ft . " is not supported yet.")
  endif
endfunction

function! my#cmt#cmt_add_vis() abort
  let l:pos_s = getpos("'<")
  let l:pos_e = getpos("'>")
  if has_key(s:cmt_mark_tab_single, &ft)
    let l:cmt_mark_single = s:cmt_mark_tab_single[&ft]
    let l:lnum_s = pos_s[1]
    let l:lnum_e = pos_e[1]
    for l:i in range(l:lnum_s, l:lnum_e, 1)
      let l:line_old = getline(l:i)
      if !(l:line_old =~ '\v^\s*$')
        let l:line_new = substitute(l:line_old, '\v^(\s*)(.*)$',
              \ '\=submatch(1).l:cmt_mark_single.submatch(2)', '')
        call setline(l:i, l:line_new)
      endif
    endfor
  else
    call my#lib#notify_err("File type " . &ft . " is not supported yet.")
  endif
endfunction

function! s:is_cmt_line(lnum) abort
  let l:line = getline(a:lnum)
  if has_key(s:cmt_mark_tab_single, &ft)
    let l:cmt_mark = s:cmt_mark_tab_single[&ft]
    let l:esc_cmt_mark = my#lib#vim_reg_esc(l:cmt_mark)
    if l:line =~ '\v^\s*' . l:esc_cmt_mark . '.*$'
      let l:res = substitute(l:line, '\v^(\s*)' . l:esc_cmt_mark . '(.*)$',
            \ '\=submatch(1).submatch(2)', '')
      return [1, l:res]
    endif
  endif
  return [0, l:line]
endfunction

function! s:del_cmt_block() abort
  let l:lnum_c = line('.')
  if !has_key(s:cmt_mark_tab_multi, &ft)
    return
  endif
  let l:cmt_mark = s:cmt_mark_tab_multi[&ft]
  let l:cmt_mark_a = l:cmt_mark[0]
  let l:cmt_mark_b = l:cmt_mark[1]
  let l:vim_cmt_mark_a = my#lib#vim_reg_esc(l:cmt_mark_a)
  let l:vim_cmt_mark_b = my#lib#vim_reg_esc(l:cmt_mark_b)
  for l:i in range(l:lnum_c - 1, 1, -1)
    let l:line_p = getline(l:i)
    if (l:line_p =~ '\v' . l:vim_cmt_mark_b . '.{-}$')
          \ && (l:line_p !~ '\v' . l:vim_cmt_mark_a . '.{-}$')
      return
    endif
    if l:line_p =~ '\v' . l:vim_cmt_mark_a . '.{-}$'
      let l:pos_a = match(l:line_p, '\v' . l:vim_cmt_mark_a . '.{-}$')
      if l:line_p =~ '\v' . l:vim_cmt_mark_b . '.{-}$'
        let l:pos_b = match(l:line_p, '\v' . l:vim_cmt_mark_b . '.{-}$')
        if l:pos_a < l:pos_b
          return
        endif
      endif
      if l:line_p =~ '\v^\s*' . l:vim_cmt_mark_a . '\s*$'
        exe l:i . 'd'
        let l:lnum_c -= 1
      else
        let l:line_p = substitute(l:line_p, l:vim_cmt_mark_a, "", 'g')
        call setline(l:i, l:line_p)
      endif
      break
    endif
  endfor
  for l:j in range(l:lnum_c + 1, line('$'), 1)
    let l:line_n = getline(l:j)
    if l:line_n =~ '\v' . l:vim_cmt_mark_b . '.*$'
      let l:pos_b = match(l:line_n, 'v' . l:vim_cmt_mark_b . '.*$')
      if l:line_n =~ '\v' . l:vim_cmt_mark_a . '.*$'
        let l:pos_a = match(l:line_n, '\v' . l:vim_cmt_mark_a . '.*$')
        if l:pos_a < l:pos_b
          return
        endif
      endif
      if l:line_n =~ '\v^\s*' . l:vim_cmt_mark_b . '\s*$'
        exe l:j . 'd'
      else
        let l:line_n = substitute(l:line_n, '\v' . l:vim_cmt_mark_b, "", 'g')
        call setline(l:j, l:line_n)
      endif
      break
    endif
  endfor
endfunction

function! my#cmt#cmt_del_norm() abort
  if !has_key(s:cmt_mark_tab_single, &ft)
    return
  endif
  let [l:cmt_line, l:line_new] = s:is_cmt_line('.')
  if l:cmt_line
    call setline('.', l:line_new)
    return
  endif
  call s:del_cmt_block()
endfunction

function! my#cmt#cmt_del_vis() abort
  let l:lnum_s = getpos("'<")[1]
  let l:lnum_e = getpos("'>")[1]
  for l:i in range(l:lnum_s, l:lnum_e, 1)
    let [l:cmt_line, l:line_new] = s:is_cmt_line(l:i)
    if l:cmt_line
      call setline(l:i, l:line_new)
    endif
  endfor
endfunction
