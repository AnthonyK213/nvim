" Open terminal and launch shell.
function! usr#util#terminal()
  let l:shell = usr#pub#var('shell')
  if type(l:shell) == v:t_list && !empty(l:shell)
    let l:exec = l:shell[0]
    let l:cmd = l:shell
  elseif type(l:shell) == v:t_string
    let l:exec = l:shell
    let l:cmd = [l:shell]
  else
    echo "The shell is invalid, please check `opt.vim`."
    return
  endif
  if !executable(l:exec)
    echo l:exec "is no a valid shell."
    return
  endif
  call usr#lib#belowright_split(15)
  setl nonu
  call termopen(l:cmd)
endfunction

" Open and edit test file in vim.
function! usr#util#edit_file(file_path, chdir)
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

function! usr#util#match_path_or_url_under_cursor()
  let l:url = usr#lib#match_url(expand('<cWORD>'))[1]
  if l:url != v:null
    return l:url
  endif
  let l:path = expand('<cfile>')
  if usr#lib#path_exists(l:path, expand('%:p:h'))
    return expand(l:path)
  endif
  return v:null
endfunction

function! usr#util#sys_open(obj, use_local=v:false)
  let l:cwd = a:use_local ? expand('%:p:h') : getcwd()
  if type(a:obj) != v:t_string
        \ || !(usr#lib#path_exists(a:obj, l:cwd) || usr#lib#match_url(a:obj)[0])
    echoerr 'Nothing found.'
    return
  endif
  let l:cmd = []
  let l:start = usr#pub#var('start')
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
function! usr#util#search_web(mode, site)
  if a:mode ==? "n"
    let l:search_obj = usr#lib#encode_url(usr#lib#get_word()[0])
  elseif a:mode ==? "v"
    let l:search_obj = usr#lib#encode_url(usr#lib#get_visual_selection())
  endif
  echo a:site . l:search_obj
  call usr#util#sys_open(a:site . l:search_obj, v:false)
endfunction
