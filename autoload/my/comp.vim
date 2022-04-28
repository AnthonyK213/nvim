" Supported list:
"   1. C
"   2. Common Lisp
"   3. C++
"   4. C#
"   5. Processing
"   6. Python
"   7. Ruby
"   8. Rust
"   9. Vim script
"   10. Lua
"   11. LaTeX


" LaTeX recipes
function! s:latex_xelatex() abort
  let l:name = expand('%:r')
  exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error' l:name . '.tex'
endfunction

function! s:latex_xelatex_2() abort
  call s:latex_xelatex()
  call s:latex_xelatex()
endfunction

function! s:latex_biber() abort
  let l:name = expand('%:r')
  call s:latex_xelatex()
  exe '!biber' l:name . '.bcf'
  call s:latex_xelatex()
  call s:latex_xelatex()
endfunction

function! s:on_event(cb, arg_tbl) abort
  return {id, data, event -> a:cb(a:arg_tbl, [id, data, event])}
endfunction

function! s:cb_run_bin(arg_tbl, cb_args) abort
  if a:cb_args[1] == 0 && a:cb_args[2] == 'exit'
    vertical new
    call termopen([a:arg_tbl['fwd'] . '/' . a:arg_tbl['bin']], {
          \ 'cwd' : a:arg_tbl['fwd']
          \ })
  endif
endfunction

function! s:comp_c(tbl) abort
  let l:cc = g:_my_dep_cc
  let l:opt = a:tbl['opt']
  if !my#lib#executable(l:cc)
    return [v:null, v:null]
  endif
  let l:cmd_tbl = {
        \ ''      : [l:cc, a:tbl['fnm'], '-o', a:tbl['bin']],
        \ 'check' : [l:cc, a:tbl['fnm'], '-g', '-o', a:tbl['bin']],
        \ 'build' : [l:cc, a:tbl['fnm'], '-O2', '-o', a:tbl['bin']],
        \ }
  if l:cmd_tbl->has_key(l:opt)
    let l:cmd = l:cmd_tbl[l:opt]
    if empty(l:opt)
      return [function('s:cb_run_bin'), l:cmd]
    else
      return [v:null, l:cmd]
    endif
  else
    call my#lib#notify_err('Invalid argument.')
    return [v:null, v:null]
  endif
endfunction

function! s:comp_clisp(tbl) abort
  if !my#lib#executable('sbcl')
    return [v:null, v:null]
  endif
  let l:cmd_tbl = {
        \ ''  : ['sbcl', '--noinform', '--load', a:tbl['fnm'], '--eval', '(exit)'],
        \ 'build' : [
          \ 'sbcl', '--noinform', '--load', a:tbl['fnm'], '--eval',
          \ '(sb-ext:save-lisp-and-die "' . a:tbl['bin']
          \ . '" :toplevel (quote main) :executable t)',
          \ ],
          \ }
  let l:opt = a:tbl['opt']
  if l:cmd->has_key(l:opt)
    let l:cmd = l:cmd_tbl[l:opt]
    return [v:null, l:cmd]
  else
    call my#lib#notify_err('Invalid argument.')
    return [v:null, v:null]
  endif
endfunction

function! s:comp_cpp(tbl) abort
  let l:cc = g:_my_dep_cc
  let l:cc_tbl = {
        \ 'gcc' : 'g++',
        \ 'clang' : 'clang++'
        \}
  if l:cc_tbl->has_key(l:cc)
    let l:cppc = l:cc_tbl[l:cc]
    if !my#lib#executable(cc)
      return [v:null, v:null]
    endif
    return [function('s:cb_run_bin'), [l:cppc, a:tbl['fnm'], '-o', a:tbl['bin']]]
  else
    return [v:null, v:null]
  endif
endfunction

function! s:comp_csharp(tbl) abort
  if !has("win32")
    return [v:null, v:null]
  endif
  let l:sln_root = my#lib#get_root("*.sln")
  if l:sln_root != v:null
    if !my#lib#executable('MSBuild')
      return [v:null, v:null]
    endif
    return [v:null, ['MSBuild.exe', l:sln_root]]
  endif
  if !my#lib#executable('csc')
    return [v:null, v:null]
  endif
  let l:cmd_tbl = {
        \ '' : ['csc', '/target:exe', a:tbl['fnm'], '/out:' . a:tbl['bin']],
        \ 'lib' : ['csc', '/target:library', a:tbl['fnm']],
        \ 'mod' : ['csc', '/target:module', a:tbl['fnm']],
        \ 'win' : ['csc', '/target:winexe', a:tbl['fnm']],
        \ }
  let l:opt = a:tbl['opt']
  if l:cmd_tbl->has_key(l:opt)
    let l:cmd = l:cmd_tbl[l:opt]
    if empty(l:opt)
      return [function('s:cb_run_bin'), l:cmd]
    else
      return [v:null, l:cmd]
    endif
  else
    call my#lib#notify_err('Invalid argument.')
    return [v:null, v:null]
  endif
