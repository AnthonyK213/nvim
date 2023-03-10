" Create a below right split window.
function! my#lib#belowright_split(height) abort
  let l:term_h = min([a:height, float2nr(winheight(0) * 0.382)])
  belowright new
  exe 'resize' l:term_h
endfunction

" Defers calling {fn} until {timeout} ms passes.
function! my#lib#defer_fn(fn, timeout) abort
  let l:timer = timer_start(a:timeout, a:fn, { "repeat": 1 })
endfunction

" Check if executable exists.
function! my#lib#executable(name) abort
  if executable(a:name)
    return 1
  endif
  call my#lib#notify_err('Executable ' . a:name . ' is not found.')
  return 0
endfunction

" Get characters around the cursor.
function! my#lib#get_context() abort
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
function! my#lib#get_git_branch(git_root = my#lib#get_root(".git", "directory")) abort
  if a:git_root == v:null | return v:null | endif
  let l:head_file = my#lib#path_append(a:git_root, "/.git/HEAD")
  if !empty(l:head_file) && !empty(glob(l:head_file))
    let l:ref_line = readfile(l:head_file)[0]
    let l:ref_matches = matchlist(l:ref_line, '\vref:\s.+/(.{-})$')
    if len(l:ref_matches) > 0
      let l:branch = l:ref_matches[1]
      if !empty(l:branch)
        return l:branch
      endif
    endif
  endif
  return v:null
endfunction

" Get path of the option file (nvimrc).
function! my#lib#get_nvimrc() abort
  let l:dir_table = [
        \ my#compat#stdpath("config"),
        \ expand("$HOME"),
        \ ]
  let l:ok_index = -1
  for l:i in range(len(l:dir_table))
    let l:dir = l:dir_table[l:i]
    if !empty(glob(l:dir))
      let l:ok_index = l:i
      let l:file_name = "/.nvimrc"
      let l:file_path = l:dir . l:file_name
      if !empty(glob(l:file_path))
        return [1, l:file_path]
      elseif has("win32")
        let l:file_name = "/_nvimrc"
        let l:file_path = l:dir . l:file_name
        if !empty(glob(l:file_path))
          return [1, l:file_path]
        endif
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
function! my#lib#get_root(pattern, ...) abort
  let l:item_type = a:0 == 0 ? "both" : a:1
  if index(["both", "file", "directory"], l:item_type) < 0
    call my#lib#notify_err('Type must be "file" or "directory".')
    return v:null
  endif
  let l:dir = expand('%:p:h')
  while 1
    let l:results = globpath(l:dir, a:pattern, 1, 1)
    if !empty(l:results)
      if l:item_type == "both"
        return l:dir
      endif
      for l:item in l:results
        let l:is_dir = isdirectory(l:item)
        if (l:item_type == "file" && !l:is_dir)
              \ || (l:item_type == "directory" && l:is_dir)
          return l:dir
        endif
      endfor
    endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir
      break
    endif
  endwhile
  return v:null
endfunction

" Get the word and its position under the cursor.
function! my#lib#get_word() abort
  let l:b = my#lib#get_context()['b']
  let l:f = my#lib#get_context()['f']
  let l:p_a = matchstr(l:b, '\v([\u4e00-\u9fff0-9a-zA-Z_-]+)$')
  let l:p_b = matchstr(l:f, '\v^([\u4e00-\u9fff0-9a-zA-Z_-])+')
  let l:word = ''
  if !empty(l:p_b)
    let l:word = l:p_a . l:p_b
  else
    let l:p_a = ''
  endif
  if empty(l:word)
    let l:word = my#lib#get_context()['n']
    let l:p_b = word
  endif
  return [l:word, len(l:b) - len(l:p_a), len(l:b) + len(l:p_b)]
endfunction

" Return the selections as string.
function! my#lib#get_gv() abort
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

" Decode json from file path.
function! my#lib#json_decode(path, strictly = 0) abort
  let l:content = readfile(a:path)
  if empty(l:content)
    return [2, v:null]
  endif
  try
    let l:result = json_decode(l:content)
    return [0, l:result]
  catch
    if a:strictly
      return [1, v:null]
    endif
    let l:content = filter(l:content, {idx, val -> val !~ '\v^\s*//'})
  endtry
  try
    let l:result = json_decode(l:content)
    return [0, l:result]
  catch
    let l:content = join(l:content)
    let l:content = substitute(l:content, '\v,\s*([\]\}])', '\=submatch(1)', 'g')
  endtry
  try
    let l:result = json_decode(l:content)
    return [0, l:result]
  catch
    return [1, v:null]
  endtry
endfunction

" Notify the error message to neovim.
function! my#lib#notify_err(err) abort
  echohl ErrorMsg
  echomsg a:err
  echohl None
endfunction

" Append file/directory/sub-path to a path.
function! my#lib#path_append(path, item) abort
  let l:path_trim = substitute(a:path, '\v[\/]+$', "", "")
  let l:item_trim = substitute(a:item, '\v^[\/]+', "", "")
  return expand(l:path_trim . "/" . l:item_trim)
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
    let l:path = my#lib#path_append(l:cwd, l:path)
  endif
  if empty(glob(l:path))
    return 0
  else
    return 1
  endif
endfunction

" Define highlight group.
function! my#lib#set_hl(name, val) abort
  let l:cmd = []
  let l:map = {'fg': 'guifg', 'bg': 'guibg', 'sp': 'guisp', 'fmt': 'gui'}
  for [l:k, l:v] in items(a:val)
    if has_key(l:map, l:k) && !empty(l:v)
      call add(l:cmd, l:map[l:k] . "=" . l:v)
    endif
  endfor
  if !empty(l:cmd)
    exe "highlight" a:name join(l:cmd, " ")
  endif
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

" Encode URL.
function! my#lib#url_encode(str) abort
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

" Match URL in a string.
function! my#lib#url_match(str) abort
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

function! my#lib#vim_pesc(str) abort
  return escape(a:str, ' ()[]{}<>.+*^$%')
endfunction
