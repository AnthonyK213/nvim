"" Create a below right split window.
function! usr#lib#belowright_split(height)
  let l:height = min([a:height, nvim_win_get_height(0) / 2])
  belowright split
  exe 'resize' l:height
endfunction

"" Find the root directory of .git
function! usr#lib#get_git_root()
  let l:dir = expand('%:p:h')
  while 1
    if !empty(globpath(l:dir, ".git", 1)) | return [1, l:dir] | endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile
  return [0, '']
endfunction

"" Get the branch name without git
function! usr#lib#get_git_branch(git_root)
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
function! usr#lib#get_char(num) abort
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

"" Determines if a character is a Chinese character.
"" Why is this faster than regex?
function! usr#lib#is_hanzi(char)
  let l:code = char2nr(a:char)
  return l:code >= 0x4E00 && l:code <= 0x9FA5 ? 1 : 0
endfunction

"" Return the <cWORD> without the noisy characters.
function! usr#lib#get_clean_cWORD(del_list)
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
function! usr#lib#get_visual_selection()
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
function! usr#lib#str_escape(str, esc_dict)
  let l:str_lst = split(a:str, '.\zs')
  let l:i = 0
  for char in l:str_lst
    if has_key(a:esc_dict, char)
      let l:str_lst[l:i] = a:esc_dict[char]
    endif
    let l:i = l:i + 1
  endfor
  return join(l:str_lst, '')
endfunction