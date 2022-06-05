" Create a below right split window.
function! my#lib#belowright_split(height) abort
  let l:term_h = min([a:height, float2nr(winheight(0) * 0.382)])
  belowright new
  exe 'resize' l:term_h
endfunction

" Encode URL.
function! my#lib#encode_url(str) abort
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

" Check if executable exists.
function! my#lib#executable(name) abort
  if executable(a:name)
    return 1
  endif
  call my#lib#notify_err('Executable ' . a:name . ' is not found.')
  return 0
endfunction

" Get the character around the cursor.
function! my#lib#get_char() abort
  let l:col = col('.')
  let l:line = getline('.')
  let l:back = strpart(l:line, 0, l:col - 1)
  let l:fore = strpart(l:line, l:col - 1)
  return {
        \ "b" : l:back,
        \ "f" : l:fore,
        \ "p" : empty(l:back) ? "" : nr2char(strgetchar(l:back, strchars(l:back) - 1)),
        \ "n" : empty(l:fore) ? "" : nr2char(strgetchar(l:fore, 0))
        \ }
endfunction

" Get the branch name.
function! my#lib#get_git_branch(git_root) abort
  if a:git_root == v:null
    return v:null
  else
    let l:git_root = substitute(a:git_root, '\v[\\/]$', '', '')
    let l:dot_git = l:git_root . '/.git'
    if isdirectory(l:dot_git)
      let l:head_file = l:git_root . '/.git/HEAD'
    else
      try
        let l:gitdir_line = readfile(l:dot_git)[0]
        let l:gitdir_matches = matchlist(l:gitdir_line, '\v^gitdir:\s(.+)$')
        if len(l:gitdir_matches) > 0
          let l:gitdir = l:gitdir_matches[1]
          let l:head_file = l:git_root . '/' . l:gitdir . '/HEAD'
        else
          return v:null
        endif
      catch
        return v:null
      endtry
    endif
    try
      let l:ref_line = readfile(l:head_file)[0]
      let l:ref_matches = matchlist(l:ref_line, '\vref:\s.+/(.{-})$')
      if len(l:ref_matches) > 0
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

" Get path of the option file (nvimrc).
function! my#lib#get_nvimrc() abort
  let l:dir_table = [
        \ my#compat#stdpath("config"),
        \ expand("$HOME"),
        \ ]
  let l:prefix = has("win32") ? "_" : "."
  let l:file_name = "/" . l:prefix . "nvimrc"
  let l:ok_index = -1
  for i in range(len(l:dir_table))
    let l:dir = l:dir_table[i]
    if !empty(glob(l:dir))
      let l:ok_index = i
      let l:file_path = l:dir . l:file_name
      if !empty(glob(l:file_path))
        return [1, l:file_path]
      endif
    endif
  endfor
  if l:ok_index >= 0
    return [0, l:dir_table[l:ok_index] . l:file_name]
  else
    return [0, v:null]
  endif
endfunction

" Find the root directory contains patter `pat`.
function! my#lib#get_root(pat) abort
  let l:dir = expand('%:p:h')
  while 1
    if !empty(globpath(l:dir, a:pat, 1)) | return l:dir | endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile
  return v:null
endfunction

" Get the word and its position under the cursor.
function! my#lib#get_word() abort
  let l:b = my#lib#get_char()['b']
  let l:f = my#lib#get_char()['f']
  let l:p_a = matchstr(l:b, '\v([\u4e00-\u9fff0-9a-zA-Z_-]+)$')
  let l:p_b = matchstr(l:f, '\v^([\u4e00-\u9fff0-9a-zA-Z_-])+')
  let l:word = ''
  if !empty(l:p_b)
    let l:word = l:p_a . l:p_b
  else
    let l:p_a = ''
  endif
  if empty(l:word)
    let l:word = my#lib#get_char()['n']
    let l:p_b = word
  endif
  return [l:word, len(l:b) - len(l:p_a), len(l:b) + len(l:p_b)]
endfunction

" Return the selections as string.
function! my#lib#get_visual_selection() abort
  try
    let l:a_save = @a
    silent normal! gv"ay
    return @a
  finally
    let @a = l:a_save
  endtry
endfunction

" Determines if a character is a Chinese character.
function! my#lib#is_hanzi(char) abort
  let l:code = char2nr(a:char)
  return l:code >= 0x4E00 && l:code <= 0x9FA5 ? 1 : 0
endfunction

" Match URL in a string.
function! my#lib#match_url(str) abort
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
  return [0, v:null]
endfunction

" Notify the error message to neovim.
function! my#lib#notify_err(err) abort
  echohl ErrorMsg
  echomsg a:err
  echohl None
endfunction

" Check if file/directory exists.
function! my#lib#path_exists(path, ...) abort
  let l:is_rel = 1
  let l:path = expand(a:path)
  if has('win32')
    if path =~ '\v^\a:[\\/]'
      let l:is_rel = 0
    endif
  else
    if path =~ '\v^/'
      let l:is_rel = 0
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
  if empty(glob(l:path))
    return 0
  else
    return 1
  endif
endfunction

" Define highlight group.
function! my#lib#set_hi(group, fg, bg, attr) abort
  let l:cmd = "highlight " . a:group
  if !empty(a:fg)   | let l:cmd = l:cmd . " guifg=" . a:fg | endif
  if !empty(a:bg)   | let l:cmd = l:cmd . " guibg=" . a:bg | endif
  if !empty(a:attr) | let l:cmd = l:cmd . " gui=" . a:attr | endif
  exe l:cmd
endfunction

" Replace chars in a string according to a dictionary.
" Probably function escape() is more useful in most situations.
function! my#lib#str_escape(str, esc_dict) abort
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

function! my#lib#vim_reg_esc(str) abort
  return escape(a:str, ' ()[]{}<>.+*^$')
endfunction
