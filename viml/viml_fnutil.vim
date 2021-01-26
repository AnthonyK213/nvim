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
  let g:util_def_cc = get(g:, 'default_c_compiler', 'clang')
endif
"" Search web
let s:util_web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }


" Functions
"" Open terminal and launch shell
function! s:util_terminal()
  call Lib_Belowright_Split(15)
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

"" Surround
function! s:util_sur_pair(pair_a)
  let l:pairs = { "(": ")", "[": "]", "{": "}", "<": ">", " ": " ", "《": "》", "“": "”" }
  if a:pair_a =~ '\v^(\(|\[|\{|\<|\s|《|“)+$'
    return join(reverse(map(split(a:pair_a, '\zs'), {idx, val -> l:pairs[val]})), '')
  elseif a:pair_a =~ '\v^(\<\w+\>)+$'
    return '</' . join(reverse(split(a:pair_a, '<')), '</')
  else
    return a:pair_a
  endif
endfunction

function! s:util_sur_add(mode, ...)
  let l:pair_a = a:0 ? a:1 : input("Surrounding add: ")
  let l:pair_b = s:util_sur_pair(l:pair_a)

  if a:mode ==# 'n'
    let l:org = getpos('.')
    if Lib_Get_Char('f') =~ '\v^.\s' ||
     \ Lib_Get_Char('f') =~ '\v^.$'
      exe "normal! a" . l:pair_b
    else
      exe "normal! Ea" . l:pair_b
    endif
    call setpos('.', l:org)
    if Lib_Get_Char('l') =~ '\v\s' ||
     \ Lib_Get_Char('b') =~ '\v^$'
      exe "normal! i" . l:pair_a
    else
      exe "normal! Bi" . l:pair_a
    endif
  elseif a:mode ==# 'v'
    let l:stt = [0] + getpos("'<")[1:2]
    let l:end = [0] + getpos("'>")[1:2]
    call setpos('.', l:end)
    exe "normal! a" . l:pair_b
    call setpos('.', l:stt)
    exe "normal! i" . l:pair_a
  endif
endfunction

function! s:util_sur_sub(...)
  let l:back = Lib_Get_Char('b')
  let l:fore = Lib_Get_Char('f')
  let l:pair_a = input("Surrounding delete: ")
  let l:pair_b = s:util_sur_pair(l:pair_a)
  let l:pair_a_new = a:0 ? a:1 : input("Change to: ")
  let l:pair_b_new = s:util_sur_pair(l:pair_a_new)
  let l:search_back = '\v.*\zs' . escape(l:pair_a, ' ()[]{}<>.+*')
  let l:search_fore = '\v' . escape(l:pair_b, ' ()[]{}<>.+*')

  if l:back =~ l:search_back && l:fore =~ l:search_fore
    let l:back_new = substitute(l:back, l:search_back, l:pair_a_new, '')
    let l:fore_new = substitute(l:fore, l:search_fore, l:pair_b_new, '')
    let l:line_new = l:back_new . l:fore_new
    call setline(line('.'), l:line_new)
  endif
endfunction

"" Search web
function! s:util_search_web(mode, site)
  let l:del_list = [
        \ ".", ",", "'", "\"",
        \ ";", "*", "~", "`", 
        \ "(", ")", "[", "]", "{", "}"
        \ ]
  if a:mode ==? "n"
    let l:search_obj = Lib_Str_Escape(Lib_Get_Clean_CWORD(l:del_list), g:lib_const_esc_url)
  elseif a:mode ==? "v"
    let l:search_obj = Lib_Str_Escape(Lib_Get_Visual_Selection(), g:lib_const_esc_url)
  endif
  let l:url_raw = s:util_web_list[a:site] . l:search_obj
  let l:url_arg = has("win32") ? l:url_raw : '"' . l:url_raw . '"'
  silent exe '!' . g:util_def_start l:url_arg
  redraw
endfunction

