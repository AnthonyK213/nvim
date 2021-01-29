" Functions
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
