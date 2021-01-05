" Variables
"" OS
if has("win32")
  let g:util_def_start = ':!start '
  let g:util_def_terminal = 'powershell.exe -nologo'
  let g:util_def_c_compiler = 'gcc '
  let g:python3_host_prog = $HOME . '/Appdata/Local/Programs/Python/Python38/python.EXE'
  set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
  set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
  set wildignore+=*.pyc
  set wildignore+=*.DS_Store
  set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz
elseif has("unix")
  let g:util_def_start = ':!xdg_open '
  let g:util_def_terminal = 'bash'
  let g:util_def_c_compiler = 'gcc '
  let g:python3_host_prog = '/usr/bin/python3'
  set wildignore+=*.so
elseif has("mac")
  let g:util_def_start = ':!open '
  let g:util_def_c_compiler = 'clang '
endif
"" Surround
let g:util_sur_map = {
      \ "<M-P>"  : ["`",     "`"],
      \ "<M-I>"  : ["*",     "*"],
      \ "<M-B>"  : ["**",   "**"],
      \ "<M-M>"  : ["***", "***"],
      \ "<M-U>"  :["<u>", "</u>"],
      \ "<leader>e(" : ["(", ")"],
      \ "<leader>e[" : ["[", "]"],
      \ "<leader>e{" : ["{", "}"],
      \ "<leader>e'" : ["'", "'"],
      \ '<leader>e"' : ['"', '"'],
      \ "<leader>e<" : ["<", ">"],
      \ "<leader>e$" : ["$", "$"]
      \ }
