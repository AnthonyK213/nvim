function! my#util#terminal() abort
  let l:shell = g:_my_dep_sh
  if type(l:shell) == v:t_list && !empty(l:shell)
    let l:exec = l:shell[0]
    let l:cmd = l:shell
  elseif type(l:shell) == v:t_string
    let l:exec = l:shell
    let l:cmd = [l:shell]
  else
    echo "The shell is invalid, please check `nvimrc`."
    return
  endif
  if !executable(l:exec)
    echo l:exec "is not a valid shell."
    return
  endif
  if has("nvim")
    call my#lib#belowright_split(15)
    setl nonu
    call termopen(l:cmd)
    call feedkeys('i', 'n')
  else
    call term_start(l:cmd)
  endif
endfunction

" Open and edit test file in vim.
function! my#util#edit_file(file_path, chdir) abort
  let l:path = expand(fnameescape(a:file_path))
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
  if has("nvim")
    call jobstart(l:cmd, { 'cwd': l:cwd })
  else
    if has("win32")
      let l:cmd = join(l:cmd, " ")
    endif
    call job_start(l:cmd, { 'cwd': l:cwd })
  endif
endfunction

" Search web.
function! my#util#search_web(mode, site) abort
  if a:mode ==? "n"
    let l:search_obj = my#lib#encode_url(my#lib#get_word()[0])
  elseif a:mode ==? "v"
    let l:search_obj = my#lib#encode_url(my#lib#get_visual_selection())
  endif
  call my#util#sys_open(a:site . l:search_obj, v:false)
endfunction

function! my#util#search_selection(cmd) abort
  let pat = my#lib#get_visual_selection()
  return '\V' . substitute(escape(pat, a:cmd . '\'), '\n', '\\n', 'g')
endfunction

function! my#util#git_push_all(...) abort
  if my#compat#has_incompat() | return | endif
  if !my#lib#executable("git") | return | endif
  let l:arg_list = a:000
  let l:git_root = my#lib#get_root('.git')
  if l:git_root != v:null
    let l:git_branch = my#lib#get_git_branch(l:git_root)
  else
    call my#lib#notify_err("Not a git repository.")
    return
  endif
  if l:git_branch != v:null
    exe 'cd' fnameescape(l:git_root)
  else
    call my#lib#notify_err("Not a valid git repository.")
    return
  endif
  if len(l:arg_list) % 2 == 0
    let l:m_index = index(l:arg_list, "-m")
    let l:b_index = index(l:arg_list, "-b")
    if (l:m_index >= 0) && (l:m_index % 2 == 0)
      let l:m_arg = l:arg_list[l:m_index + 1]
    elseif l:m_index < 0
      let l:m_arg = strftime('%y%m%d')
    else
      call my#lib#notify_err("Invalid commit argument.")
      return
    endif
    if (l:b_index >= 0) && (l:b_index % 2 == 0)
      let l:b_arg = l:arg_list[l:b_index + 1]
    elseif l:b_index < 0
      let l:b_arg = l:git_branch
    else
      call my#lib#notify_err("Invalid branch argument.")
    endif
  else
    call my#lib#notify_err("Wrong number of arguments is given.")
    return
  endif
  function! s:git_commit_cb(proc, job_id, data, event) closure
    if a:data == 0
      echomsg "Commit message:" l:m_arg
    else
      call my#lib#notify_err(join(a:proc.standard_output))
    endif
  endfunction
  function! s:git_push_cb(proc, job_id, data, event) closure
    if a:data == 0
      echomsg join(a:proc.standard_output)
    else
      call my#lib#notify_err(join(a:proc.standard_output))
    endif
  endfunction
  let l:git_add = my#proc#new("git", {
        \ "args": ["add", "*"],
        \ "cwd": l:git_root
        \ })
  let l:git_commit = my#proc#new("git", {
        \ "args": ["commit", "-m", l:m_arg],
        \ "cwd": l:git_root
        \ }, function("s:git_commit_cb"))
  let l:git_push = my#proc#new("git", {
        \ "args": ["push", "origin", l:b_arg, "--porcelain"],
        \ "cwd": l:git_root
        \ }, function("s:git_push_cb"))
  call l:git_add.continue_with(l:git_commit)
  call l:git_commit.continue_with(l:git_push)
  call l:git_add.start()
endfunction
