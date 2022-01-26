" Get the character around the cursor.
function! usr#lib#get_char(num) abort
  if a:num ==# 'p'
    return matchstr(getline('.'), '.\%' . col('.') . 'c')
  elseif a:num ==# 'n'
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
  elseif a:num ==# 'b'
    return matchstr(getline('.'), '^.*\%' . col('.') . 'c')
  elseif a:num ==# 'f'
    return matchstr(getline('.'), '\%' . col('.') . 'c.*$')
  endif
endfunction

" Find the root directory contains patter `pat`.
function! usr#lib#get_root(pat) abort
  let l:dir = expand('%:p:h')
  while 1
    if !empty(globpath(l:dir, a:pat, 1)) | return l:dir | endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile
  return v:null
endfunction

" Get the branch name.
function! usr#lib#get_git_branch(git_root) abort
  if a:git_root == v:null
    return v:null
  else
    let l:git_root = substitute(a:git_root, '\v[\\/]$', '', '')
    let l:dot_git = l:git_root . '/.git'
    if isdirectory(l:dot_git)
      let l:head_file = l:git_root . './git/HEAD'
    else
      try
        let l:gitdir_line = readfile(l:dot_git)[0]
        let l:gitdir_matches = matchlist(l:gitdir_line, '\v^gitdir:\s(.+)$')
        if l:gitdir_matches->len() > 0
          let l:gitdir = l:gitdir_matches[1]
          let l:head_file = l:git_root . '/' . l:gitdir . '/HEAD'
        else
          return v:null
        endif
      catch
        return v:null
      endtry
    endif
    echo l:head_file
    try
      let l:ref_line = readfile(l:head_file)[0]
      let l:ref_matches = matchlist(l:ref_line, '\vref:\s.+/(.{-})$')
      echo l:ref_matches
      if l:ref_matches->len() > 0
        let l:branch = l:ref_matches[1]
        if !empty(l:branch)
          return l:branch
        else
          return v:null
        endif
      else
        return v:null
      endif
    catch
      return v:null
    endtry
  endif
endfunction

" Return the selections as string.
function! usr#lib#get_visual_selection()
  try
    let l:a_save = @a
    silent normal! gv"ay
    return @a
  finally
    let @a = l:a_save
  endtry
endfunction

" Determines if a character is a Chinese character.
" Why is this faster than regex?
function! usr#lib#is_hanzi(char)
  let l:code = char2nr(a:char)
  return l:code >= 0x4E00 && l:code <= 0x9FA5 ? 1 : 0
endfunction

" Get the word and its position under the cursor.
function! usr#lib#get_word()
  let l:b = usr#lib#get_char('b')
  let l:f = usr#lib#get_char('f')
  let l:p_a = matchstr(l:b, '\v([\u4e00-\u9fff0-9a-zA-Z_-]+)$')
  let l:p_b = matchstr(l:f, '\v^([\u4e00-\u9fff0-9a-zA-Z_-])+')
  let l:word = ''
  if !empty(l:p_b)
    let l:word = l:p_a . l:p_b
  else
    let l:p_a = ''
  endif
  if l:word->empty()
    let l:word = usr#lib#get_char('n')
    let l:p_b = word
  endif
  return [l:word, len(l:b) - len(l:p_a), len(l:b) + len(l:p_b)]
endfunction

" Replace chars in a string according to a dictionary.
" Probably function escape() is more useful in most situations.
function! usr#lib#str_escape(str, esc_dict)
  let l:str_lst = split(a:str, '.\zs')
  let l:i = 0
  for l:char in l:str_lst
    if has_key(a:esc_dict, l:char)
      let l:str_lst[l:i] = a:esc_dict[l:char]
    endif
    let l:i = l:i + 1
  endfor
  return join(l:str_lst, '')
endfunction

" Define highlight group.
function! usr#lib#set_hi(group, fg, bg, attr)
  let l:cmd = "highlight " . a:group
  if !empty(a:fg)   | let l:cmd = l:cmd . " guifg=" . a:fg | endif
  if !empty(a:bg)   | let l:cmd = l:cmd . " guibg=" . a:bg | endif
  if !empty(a:attr) | let l:cmd = l:cmd . " gui=" . a:attr | endif
  exe l:cmd
endfunction

function! usr#lib#vim_reg_esc(str)
  return escape(a:str, ' ()[]{}<>.+*^$')
endfunction

function! usr#lib#encode_url(str)
  let l:res = ""
  for l:char in split(a:str, '.\zs')
    if l:char =~ '\v(\w|\.|-)'
      let l:res .= l:char
    else
      let l:res .= printf("%%%02x", char2nr(l:char))
    endif
  endfor
  return l:res
endfunction

function! usr#lib#match_url(str)
  let l:protocols = {
        \ '' : 0,
        \ 'http://' : 0,
        \ 'https://' : 0,
        \ 'ftp://' : 0
        \ }
  let l:match_res = matchlist(a:str, '\v(\a+://)(\w[-.0-9A-Za-z_]*)(:?)(\d*)(/?)([0-9A-Za-z_.~!*:@&+$/?%#=-]*)')
  if !empty(l:match_res)
    let l:url   = l:match_res[0]
    let l:prot  = l:match_res[1]
    let l:dom   = l:match_res[2]
    let l:colon = l:match_res[3]
    let l:port  = l:match_res[4]
    let l:slash = l:match_res[5]
    let l:path  = l:match_res[6]
    if !empty(url)
          \ && dom !~ '\W\W'
          \ && l:protocols[tolower(l:prot)] == (1 - len(l:slash)) * len(l:path)
          \ && (empty(l:colon) || !empty(port) && str2nr(port) < 65536)
      return [len(l:url) == len(a:str), url]
    endif
  endif
  return [v:false, v:null]
endfunction

" Create a below right split window.
function! usr#lib#belowright_split(height)
  let l:term_h = min([a:height, float2nr(winheight(0) * 0.382)])
  belowright new
  exe 'resize' l:term_h
endfunction

function! usr#lib#notify_err(err)
  echohl ErrorMsg
  echomsg a:err
  echohl None
endfunction

function! usr#lib#path_exists(path, ...)
  let l:is_rel = v:true
  let l:path = expand(a:path)
  if has('win32')
    if path =~ '\v^\a:[\\/]'
      let l:is_rel = v:false
    endif
  else
    if path =~ '\v^/'
      let l:is_rel = v:false
    endif
  endif
  if l:is_rel
    if a:0 == 0
      let l:cwd = getcwd()
    else
      let l:cwd = a:1
    endif
    let l:cwd = substitute(l:cwd, '\v[\\/]$', '', '')
    let l:path = l:cwd . '/' . l:path
  endif
  if l:path->glob()->empty()
    return v:false
  else
    return v:true
  endif
endfunction

function! usr#lib#executable(name)
  if executable(a:name)
    return v:true
  endif
  call usr#lib#notify_err('Executable ' . a:name . ' is not found.')
  return v:false
endfunction

function! usr#lib#incompat() abort
  if has("nvim")
    return 0
  endif
  echohl WarningMsg
  echomsg "Incompatible invocation. Aborted."
  echohl None
  return 1
endfunction