"" Search web
let s:util_web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }
let g:esc_url = {
      \ " " : "\\\%20",
      \ "!" : "\\\%21",
      \ "\"": "\\\%22",
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
"" Mouse toggle
function! s:mouse_toggle()
  if &mouse == 'a'
    set mouse=
    echom "Mouse disabled"
  else
    set mouse=a
    echom "Mouse enabled"
  endif
endfunction

"" Open terminal
function! s:util_terminal()
  call Lib_Belowright_Split(15)
  exe ':terminal ' . g:util_def_terminal
endfunction

"" Open file manager
function! s:util_explorer()
  silent exe g:util_def_start . ' .'
endfunction

"" Open pdf file
function! s:util_pdf_view(...)
  if a:0 > 0
    let l:name = a:1
  else
    let l:name = expand('%:r') . '.pdf'
  endif
  exe g:util_def_start . l:name
endfunction

"" Surround
function! s:util_sur_impl(quote_a, quote_b)
  let l:stt = [0] + getpos("'<")[1:2]
  let l:end = [0] + getpos("'>")[1:2]
  call setpos('.', l:end)
  exe "normal! a" . a:quote_b
  call setpos('.', l:stt)
  exe "normal! i" . a:quote_a
endfunction

function! s:util_sur_def_map(kbd, quote_a, quote_b)
  let l:esc_dict = {"\"":"\\\""}
  let l:key = "\"" . Lib_Str_Escape(a:quote_a, l:esc_dict) . "\", "
  let l:val = "\"" . Lib_Str_Escape(a:quote_b, l:esc_dict) . "\""
  exe 'vnoremap <silent> ' . a:kbd . ' :<C-u>call <SID>util_sur_impl(' . l:key . l:val . ')<CR>'
endfunction

"" Hanzi count.
function! s:hanzi_count(mode)
  if a:mode ==? "n"
    let l:content = readfile(expand('%:p'))
    let l:h_count = 0
    for line in l:content
      for char in split(line, '.\zs')
        if Lib_Is_Hanzi(char) | let l:h_count += 1 | endif
      endfor
    endfor
    return l:h_count
  elseif a:mode ==? "v"
    let l:select = split(Lib_Get_Visual_Selection(), '.\zs')
    let l:h_count = 0
    for char in l:select
      if Lib_Is_Hanzi(char) | let l:h_count += 1 | endif
    endfor
    return l:h_count
  else
    echom "Invalid mode argument."
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
    let l:search_obj = Lib_Str_Escape(Lib_Get_Clean_CWORD(l:del_list), g:esc_url)
  elseif a:mode ==? "v"
    let l:search_obj = Lib_Str_Escape(Lib_Get_Visual_Selection(), g:esc_url)
  else
    echom "Invalid mode argument."
  endif
  let l:url = s:util_web_list[a:site] . l:search_obj
  silent exe g:util_def_start . l:url
  redraw
endfunction

"" Latex recipes (alternative)
function! s:xelatex()
  let l:name = expand('%:r')
  exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error ' . l:name . '.tex'
endfunction

function! s:xelatex2()
  call s:xelatex()
  call s:xelatex()
endfunction

function! s:biber()
  let l:name = expand('%:r')
  call s:xelatex()
  exe '!biber ' . l:name . '.bcf'
  call s:xelatex()
  call s:xelatex()
endfunction

"" Git push all
function! s:git_push_all(...)
  let l:arg_list = a:000
  let l:git_root = Lib_Get_Git_Root()
  if l:git_root[0] == 1
    let l:git_branch = Lib_Get_Git_Branch(l:git_root)
    if l:git_branch[0] == 1
      echo "Git root path : " . l:git_root[1]
      echo "Current branch: " . l:git_branch[1]
      exe 'cd ' . l:git_root[1]
      if len(l:arg_list) % 2 == 0
        exe '!git add *'
        let l:m_index = index(l:arg_list, "-m")
        let l:b_index = index(l:arg_list, "-b")
        let l:time = strftime('%y%m%d')
        if (l:m_index >= 0) && (l:m_index % 2 == 0)
          exe '!git commit -m ' . l:arg_list[l:m_index + 1]
        elseif l:m_index < 0
          exe '!git commit -m ' . l:time
        else
          echom "Invalid commit argument."
        endif
        if (l:b_index >= 0) && (l:b_index % 2 == 0)
          exe '!git push origin ' . l:arg_list[l:b_index + 1]
        elseif l:b_index < 0
          exe '!git push origin ' . l:git_branch[1]
        else
          echom "Invalid branch argument."
        endif
      else
        echom "Wrong number of arguments is given."
      endif
    else
      echom "Not a valid git repository."
    endif
  else
    echom "Not a git repository."
  endif
endfunction

"" Run code
function! s:run_or_compile(option)
  let l:optn = a:option
  let l:size = 30
  let l:cmdh = 'term '
  let l:file = expand('%:t')
  let l:name = expand('%:r')
  let l:exts = expand('%:e')
  let l:exec = has("win32") ? '' : './'
  if l:exts ==? 'py'
    " PYTHON
    call Lib_Belowright_Split(l:size)
    exe l:cmdh . 'python ' . l:file
    redraw
  elseif l:exts ==? 'c'
    " C
    if l:optn ==? ''
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . g:util_def_c_compiler . l:file . ' -o ' . l:name . ' && ' . l:exec . l:name
    elseif l:optn ==? 'check'
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . g:util_def_c_compiler . l:file . ' -g -o ' . l:name
    elseif l:optn ==? 'build'
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . g:util_def_c_compiler . l:file . ' -O2 -o ' . l:name
    else
      echo "Invalid argument."
    endif
    redraw
  elseif l:exts ==? 'cpp'
    " C++
    call Lib_Belowright_Split(l:size)
    exe l:cmdh . 'g++ ' . l:file
    redraw
  elseif l:exts ==? 'rs'
    " RUST
    if l:optn ==? ''
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . 'cargo run'
    elseif l:optn ==? 'rustc'
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . 'rustc ' . l:file . ' && ' . l:exec . l:name
    elseif l:optn ==? 'clean'
      exe '!cargo clean'
    elseif l:optn ==? 'check'
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . 'cargo check'
    elseif l:optn ==? 'build'
      call Lib_Belowright_Split(l:size)
      exe l:cmdh . 'cargo build --release'
    else
      echo "Invalid argument."
    endif
    redraw
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

"" Markdown number bullet
function! s:md_check_line(lnum)
  let l:lstr = getline(a:lnum)
  let l:detect = 0
  let l:bullet = 0
  let l:indent = strlen(matchstr(l:lstr, '\v^(\s*)')) 
  if l:lstr =~ '\v^\s*(\+|-|*)\s+.*$'
    let l:detect = 1
    let l:bullet = substitute(l:lstr,
          \ '\v^\s*(.)\s+.*$', '\=submatch(1)', '')
  elseif l:lstr =~ '\v^\s*(\d+)\.\s+.*$'
    let l:detect = 2
    let l:bullet = substitute(l:lstr,
          \ '\v^\s*(\d+)\.\s+.*$', '\=submatch(1)', '')
  endif
  return [l:detect, l:lstr, l:bullet, l:indent]
endfunction

function! s:md_insert_bullet()
  let l:lnum = line('.')
  let l:linf_c = s:md_check_line('.')

  let l:detect = 0
  let l:bullet = 0
  let l:indent = 0

  if l:linf_c[0] == 0
    let l:lnum_b = l:lnum - 1
    while l:lnum_b > 0
      let l:linf_b = s:md_check_line(l:lnum_b)
      if l:linf_b[3] < l:linf_c[3] && l:linf_b[0] != 0
        let l:detect = l:linf_b[0]
        let l:bullet = l:linf_b[2]
        let l:indent = l:linf_b[3]
        break
      endif
      let l:lnum_b -= 1
    endwhile
  else
    let l:detect = l:linf_c[0]
    let l:bullet = l:linf_c[2]
    let l:indent = l:linf_c[3]
  endif

  if l:detect == 0
    call feedkeys("\<C-o>o")
  else
    let l:lnum_f = l:lnum + 1
    let l:move_d = 0
    let l:move_record = []
    while l:lnum_f <= line('$')
      let l:linf_f = s:md_check_line(l:lnum_f)
      if l:linf_f[0] == l:detect && l:linf_f[3] == l:indent
        call add(l:move_record, l:move_d)
        if l:detect == 1
          break
        elseif l:detect == 2 && l:linf_f[0] == 2
          call setline(l:lnum_f, substitute(l:linf_f[1],
                \ '\v(\d+)', '\=submatch(1) + 1', ''))
        endif
      elseif l:linf_f[3] <= l:indent
        call add(l:move_record, l:move_d)
        break
      elseif l:lnum_f == line('$')
        call add(l:move_record, l:move_d + 1)
        break
      endif
      let l:lnum_f += 1
      let l:move_d += 1
    endwhile
    let l:count_d = len(l:move_record) == 0 ? 0 : l:move_record[0]
    let l:nbullet = l:detect == 2 ? (l:bullet + 1) . '. ' : l:bullet . ' '
    call feedkeys(repeat("\<C-g>U\<Down>", l:count_d) . "\<C-o>o\<C-o>0" .
          \ repeat("\<space>", l:indent) . l:nbullet)
  endif
endfunction

function s:md_sort_num_bullet()
  let l:lnum = line('.')
  let l:linf_c = s:md_check_line('.')

  if l:linf_c[0] == 2
    let l:num_lb = [l:lnum]
    let l:num_lf = []

    let l:lnum_b = l:lnum - 1
    while l:lnum_b > 0
      let l:linf_b = s:md_check_line(l:lnum_b)
      if l:linf_b[0] == 2
        if l:linf_b[3] == l:linf_c[3]
          call add(l:num_lb, l:lnum_b)
        elseif l:linf_b[3] < l:linf_c[3]
          break
        endif
      elseif l:linf_b[0] != 2 && l:linf_b[3] <= l:linf_c[3]
        break
      endif
      let l:lnum_b -= 1
    endwhile

    let l:lnum_f = l:lnum + 1
    while l:lnum_f <= line('$')
      let l:linf_f = s:md_check_line(l:lnum_f)
      if l:linf_f[0] == 2
        if l:linf_f[3] == l:linf_c[3]
          call add(l:num_lf, l:lnum_f)
        elseif l:linf_f[3] < l:linf_c[3]
          break
        endif
      elseif l:linf_f[0] != 2 && l:linf_f[3] <= l:linf_c[3]
        break
      endif
      let l:lnum_f += 1
    endwhile

    let l:num_la = reverse(l:num_lb) + l:num_lf

    let l:i = 1
    for item in l:num_la
      call setline(item, substitute(getline(item),
            \ '\v(\d+)', '\=' . l:i, ''))
      let l:i += 1
    endfor
  else
    echo "Not in a line of any numbered lists."
    return
  endif
endfunction


" Key maps
"" Mouse toggle
nn  <silent> <F2> :call           <SID>mouse_toggle()<CR>
vn  <silent> <F2> :<C-u>call      <SID>mouse_toggle()<CR>
ino <silent> <F2> <C-o>:call      <SID>mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-n>:call <SID>mouse_toggle()<CR>a
"" Terminal
nn  <M-t>      :call <SID>util_terminal()<CR>i
ino <M-t> <Esc>:call <SID>util_terminal()<CR>i
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
""" Explorer
nn  <silent> <F4>      :call <SID>util_explorer()<CR>
ino <silent> <F4> <Esc>:call <SID>util_explorer()<CR>
"" Hanzi count; <leader>wc -> w(ord)c(ount)
nn  <silent> <leader>wc
      \ :echo 'Chinese characters count: ' . <SID>hanzi_count("n")<CR>
vn  <silent> <leader>wc
      \ :<C-u>echo 'Chinese characters count: ' . <SID>hanzi_count("v")<CR>
"" Surround
for [key, val] in items(g:util_sur_map)
  call s:util_sur_def_map(key, val[0], val[1])
endfor
"" Insert an orgmode-style timestamp at the end of the line
nn  <silent> <C-c><C-c> m'A<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>
"" Search visual selection
vn  <silent> * y/\V<C-r>=Lib_Get_Visual_Selection()<CR><CR>
"" Search cword in web browser; <leader> f* -> f(ind)
for key in keys(s:util_web_list)
  exe 'nn <silent> <leader>f' . key . ' :call <SID>util_search_web("n", "' . key . '")<CR>'
  exe 'vn <silent> <leader>f' . key . ' :<C-u>call <SID>util_search_web("v", "' . key . '")<CR>'
endfor
"" List bullets
ino <silent> <M-CR> <C-o>:call <SID>md_insert_bullet()<CR>
nn  <silent> <leader>sl  :call <SID>md_sort_num_bullet()<CR>
"" Echo git status: <leader>v* -> v(ersion control)
nn <silent> <leader>vs :!git status<CR>
"" Some emacs shit.
for [key, val] in items({"n":"j", "p":"k"})
  exe 'nnoremap <C-' . key . '> g' . val
  exe 'vnoremap <C-' . key . '> g' . val
  exe 'inoremap <silent> <C-' . key . '> <C-o>g' . val
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
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-o>+" : g:custom_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-o>-\<C-o>$" : g:custom_l


" Commands
"" Latex
command! Xe1 call <SID>xelatex()
command! Xe2 call <SID>xelatex2()
command! Bib call <SID>biber()
"" Git
command! -nargs=* PushAll :call <SID>git_push_all(<f-args>)
"" Run code
command! -nargs=? CodeRun :call <SID>run_or_compile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
"" View PDF
command! -nargs=? -complete=file PDF :call <SID>util_pdf_view(<f-args>)
