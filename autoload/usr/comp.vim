"" LaTeX recipes
function! s:latex_xelatex()
  let l:name = expand('%:r')
  exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error' l:name . '.tex'
endfunction

function! s:latex_xelatex_2()
  call s:latex_xelatex()
  call s:latex_xelatex()
endfunction

function! s:latex_biber()
  let l:name = expand('%:r')
  call s:latex_xelatex()
  exe '!biber' l:name . '.bcf'
  call s:latex_xelatex()
  call s:latex_xelatex()
endfunction

" Supported list:
"   1. C
"   2. C++
"   3. C#
"   4. Processing
"   5. Python
"   6. Ruby
"   7. Rust
"   8. Vim script
"   9. Lua (Neovim)
"   10. LaTeX
function! s:comp_c(tbl)
  if empty(a:tbl.optn)
    let l:cmd = usr#pub#var()["ccomp"] . ' ' . a:tbl["file"] . ' -o ' .
          \ a:tbl["name"] . a:tbl["oute"] . ' && ' . a:tbl["exec"] . a:tbl["name"]
    return [1, l:cmd]
  elseif a:tbl.optn ==# "check"
    let l:cmd = usr#pub#var()["ccomp"] . ' ' . a:tbl["file"] . ' -g -o ' .
          \ a:tbl["name"] . a:tbl["oute"]
    return [1, l:cmd]
  elseif a:tbl.optn ==# "build"
    let l:cmd = usr#pub#var()["ccomp"] . ' ' . a:tbl["file"] . ' -O2 -o ' .
          \ a:tbl["name"] . a:tbl["oute"]
    return [1, l:cmd]
  endif
  echom "Invalid argument."
  return [0, ""]
endfunction

function! s:comp_cpp(tbl)
  return [
      \ 1,
      \ "g++ " . a:tbl["file"] . ' -o '. a:tbl["name"] . a:tbl["oute"] .
      \ ' && ' .  a:tbl["exec"] . a:tbl["name"]
      \ ]
endfunction

function! s:comp_csharp(tbl)
  if !has("wind32") | return | endif
  if empty(a:tbl.optn)
    let l:cmd = 'csc ' . a:tbl["file"] . ' && ' . a:tbl["exec"] . a:tbl["name"]
    return [1, l:cmd]
  elseif index(['exe', 'winexe', 'library', 'module'], a:tbl.optn) >= 0
    let l:cmd = 'csc /target:' . a:tbl["optn"] . ' ' . a:tbl["file"]
    return [1, l:cmd]
  endif
  echom "Invalid argument."
  return [0, ""]
endfunction

function! s:comp_lua(tbl)
  return [0, 'luafile ' . a:tbl["path"]]
endfunction

function! s:comp_processing(tbl)
  if exists(":RunProcessing") == 2
    return [0, "RunProcessing"]
  endif
  return [0, ""]
endfunction

function! s:comp_python(tbl)
  return [1, 'python ' . a:tbl["path"]]
endfunction

function! s:comp_ruby(tbl)
  return [1, 'ruby ' . a:tbl["path"]]
endfunction

function! s:comp_rust(tbl)
  if empty(a:tbl.optn)
    l:cmd = 'cargo run'
    return [1, l:cmd]
  elseif a:tbl.optn ==# 'build'
    let l:cmd = 'cargo build --release'
    return [1, l:cmd]
  elseif a:tbl.optn ==# 'check'
    let l:cmd = 'cargo check'
    return [1, l:cmd]
  elseif a:tbl.optn ==# 'clean'
    let l:cmd = '!cargo clean'
    return [0, l:cmd]
  elseif a:tbl.optn ==# 'rustc'
    let l:cmd = 'rustc ' . a:tbl["file"] . ' && ' . a:tbl["exec"] . a:tbl["name"]
    return [1, l:cmd]
  endif
  echom "Invalid argument."
  return [0, ""]
endfunction

function! s:comp_latex(tbl)
  if empty(a:tbl.optn)
    call s:latex_xelatex_2()
  elseif a:tbl.optn ==# 'biber'
    call s:latex_biber()
  else
    echom "Invalid argument."
  endif
  return [0, ""]
endfunction

function! s:comp_vim(tbl)
  return [0, 'source ' . a:tbl["path"]]
endfunction

let s:comp_table = {
      \ "c" : {tbl -> s:comp_c(tbl)},
      \ "cpp" : {tbl -> s:comp_cpp(tbl)},
      \ "cs" : {tbl -> s:comp_csharp(tbl)},
      \ "lua" : {tbl -> s:comp_lua(tbl)},
      \ "processing" : {tbl -> s:comp_processing(tbl)},
      \ "python" : {tbl -> s:comp_python(tbl)},
      \ "ruby" : {tbl -> s:comp_ruby(tbl)},
      \ "rust" : {tbl -> s:comp_rust(tbl)},
      \ "tex" : {tbl -> s:comp_latex(tbl)},
      \ "vim" : {tbl -> s:comp_vim(tbl)}
      \ }

function! usr#comp#run_or_compile(option)
  let l:gcwd = getcwd()
  let l:tbl = {
        \ "exec" : has("win32") == 1 ? '' : './',
        \ "exts" : tolower(expand('%:e')),
        \ "file" : expand('%:t'),
        \ "name" : expand('%:r'),
        \ "optn" : a:option,
        \ "oute" : has("win32") == 1 ? '.exe' : '',
        \ "path" : expand('%:p'),
        \ }

  cd %:p:h

  if has_key(s:comp_table, &ft)
    let [l:term_use, l:term_cmd] = s:comp_table[&ft](l:tbl)
  else
    echom "File type not supported yet."
    exe 'cd' l:gcwd
    return
  endif

  if l:term_cmd ==# ""
    exe 'cd' l:gcwd
    return
  elseif l:term_use
    let l:term_cmd = 'term ' . l:term_cmd
    call usr#lib#belowright_split(30)
  endif

  exe l:term_cmd
endfunction
