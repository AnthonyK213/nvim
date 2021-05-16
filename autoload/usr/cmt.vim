let s:cmt_mark_tab_single = {
      \ 'c'         : '//',
      \ 'cpp'       : "//",
      \ 'cs'        : "//",
      \ 'java'      : "//",
      \ 'lua'       : "--",
      \ 'rust'      : "//",
      \ 'lisp'      : ";",
      \ 'perl'      : '#',
      \ 'python'    : "#",
      \ 'sh'        : "#",
      \ 'tex'       : "%",
      \ 'vim'       : '"',
      \ 'vimwiki'   : "%% ",
      \ 'sshconfig' : '#'
      \ }


let s:cmt_mark_tab_multi = {
      \ 'c'    : ["/*", "*/"],
      \ 'cpp'  : ["/*", "*/"],
      \ 'cs'   : ["/*", "*/"],
      \ 'java' : ["/*", "*/"],
      \ 'lua'  : ["--[[", "]]"],
      \ 'rust' : ["/*", "*/"],
      \ }

function! usr#cmt#cmt_add_norm() abort
  if has_key(s:cmt_mark_tab_single, &ft)
    let l:cmt_mark = s:cmt_mark_tab_single[&ft]
    let l:pos = getpos('.')
    call feedkeys("I" . l:cmt_mark, 'xn')
    call setpos('.', l:pos)
  else
    echo "Have no idea how to comment" &ft "file."
  endif
endfunction

function! usr#cmt#cmt_add_vis() abort
  let l:pos_s = getpos("'<")
  let l:pos_e = getpos("'>")
  if has_key(s:cmt_mark_tab_multi, &ft)
    let l:cmt_mark_multi = s:cmt_mark_tab_multi[&ft]
    call setpos('.', l:pos_e)
    call feedkeys("o" . l:cmt_mark_multi[1], 'xn')
    call setpos('.', l:pos_s)
    call feedkeys("O" . l:cmt_mark_multi[0], 'xn')
  elseif has_key(s:cmt_mark_tab_single, &ft)
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
    echo "Have no idea how to comment" &ft "file."
  endif
endfunction

function! usr#cmt#is_cmt_line(lnum) abort
  let l:line = getline(a:lnum)
  if has_key(s:cmt_mark_tab_single, &ft)
    let l:cmt_mark = s:cmt_mark_tab_single[&ft]
    let l:esc_cmt_mark = usr#lib#vim_reg_esc(l:cmt_mark)
    if l:line =~ '\v^\s*' . l:esc_cmt_mark . '.*$'
      let l:res = substitute(l:line, '\v^(\s*)' . l:esc_cmt_mark . '(.*)$',
            \ '\=submatch(1).submatch(2)', '')
      return [1, l:res]
    endif
  endif
  return [0, l:line]
endfunction

" TODO:
" usr#cmt#del_cmt_block
" usr#cmt#cmt_del_norm
" usr#cmt#cmt_del_vis
