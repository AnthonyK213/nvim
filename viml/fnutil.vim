" Variables
"" OS
if has("win32")
  let g:util_def_start = 'start'
  let g:util_def_shell = get(g:, 'default_shell', 'powershell.exe -nologo')
  let g:util_def_cc = get(g:, 'default_c_compiler', 'gcc')
  let g:python3_host_prog = get(g:, 'python3_exec_path', $HOME . '/Appdata/Local/Programs/Python/Python38/python.EXE')
  set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
  set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
  set wildignore+=*.pyc
  set wildignore+=*.DS_Store
  set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz
elseif has("unix")
  let g:util_def_start = 'xdg-open'
  let g:util_def_shell = get(g:, 'default_shell', 'bash')
  let g:util_def_cc = get(g:, 'default_c_compiler', 'gcc')
  let g:python3_host_prog = get(g:, 'python3_exec_path', '/usr/bin/python3')
  set wildignore+=*.so
elseif has("mac")
  let g:util_def_start = 'open'
  let g:util_def_shell = get(g:, 'default_shell', 'zsh')
  let g:util_def_cc = get(g:, 'default_c_compiler', 'clang')
endif
"" Search web
let s:util_web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }
"" Escape string for URL.
let s:lib_const_esc_url = {
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
"" Directional operation which won't mess up the history.
let g:lib_const_l = "\<C-g>U\<Left>"
let g:lib_const_d = "\<C-g>U\<Down>"
let g:lib_const_u = "\<C-g>U\<Up>"
let g:lib_const_r = "\<C-g>U\<Right>"


" Functions

"" Open terminal and launch shell
function! s:util_terminal()
  call usr#lib#belowright_split(15)
  exe ':terminal' g:util_def_shell
endfunction

"" Open file of buffer with system default browser.
function! s:util_open()
  let l:file_path = '"' . escape(expand('%:p'), '%#') . '"'
  let l:cmd = has("win32") ? '' : g:util_def_start
  silent exe '!' . l:cmd l:file_path
endfunction

"" Open file manager
function! s:util_explorer()
  silent exe '!' . g:util_def_start '.'
endfunction

"" Open pdf file
function! s:util_pdf_view(...)
  if a:0 > 0
    let l:name = a:1
  else
    let l:name = escape(expand('%:r'), '%#') . '.pdf'
  endif
  silent exe '!' . g:util_def_start l:name
endfunction

"" Search web
function! s:util_search_web(mode, site)
  let l:del_list = [
        \ ".", ",", "'", "\"",
        \ ";", "*", "~", "`", 
        \ "(", ")", "[", "]", "{", "}"
        \ ]
  if a:mode ==? "n"
    let l:search_obj = usr#lib#str_escape(lib_get_clean_cword(l:del_list), s:lib_const_esc_url)
  elseif a:mode ==? "v"
    let l:search_obj = usr#lib#str_escape(lib_get_visual_selection(), s:lib_const_esc_url)
  endif
  let l:url_raw = s:util_web_list[a:site] . l:search_obj
  let l:url_arg = has("win32") ? l:url_raw : '"' . l:url_raw . '"'
  silent exe '!' . g:util_def_start l:url_arg
  redraw
endfunction

"" LaTeX recipes
function! s:util_latex_xelatex()
  let l:name = expand('%:r')
  exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error' l:name . '.tex'
endfunction

function! s:util_latex_xelatex2()
  call s:util_latex_xelatex()
  call s:util_latex_xelatex()
endfunction

function! s:util_latex_biber()
  let l:name = expand('%:r')
  call s:util_latex_xelatex()
  exe '!biber' l:name . '.bcf'
  call s:util_latex_xelatex()
  call s:util_latex_xelatex()
endfunction

"" Run code
function! s:util_run_or_compile(option)
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
      exe l:cmdh g:util_def_cc l:file '-o' l:name . l:oute '&&' l:exec . l:name
    elseif l:optn ==? 'check'
      exe l:cmdh g:util_def_cc l:file '-g -o' l:name . l:oute
    elseif l:optn ==? 'build'
      exe l:cmdh g:util_def_cc l:file '-O2 -o' l:name . l:oute
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
  else
    " ERROR
    echo 'Unknown file type: .' . l:exts
  endif
endfunction


" Key maps
"" Mouse toggle
nn  <silent> <F2> :call           usr#util#mouse_toggle()<CR>
vn  <silent> <F2> :<C-u>call      usr#util#mouse_toggle()<CR>
ino <silent> <F2> <C-\><C-o>:call usr#util#mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-n>:call usr#util#mouse_toggle()<CR>a
"" Background toggle
nn  <silent> <leader>bg :call usr#util#bg_toggle()<CR>
""" Explorer
nn  <silent> <leader>oe :call <SID>util_explorer()<CR>
"" Terminal
nn  <silent> <leader>ot :call <SID>util_terminal()<CR>i
"" Open with system default browser
nn  <silent> <leader>ob :call <SID>util_open()<CR>
"" Windows-like behaviors
""" Save
nn  <silent> <C-s> :w<CR>
ino <silent> <C-s> <C-\><C-o>:w<CR>
""" Undo
nn  <silent> <C-z> u
ino <silent> <C-z> <C-\><C-o>u
""" Copy/Paste
vn  <silent> <M-c> "+y
vn  <silent> <M-x> "+x
nn  <silent> <M-v> "+p
vn  <silent> <M-v> "+p
ino <silent> <M-v> <C-R>=@+<CR>
""" Select
nn  <silent> <M-a> ggVG
ino <silent> <M-a> <Esc>ggVG
"" Hanzi count
nn  <silent> <leader>cc
      \ :echo 'Chinese characters count: ' . usr#util#hanzi_count("n")<CR>
vn  <silent> <leader>cc
      \ :<C-u>echo 'Chinese characters count: ' . usr#util#hanzi_count("v")<CR>
"" Surround
""" Common maps
nn <silent> <leader>sa :call usr#srd#sur_add('n')<CR>
vn <silent> <leader>sa :<C-u>call usr#srd#sur_add('v')<CR>
nn <silent> <leader>sd :call usr#srd#sur_sub('')<CR>
nn <silent> <leader>sc :call usr#srd#sur_sub()<CR>
""" Markdown
for [key, val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for mod_item in ['n', 'v']
    exe mod_item . 'n' '<silent> <M-' . key . '>'
          \ ':call <SID>util_sur_add("' . mod_item . '","' . val . '")<CR>'
  endfor
endfor
"" Search visual selection
vn  <silent> * y/\V<C-r>=usr#lib#get_visual_selection()<CR><CR>
"" Search cword in web browser
for key in keys(s:util_web_list)
  exe 'nn <silent> <leader>k' . key ':call <SID>util_search_web("n", "' . key . '")<CR>'
  exe 'vn <silent> <leader>k' . key ':<C-u>call <SID>util_search_web("v", "' . key . '")<CR>'
endfor
"" List bullets
ino <silent> <M-CR> <C-\><C-o>:call usr#note#md_insert_bullet()<CR>
nn  <silent> <leader>ml :call usr#note#md_sort_num_bullet()<CR>
"" Echo git status
nn <silent> <leader>vs :!git status<CR>
"" Append day of week after the date
nn <silent> <leader>dd :call usr#util#append_day_from_date()<CR>
"" Insert an orgmode-style timestamp at the end of the line
nn <silent> <leader>ds A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>
"" Some emacs shit.
for [key, val] in items({"n": "j", "p": "k"})
  exe 'nn  <C-' . key . '> g' . val
  exe 'vn  <C-' . key . '> g' . val
  exe 'ino <silent> <C-' . key . '> <C-\><C-O>g' . val
endfor
nn  <M-x> :
ino <M-x> <C-\><C-o>:
ino <M-b> <C-\><C-o>b
ino <M-f> <C-\><C-o>e<Right>
ino <C-SPACE> <C-\><C-o>v
ino <silent> <C-a> <C-\><C-o>g0
ino <silent> <C-e> <C-\><C-o>g$
ino <silent> <C-k> <C-\><C-o>D
ino <silent> <M-d> <C-\><C-o>dw
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-\>\<C-o>+" : g:lib_const_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-\>\<C-o>-\<C-\>\<C-o>$" : g:lib_const_l


" Commands
"" Latex
command! Xe1 call <SID>util_latex_xelatex()
command! Xe2 call <SID>util_latex_xelatex2()
command! Bib call <SID>util_latex_biber()
"" Git
command! -nargs=* PushAll :call usr#vcs#git_push_all(<f-args>)
"" Run code
command! -nargs=? CodeRun :call <SID>util_run_or_compile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
"" View PDF
command! -nargs=? -complete=file PDF :call <SID>util_pdf_view(<f-args>)
