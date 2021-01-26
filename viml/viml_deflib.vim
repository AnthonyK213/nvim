" Functions
"" Find the root directory of .git
function! Lib_Get_Git_Root()
  let l:dir = expand('%:p:h')
  while 1
    if !empty(globpath(l:dir, ".git", 1)) | return [1, l:dir] | endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile
  return [0, '']
endfunction

"" Get the branch name without git
function! Lib_Get_Git_Branch(git_root)
  if a:git_root[0] == 0
    return [0, '']
  else
    try
      let l:content = readfile(a:git_root[1] . '/.git/HEAD')
      return [1, split(l:content[0], '/')[-1]]
    catch
      return [0, '']
    endtry
  endif
endfunction

"" Get the character around the cursor.
function! Lib_Get_Char(num) abort
  if a:num ==# 'l'
    return matchstr(getline('.'), '.\%' . col('.') . 'c')
  elseif a:num ==# 'n'
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
  elseif a:num ==# 'b'
    return matchstr(getline('.'), '^.*\%' . col('.') . 'c')
  elseif a:num ==# 'f'
    return matchstr(getline('.'), '\%' . col('.') . 'c.*$')
  else
    echo 'Invalid argument.'
  endif
endfunction

"" Return the <cWORD> without the noisy characters.
function! Lib_Get_Clean_CWORD(del_list)
  let l:c_word = expand("<cWORD>")
  while index(a:del_list, l:c_word[(len(l:c_word) - 1)]) >= 0 && len(l:c_word) >= 2
    let l:c_word = l:c_word[:(len(l:c_word) - 2)]
  endwhile
  while index(a:del_list, l:c_word[0]) >= 0 && len(l:c_word) >= 2
    let l:c_word = l:c_word[1:]
  endwhile
  return l:c_word
endfunction

"" Return the selections as string.
function! Lib_Get_Visual_Selection()
  try
    let l:a_save = @a
    silent normal! gv"ay
    return @a
  finally
    let @a = l:a_save
  endtry
endfunction

"" Replace chars in a string according to a dictionary.
"" Probably function escape() is more useful in most situations.
function! Lib_Str_Escape(str, esc_dict)
  let l:str_lst = split(a:str, '\zs')
  let l:i = 0
  for char in l:str_lst
    if has_key(a:esc_dict, char)
      let l:str_lst[l:i] = a:esc_dict[char]
    endif
    let l:i = l:i + 1
  endfor
  return join(l:str_lst, '')
endfunction
