function! usr#vcs#git_push_all(...)
  let l:arg_list = a:000
  let l:git_root = usr#lib#get_git_root()

  if l:git_root[0] == 1
    let l:git_branch = usr#lib#get_git_branch(l:git_root)
  else
    echom "Not a git repository."
    return
  endif

  if l:git_branch[0] == 1
    echo "Root directory:" l:git_root[1]
    echo "Current branch:" l:git_branch[1]
    exe 'cd' l:git_root[1]
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
      let l:time = strftime('%y%m%d')
      let l:m_arg = l:time
    else
      echom "Invalid commit argument."
      return
    endif
    silent exe '!git add *'
    silent exe '!git commit -m' l:m_arg
    echom "Commit message:" l:m_arg

    if (l:b_index >= 0) && (l:b_index % 2 == 0)
      let l:b_arg = l:arg_list[l:b_index + 1]
    elseif l:b_index < 0
      let l:b_arg = l:git_branch[1]
    else
      echom "Invalid branch argument."
    endif
    exe '!git push origin' l:b_arg
  else
    echom "Wrong number of arguments is given."
  endif
endfunction
