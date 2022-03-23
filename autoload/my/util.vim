" Open terminal and launch shell. [Incompatible]
function! my#util#terminal() abort
  if my#compat#hasIncompat() | return | endif
  let l:shell = g:_my_dep_sh
  if type(l:shell) == v:t_list && !empty(l:shell)
    let l:exec = l:shell[0]
    let l:cmd = l:shell
  elseif type(l:shell) == v:t_string
    let l:exec = l:shell
    let l:cmd = [l:shell]
  else
    echo "The shell is invalid, please check `opt.json`."
    return
  endif
  if !executable(l:exec)
    echo l:exec "is not a valid shell."
    return
  endif
  call my#lib#belowright_split(15)
  setl nonu
  call termopen(l:cmd)
endfunction

" Open and edit test file in vim.
function! my#util#edit_file(file_path, chdir) abort
  let l:path = expand(a:file_path)
  if empty(expand("%:t"))
    silent exe 'e' l:path
  else
    silent exe 'tabnew' l:path
  endif
  if a:chdir
    silent exe 'cd %:p:h'
  endif
endfunction

function! my#util#match_path_or_url_under_cursor() abort
  let l:url = my#lib#match_url(expand('<cWORD>'))[1]
  if l:url != v:null
    return l:url
  endif
  let l:path = expand('<cfile>')
  if my#lib#path_exists(l:path, expand('%:p:h'))
    return expand(l:path)
  endif
  return v:null
endfunction

function! my#util#sys_open(obj, use_local=v:false) abort
  if my#compat#hasIncompat() | return | endif
  let l:cwd = a:use_local ? expand('%:p:h') : getcwd()
  if type(a:obj) != v:t_string
        \ || !(my#lib#path_exists(a:obj, l:cwd) || my#lib#match_url(a:obj)[0])
    call my#lib#notify_err('Nothing found.')
    return
  endif
  let l:cmd = []
  let l:start = g:_my_dep_start
  if type(l:start) == v:t_list
    let l:cmd += l:start
  elseif type(l:start) == v:t_string
    call add(l:cmd, l:start)
  else
    echoerr 'Invalid definition of `start`.'
    return
  endif
  call add(l:cmd, a:obj)
  call jobstart(l:cmd, { 'cwd': l:cwd })
endfunction

" Search web.
function! my#util#search_web(mode, site) abort
  if a:mode ==? "n"
    let l:search_obj = my#lib#encode_url(my#lib#get_word()[0])
  elseif a:mode ==? "v"
    let l:search_obj = my#lib#encode_url(my#lib#get_visual_selection())
  endif
  echo a:site . l:search_obj
  call my#util#sys_open(a:site . l:search_obj, v:false)
endfunction