endfunction

function! s:comp_lua(tbl) abort
  if a:tbl['opt'] == ''
    return [v:null, 'luafile %']
  elseif a:tbl['opt'] == 'nojit'
    if !my#lib#executable('lua')
      return [v:null, v:null]
    endif
    return [v:null, ['lua', a:tbl['fnm']]]
  else
    call my#lib#notify_err('Invalid arguments.')
    return [v:null, v:null]
  endif
endfunction

function! s:comp_processing(tbl) abort
  if !my#lib#executable('processing-java')
    return [v:null, v:null]
  endif
  let l:sketch_name = expand('%:p:h:t')
  if has('win32')
    l:output_dir = expand('$TEMP') . '\\nvim_processing\\' . l:sketch_name
  else
    l:output_dir = '/tmp/nvim_processing/' . l:sketch_name
  endif
  return [v:null, [
        \ 'processing-java',
        \ '--sketch=' . a:tbl['fwd'],
        \ '--output=' . l:output_dir,
        \ '--force',
        \ '--run'
        \ ]]
endfunction

function! s:comp_python(tbl) abort
  if !my#lib#executable('python')
    return [v:null, v:null]
  endif
  return [v:null, ['python', a:tbl["fnm"]]]
endfunction

function! s:comp_ruby(tbl) abort
  if !my#lib#executable('ruby')
    return [v:null, v:null]
  endif
  return [v:null, ['ruby', a:tbl["fnm"]]]
endfunction

function! s:comp_rust(tbl) abort
  if !my#lib#executable('cargo')
    return [v:null, v:null]
  endif
  let l:cargo_root = my#lib#get_root('Cargo.toml')
  if l:cargo_root != v:null
    let l:cmd_tbl = {
          \ ''      : ['cargo', 'run'],
          \ 'build' : ['cargo', 'build', '--release'],
          \ 'check' : ['cargo', 'check'],
          \ 'clean' : ['cargo', 'clean'],
          \ 'test'  : ['cargo', 'test']
          \ }
    let l:opt = a:tbl['opt']
    if l:cmd_tbl->has_key(l:opt) 
      let l:cmd = l:cmd_tbl[l:opt]
      return [v:null, l:cmd]
    else
      call my#lib#notify_err('Invalid argument.')
      return [v:null, v:null]
    endif
  endif
  return [function('s:cb_run_bin'), ['rustc', a:tbl['fnm'], '-o', a:tbl['bin']]]
endfunction

function! s:comp_latex(tbl) abort
  if empty(a:tbl['opt'])
    call s:latex_xelatex_2()
  elseif a:a:tbl['opt'] ==# 'biber'
    call s:latex_biber()
  else
    call my#lib#notify_err("Invalid argument.")
  endif
  return [v:null, v:null]
endfunction

function! s:comp_vim(_) abort
  return [v:null, 'source %']
endfunction

let s:comp_table = {
      \ "arduino" : function('s:comp_processing'),
      \ "c" : function('s:comp_c'),
      \ "lisp" : function('s:comp_clisp'),
      \ "cpp" : function('s:comp_cpp'),
      \ "cs" : function('s:comp_csharp'),
      \ "lua" : function('s:comp_lua'),
      \ "python" : function('s:comp_python'),
      \ "ruby" : function('s:comp_ruby'),
      \ "rust" : function('s:comp_rust'),
      \ "tex" : function('s:comp_latex'),
      \ "vim" : function('s:comp_vim')
      \ }

function! my#comp#run_or_compile(option) abort
  let l:tbl = {
        \ "bin" : '_' . expand('%:t:r') . (has("win32") ? '.exe' : ''),
        \ "bwd" : getcwd(),
        \ "fnm" : expand('%:t'),
        \ "fwd" : expand('%:p:h'),
        \ "opt" : a:option,
        \ }
  if s:comp_table->has_key(&ft)
    let l:res = s:comp_table[&ft](l:tbl)
    let l:term_cmd = l:res[1]
    if type(l:term_cmd) == v:t_list
      if my#compat#has_incompat() | return | endif
      call my#lib#belowright_split(30)
      if type(l:res[0]) == v:t_func
        call termopen(l:term_cmd, {
              \ 'cwd' : l:tbl['fwd'],
              \ 'on_exit' : s:on_event(l:res[0], l:tbl)
              \ })
      else
        call termopen(l:term_cmd, { 'cwd' : l:tbl['fwd'] })
      endif
    elseif type(l:term_cmd) == v:t_string
      exe 'cd' fnameescape(l:tbl['fwd'])
      exe l:term_cmd
      exe 'cd' fnameescape(l:tbl['bwd'])
    endif
  else
    call my#lib#notify_err('File type is not supported yet.')
  endif
endfunction
