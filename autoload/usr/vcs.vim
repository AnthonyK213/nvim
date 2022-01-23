function! s:on_read(id, data, event) dict
  let l:str = join(a:data, "  ")
  echom str
endfunction

function! s:on_commit(m_arg, b_arg)
  echom 'Commit message:' a:m_arg
  call s:git_push_async(a:b_arg)
endfunction

function! s:on_add(m_arg, b_arg)
  call s:git_commit_async(a:m_arg, a:b_arg)
endfunction

function! s:git_push_async(b_arg)
  call jobstart(
        \ ['git', 'push', 'origin', a:b_arg, '--porcelain'],
        \ {'on_stdout': function('s:on_read'), 'stdout_buffered': v:true}
        \ )
endfunction

function! s:git_commit_async(m_arg, b_arg)
  call jobstart([
    \ 'git',
    \ 'commit',
    \ '-m',
    \ a:m_arg
    \ ], { 'on_exit':{x, y -> s:on_commit(a:m_arg, a:b_arg)} })
endfunction

function! s:git_push_all_async(m_arg, b_arg)
  call jobstart([
    \ 'git',
    \ 'add',
    \ '*'
    \ ], { 'on_exit':{x, y -> s:on_add(a:m_arg, a:b_arg)} })
endfunction

function! usr#vcs#git_push_all(...) abort
  if usr#lib#incompat() | return | endif
  let l:arg_list = a:000
  let l:git_root = usr#lib#get_root('.git')
  if l:git_root != v:null
    let l:git_branch = usr#lib#get_git_branch(l:git_root)
  else
    echom "Not a git repository."
    return
  endif
  if l:git_branch != v:null
    exe 'cd' l:git_root
  else
    echom "Not a valid git repository."
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
      echom "Invalid commit argument."
      return
    endif
    if (l:b_index >= 0) && (l:b_index % 2 == 0)
      let l:b_arg = l:arg_list[l:b_index + 1]
    elseif l:b_index < 0
      let l:b_arg = l:git_branch
    else
      echom "Invalid branch argument."
    endif
    call s:git_push_all_async(l:m_arg, l:b_arg)
  else
    echom "Wrong number of arguments is given."
  endif
endfunction
