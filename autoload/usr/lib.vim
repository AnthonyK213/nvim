" Create a below right split window.
function! usr#lib#belowright_split(height)
  let l:height = min([a:height, float2nr(winheight(0) * 0.382)])
  belowright split
  exe 'resize' l:height
endfunction

" Find the root directory contains patter `pat`.
function! usr#lib#get_root(pat)
  let l:dir = expand('%:p:h')
  while 1
    if !empty(globpath(l:dir, a:pat, 1)) | return l:dir | endif
    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile
  return v:null
endfunction

" Get the branch name.
function! usr#lib#get_git_branch(git_root)
  if a:git_root == v:null
    return v:null
  else
    try
      let l:content = readfile(a:git_root . '/.git/HEAD')
      return split(l:content[0], '/')[-1]
    catch
      return v:null
    endtry
  endif
endfunction

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

" Determines if a character is a Chinese character.
" Why is this faster than regex?
function! usr#lib#is_hanzi(char)
  let l:code = char2nr(a:char)
  return l:code >= 0x4E00 && l:code <= 0x9FA5 ? 1 : 0
endfunction

" Return the <cWORD> without the noisy characters.
function! usr#lib#get_clean_cWORD(del_list)
  let l:c_word = expand("<cWORD>")
  while index(a:del_list, l:c_word[(len(l:c_word) - 1)]) >= 0 &&
        \ len(l:c_word) >= 2
    let l:c_word = l:c_word[:(len(l:c_word) - 2)]
  endwhile
  while index(a:del_list, l:c_word[0]) >= 0 && len(l:c_word) >= 2
    let l:c_word = l:c_word[1:]
  endwhile
  return l:c_word
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

function! usr#lib#vim_reg_esc(str)
  return escape(a:str, '()[]{}<>.+*^$')
endfunction

" Define highlight group.
function! usr#lib#set_hi(group, fg, bg, attr)
  let l:cmd = "highlight " . a:group
  if !empty(a:fg)   | let l:cmd = l:cmd . " guifg=" . a:fg | endif
  if !empty(a:bg)   | let l:cmd = l:cmd . " guibg=" . a:bg | endif
  if !empty(a:attr) | let l:cmd = l:cmd . " gui=" . a:attr | endif
  exe l:cmd
endfunction