"" Git push all
function! s:util_git_push_all(...)
  let l:arg_list = a:000
  let l:git_root = Lib_Get_Git_Root()

  if l:git_root[0] == 1
    let l:git_branch = Lib_Get_Git_Branch(l:git_root)
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
    call Lib_Belowright_Split(l:size)
    exe l:cmdh 'python' l:file
  elseif l:exts ==? 'c'
    " C
    let l:cmd_arg = ['', 'check', 'build']
    if index(l:cmd_arg, l:optn) < 0
      echo "Invalid argument."
      return
    endif
    call Lib_Belowright_Split(l:size)
    if l:optn ==? ''
      exe l:cmdh g:util_def_cc l:file '-o' l:name . l:oute '&&' l:exec . l:name
    elseif l:optn ==? 'check'
      exe l:cmdh g:util_def_cc l:file '-g -o' l:name . l:oute
    elseif l:optn ==? 'build'
      exe l:cmdh g:util_def_cc l:file '-O2 -o' l:name . l:oute
    endif
  elseif l:exts ==? 'cpp'
    " C++
    call Lib_Belowright_Split(l:size)
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
    call Lib_Belowright_Split(l:size)
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
""" Explorer
nn  <silent> <leader>oe :call <SID>util_explorer()<CR>
"" Terminal
nn  <silent> <leader>ot :call <SID>util_terminal()<CR>i
"" Open with system default browser
nn  <silent> <leader>ob :call <SID>util_open()<CR>
"" Windows-like behaviors
""" Save
nn  <silent> <C-s> :w<CR>
ino <silent> <C-s> <C-o>:w<CR>
""" Undo
nn  <silent> <C-z> u
ino <silent> <C-z> <C-o>u
""" Copy/Paste
vn  <silent> <M-c> "+y
vn  <silent> <M-x> "+x
nn  <silent> <M-v> "+p
vn  <silent> <M-v> "+p
ino <silent> <M-v> <C-R>=@+<CR>
""" Select
nn  <silent> <M-a> ggVG
ino <silent> <M-a> <Esc>ggVG
"" Surround
""" Common maps
nn <silent> <leader>sa :call <SID>util_sur_add('n')<CR>
vn <silent> <leader>sa :<C-u>call <SID>util_sur_add('v')<CR>
nn <silent> <leader>sd :call <SID>util_sur_sub('')<CR>
nn <silent> <leader>sc :call <SID>util_sur_sub()<CR>
""" Markdown
for [key, val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for mod_item in ['n', 'v']
    exe mod_item . 'n' '<silent> <M-' . key . '>'
          \ ':call <SID>util_sur_add("' . mod_item . '","' . val . '")<CR>'
  endfor
endfor
"" Search visual selection
vn  <silent> * y/\V<C-r>=Lib_Get_Visual_Selection()<CR><CR>
"" Search cword in web browser
for key in keys(s:util_web_list)
  exe 'nn <silent> <leader>k' . key ':call <SID>util_search_web("n", "' . key . '")<CR>'
  exe 'vn <silent> <leader>k' . key ':<C-u>call <SID>util_search_web("v", "' . key . '")<CR>'
endfor
"" Echo git status
nn <silent> <leader>vs :!git status<CR>
"" Some emacs shit.
for [key, val] in items({"n": "j", "p": "k"})
  exe 'nn  <C-' . key . '> g' . val
  exe 'vn  <C-' . key . '> g' . val
  exe 'ino <silent> <C-' . key . '> <C-o>g' . val
endfor
nn  <M-x> :
ino <M-x> <C-o>:
ino <M-b> <C-o>b
ino <M-f> <C-o>e<Right>
ino <C-SPACE> <C-o>v
ino <silent> <C-a> <C-o>g0
ino <silent> <C-e> <C-o>g$
ino <silent><expr> <C-k> col('.') >= col('$') ? "" : "\<C-o>D"
ino <silent><expr> <M-d> col('.') >= col('$') ? "" : "\<C-o>dw"
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-o>+" : lib_const_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-o>-\<C-o>$" : lib_const_l


" Commands
"" Git
command! -nargs=* PushAll :call <SID>util_git_push_all(<f-args>)
"" Run code
command! -nargs=? CodeRun :call <SID>util_run_or_compile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
"" View PDF
command! -nargs=? -complete=file PDF :call <SID>util_pdf_view(<f-args>)
