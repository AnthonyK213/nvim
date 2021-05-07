let s:nanovim_mode={
      \ 'c'     : ' C ',
      \ 'i'     : ' I ',
      \ 'ic'    : ' I ',
      \ 'ix'    : ' I ',
      \ 'n'     : ' N ',
      \ 'multi' : ' M ',
      \ 'niI'   : ' Ĩ ',
      \ 'no'    : ' N ',
      \ 'R'     : ' R ',
      \ 'Rv'    : ' R ',
      \ 's'     : ' S ',
      \ 'S'     : ' S ',
      \ 't'     : ' T ',
      \ 'v'     : ' v ',
      \ 'V'     : ' V ',
      \ ''    : ' B ',
      \ }


" Local functions
" Get the branch
function! s:get_git_branch()
  let l:current_dir = expand('%:p:h')
  let l:is_git_repo = 0
  while 1
    if !empty(globpath(l:current_dir, ".git", 1))
      let l:is_git_repo = 1
      break
    endif
    let l:temp_dir = l:current_dir
    let l:current_dir = fnamemodify(l:current_dir, ':h')
    if l:temp_dir ==# l:current_dir
      break
    endif
  endwhile
  if !l:is_git_repo | return '' | end
  try
    let l:content = readfile(l:current_dir . '/.git/HEAD')
    return '#' . split(l:content[0], '/')[-1]
  catch
    return ''
  endtry
endfunction

function! s:cap_str_init(str)
  if !empty(a:str)
    return toupper(a:str[0]) . a:str[1:]
  endif
  return a:str
endfunction


" Autoload functions
" Get mode.
" It is better to use just one character to show the mode.
function! nanovim#util#get_mode()
  return has_key(s:nanovim_mode, mode(1)) ? s:nanovim_mode[mode(1)] : '_'
endfunction

" Get file name.
" Shorten then file name when the window is too narrow.
function! nanovim#util#get_file_name()
  let l:file_path = expand('%:p')
  let l:file_dir  = expand('%:p:h')
  let l:file_name = expand('%:t')
  
  if empty(l:file_name)
    return "[No Name]"
  endif

  let l:path_sepr = "/"
  if has('win32')
    let l:path_sepr = "\\"
  endif

  if strlen(l:file_path) > winwidth(0) * 0.7
    return l:file_name
  endif

  if strlen(l:file_path) > winwidth(0) * 0.4
    let l:path_list = split(l:file_dir, l:path_sepr)
    let l:path_head = "/"
    if has('win32')
      let l:path_head = remove(l:path_list, 0) . "\\"
    endif
    for l:dir in l:path_list
      if l:dir[0] !=# '.'
        let l:dir_short = l:dir[0]
      elseif strlen(l:dir) > 1
        let l:dir_short = l:dir[0:1]
      else
        let l:dir_short = '.'
      endif
      let l:path_head .= l:dir_short . l:path_sepr
    endfor
    return l:path_head . l:file_name
  endif

  return l:file_path
endfunction

" (filetype, branch)
function! nanovim#util#filetype_and_branch()
  let l:ls_old = [s:cap_str_init(&ft), s:get_git_branch()]
  let l:ls_new = []
  for l:item in l:ls_old
    if !empty(l:item)
      call add(l:ls_new, l:item)
    endif
  endfor
  if len(l:ls_new)
    return '(' . join(l:ls_new, ', ') .')'
  else
    return ''
  endif
endfunction
