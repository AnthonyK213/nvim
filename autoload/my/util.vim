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
function! my#util#edit_file(file_path, chdir=0) abort
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
  let l:url = my#lib#url_match(expand('<cWORD>'))[1]
  if l:url != v:null
    return l:url
  endif
  let l:path = expand('<cfile>')
  if my#lib#path_exists(l:path, expand('%:p:h'))
    return expand(l:path)
  endif
  return v:null
endfunction

function! my#util#sys_open(obj, use_local=0) abort
  let l:cwd = a:use_local ? expand('%:p:h') : getcwd()
  if type(a:obj) != v:t_string
        \ || !(my#lib#path_exists(a:obj, l:cwd) || my#lib#url_match(a:obj)[0])
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
    let l:search_obj = my#lib#url_encode(my#lib#get_word()[0])
  elseif a:mode ==? "v"
    let l:search_obj = my#lib#url_encode(my#lib#get_gv())
  endif
  call my#util#sys_open(a:site . l:search_obj)
endfunction

function! my#util#search_selection(cmd) abort
  let l:pat = my#lib#get_gv()
  return '\V' . substitute(escape(l:pat, a:cmd . '\'), '\n', '\\n', 'g')
endfunction

let s:funcref_list = []

function my#util#add_funcref(fn) abort
  call add(s:funcref_list, a:fn)
  return len(s:funcref_list) - 1
endfunction

function! my#util#get_funcref(index) abort
  if a:index < len(s:funcref_list)
    return s:funcref_list[a:index]
  endif
endfunction

function! my#util#set_keymap(mode, lhs, rhs, opts = {}) abort
  let l:cmd = a:mode . (has_key(a:opts, "noremap") && a:opts["noremap"] ? "noremap" : "map")
  let l:arg = ""
  for l:a in ["buffer", "nowait", "silent", "script"]
    if has_key(a:opts, l:a) && a:opts[l:a]
      let l:arg .= "<" . l:a . ">"
    endif
  endfor
  if type(a:rhs) == v:t_string
    if has_key(a:opts, "expr") && a:opts["expr"]
      let l:arg .= "<expr>"
    endif
    let l:right = a:rhs
  elseif type(a:rhs) == v:t_func
    let l:arg .= "<expr>"
    let l:index = my#util#add_funcref(a:rhs)
    let l:right = "my#util#get_funcref(" . string(l:index) . ")()"
  else
    return
  endif
  exe l:cmd l:arg a:lhs l:right
endfunction

function! my#util#new_keymap(mode, lhs, new_rhs, opts = 0) abort
  let l:args = maparg(a:lhs, a:mode, v:false, v:true)
  let l:new_opts = type(a:opts) == v:t_dict ? a:opts : l:args
  let l:new_opts["expr"] = 1
  if type(a:new_rhs) != v:t_func
    return
  endif
  if empty(l:args)
    call my#util#set_keymap(a:mode, a:lhs, {-> a:new_rhs({-> a:lhs})}, l:new_opts)
    return
  endif
  if has_key(l:args, "sid")
    let l:fallback_rhs = substitute(l:args["rhs"], '<SID>', "<SNR>" . l:args["sid"] . "_", "g")
  else
    let l:fallback_rhs = l:args["rhs"]
  endif
  if has_key(l:args, "expr") && l:args["expr"]
    call my#util#set_keymap(a:mode, a:lhs, {-> a:new_rhs({-> eval(l:fallback_rhs)})}, l:new_opts)
  else
    call my#util#set_keymap(a:mode, a:lhs, {-> a:new_rhs({-> my#compat#replace_termcodes(l:fallback_rhs, 1, 0, 1)})}, l:new_opts)
  endif
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
  call my#proc#queue_all([l:git_add, l:git_commit, l:git_push])
endfunction

function! my#util#auto_hl(scheme, hl_table, palette) abort
  function! s:c(color_table, name) closure
    if !empty(a:name)
      if a:name[0] ==# '#'
        return a:name
      elseif a:name[0] ==# '$'
        let l:key = a:name[1:]
        if has_key(a:color_table, l:key)
          return a:color_table[l:key]
        endif
      endif
    endif
    return ''
  endfunction
  function! s:hl() closure
    let l:map = a:palette()
    for [l:k, l:v] in items(a:hl_table)
      let l:val = deepcopy(l:v)
      for [l:a, l:b] in items(l:val)
        if index(['fg', 'bg', 'sp'], l:a) >= 0
          let l:val[l:a] = s:c(l:map, l:b)
        endif
      endfor
      call my#lib#set_hl(l:k, l:val)
    endfor
  endfunction
  exe "augroup" a:scheme . "Extd"
  exe "autocmd!"
  exe "au ColorScheme" a:scheme "call <SID>hl()"
  exe "augroup end"
endfunction
