"" OS
if has("win32")
  let s:util_def_start = 'start'
  let s:util_def_shell = get(g:, 'default_shell', 'powershell.exe -nologo')
  let s:util_def_cc = get(g:, 'default_c_compiler', 'gcc')
elseif has("unix")
  let s:util_def_start = 'xdg-open'
  let s:util_def_shell = get(g:, 'default_shell', 'bash')
  let s:util_def_cc = get(g:, 'default_c_compiler', 'gcc')
elseif has("mac")
  let s:util_def_start = 'open'
  let s:util_def_shell = get(g:, 'default_shell', 'zsh')
  let s:util_def_cc = get(g:, 'default_c_compiler', 'clang')
endif
"" Escape string for URL.
let s:esc_url = {
      \ " " : "\\\%20",
      \ "!" : "\\\%21",
      \ '"' : "\\\%22",
      \ "#" : "\\\%23",
      \ "$" : "\\\%24",
      \ "%" : "\\\%25",
      \ "&" : "\\\%26",
      \ "'" : "\\\%27",
      \ "(" : "\\\%28",
      \ ")" : "\\\%29",
      \ "*" : "\\\%2A",
      \ "+" : "\\\%2B",
      \ "," : "\\\%2C",
      \ "/" : "\\\%2F",
      \ ":" : "\\\%3A",
      \ ";" : "\\\%3B",
      \ "<" : "\\\%3C",
      \ "=" : "\\\%3D",
      \ ">" : "\\\%3E",
      \ "?" : "\\\%3F",
      \ "@" : "\\\%40",
      \ "\\": "\\\%5C",
      \ "|" : "\\\%7C",
      \ "\n": "\\\%20",
      \ "\r": "\\\%20",
      \ "\t": "\\\%20"
      \ }


" Functions
"" Open terminal and launch shell
function! usr#util#terminal()
  call usr#lib#belowright_split(15)
  silent exe 'terminal' s:util_def_shell
  setl nonu
endfunction

"" Open and edit test file in vim.
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

"" Open file with system default browser.
function! usr#util#open_file(file_path)
  if empty(glob(a:file_path))
    return
  end
  let l:file_path_esc = '"' . escape(expand(a:file_path), '%#') . '"'
  let l:cmd = has("win32") ? s:util_def_start . ' ""' : s:util_def_start
  silent exe '!' . l:cmd l:file_path_esc
endfunction

"" Search web
function! usr#util#search_web(mode, site)
  let l:del_list = [
        \ ".", ",", "'", "\"",
        \ ";", "*", "~", "`", 
        \ "(", ")", "[", "]", "{", "}"
        \ ]
  if a:mode ==? "n"
    let l:search_obj = usr#lib#str_escape(usr#lib#get_clean_cWORD(l:del_list), s:esc_url)
  elseif a:mode ==? "v"
    let l:search_obj = usr#lib#str_escape(usr#lib#get_visual_selection(), s:esc_url)
  endif
  let l:url_raw = a:site . l:search_obj
  let l:url_arg = has("win32") ? l:url_raw : '"' . l:url_raw . '"'
  silent exe '!' . s:util_def_start l:url_arg
  redraw
endfunction

"" LaTeX recipes
function! s:latex_xelatex()
  let l:name = expand('%:r')
  exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error' l:name . '.tex'
endfunction

function! s:latex_xelatex2()
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

"" Run code
function! usr#util#run_or_compile(option)
  let l:optn = a:option
  let l:size = 30
  let l:cmdh = 'term'
  let l:file = expand('%:t')
  let l:name = expand('%:r')
  let l:exts = expand('%:e')
  if has("win32")
    let l:exec = ''
    let l:oute = '.exe'
  else
    let l:exec = './'
    let l:oute = ''
  end

  if l:exts ==? 'py'
    " PYTHON
    call usr#lib#belowright_split(l:size)
    exe l:cmdh 'python' l:file
  elseif l:exts ==? 'c'
    " C
    let l:cmd_arg = ['', 'check', 'build']
    if index(l:cmd_arg, l:optn) < 0
      echo "Invalid argument."
      return
    endif
    call usr#lib#belowright_split(l:size)
    if l:optn ==? ''
      exe l:cmdh s:util_def_cc l:file '-o' l:name . l:oute '&&' l:exec . l:name
    elseif l:optn ==? 'check'
      exe l:cmdh s:util_def_cc l:file '-g -o' l:name . l:oute
    elseif l:optn ==? 'build'
      exe l:cmdh s:util_def_cc l:file '-O2 -o' l:name . l:oute
    endif
  elseif l:exts ==? 'cpp'
    " C++
    call usr#lib#belowright_split(l:size)
    exe l:cmdh 'g++' l:file
  elseif l:exts ==? 'rs'
    " RUST
    let l:cmd_arg = ['', 'rustc', 'clean', 'check', 'build']
    if index(l:cmd_arg, l:optn) < 0
      echo "Invalid argument."
      return
    endif
    if l:optn ==? 'clean'
      exe '!cargo clean'
      return
    endif
    call usr#lib#belowright_split(l:size)
    if l:optn ==? ''
      exe l:cmdh 'cargo run'
    elseif l:optn ==? 'rustc'
      exe l:cmdh 'rustc' l:file '&&' l:exec . l:name
    elseif l:optn ==? 'check'
      exe l:cmdh 'cargo check'
    elseif l:optn ==? 'build'
      exe l:cmdh 'cargo build --release'
    endif
  elseif l:exts ==? 'vim'
    " VIML
    exe 'source %'
  elseif l:exts ==? 'lua'
    " LUA
    exe 'luafile %'
  elseif l:exts ==? 'tex'
    " TeX
    if l:optn ==? ''
      call s:latex_xelatex()
    elseif l:optn == 'biber'
      call s:latex_biber()
    endif
  else
    " ERROR
    echo 'Unknown file type: .' . l:exts
  endif
endfunction
