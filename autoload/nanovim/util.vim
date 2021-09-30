let s:nanovim_mode = {
      \ 'c'     : ' CO ',
      \ 'i'     : ' IN ',
      \ 'ic'    : ' IC ',
      \ 'ix'    : ' IX ',
      \ 'n'     : ' NM ',
      \ 'multi' : ' MU ',
      \ 'niI'   : ' ĨN ',
      \ 'no'    : ' OP ',
      \ 'R'     : ' RP ',
      \ 'Rv'    : ' RP ',
      \ 's'     : ' SC ',
      \ 'S'     : ' SL ',
      \ 't'     : ' TM ',
      \ 'v'     : ' VC ',
      \ 'V'     : ' VL ',
      \ ''    : ' VB ',
      \ }
let s:nanovim_short_ft = [
      \ 'NvimTree', 'help', 'netrw',
      \ 'nerdtree', 'qf',
      \ '__GonvimMarkdownPreview__',
      \ ]


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
function! nanovim#util#mode()
  return has_key(s:nanovim_mode, mode(1)) ? s:nanovim_mode[mode(1)] : '_'
endfunction

" Get file name.
" Shorten then file name when the window is too narrow.
function! nanovim#util#fname()
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
function! nanovim#util#misc_info()
  let l:ls = filter([s:cap_str_init(&ft), s:get_git_branch()], '!empty(v:val)')
  if len(l:ls) | return '(' . join(l:ls, ', ') .')' | else | return '' | endif
endfunction

" When enter/leave the buffer/window, set the status line.
" Long:
" | MODE | file_name (file_type, git_branch)                      line:column |
" Short:
" | file_name                                                                 |
function! nanovim#util#enter()
  if index(s:nanovim_short_ft, &ft) >= 0
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Default# %= %y %#Nano_Face_Default# "
  else
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Faded#%{&modified?'':nanovim#util#mode()}" .
          \ "%#Nano_Face_Header_Popout#%{&modified?nanovim#util#mode():''}" .
          \ "%#Nano_Face_Header_Strong# %{nanovim#util#fname()}%<" .
          \ "%#Nano_Face_Header_Default#  %{nanovim#util#misc_info()}" .
          \ "%= %l:%c %#Nano_Face_Default# "
  endif
endfunction

function! nanovim#util#leave()
  if index(s:nanovim_short_ft, &ft) < 0
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Subtle# %{nanovim#util#fname()}" .
          \ "%= %#Nano_Face_Default# "
  endif
endfunction
