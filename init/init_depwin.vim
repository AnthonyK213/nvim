" Python3 path
let g:python3_host_prog=$HOME.'/Appdata/Local/Programs/Python/Python38/python.EXE'


" Ignore certain files and folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz


" Function
function! Term()
  call Lib_Belowright_Split(15)
  terminal powershell.exe -nologo
endfunction

function! Expl()
  exe ':!explorer.exe .'
  redraw
endfunction

function! PDFView(...)
  if a:0 > 0
    let name = a:1
  else
    let name = expand('%:r') . '.pdf'
  endif
  exe '!start SumatraPDF.exe -reuse-instance ' . name
  redraw
endfunction

let s:web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }
let g:esc_url = {
      \ " " : "\\\%20",
      \ "\"": "\\\%22",
      \ "#" : "\\\%23",
      \ "%" : "\\\%25",
      \ "&" : "\\\%26",
      \ "(" : "\\\%28",
      \ ")" : "\\\%29",
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
  let l:url = s:web_list[a:site] . l:search_obj
  silent exe ':!start ' . l:url
  redraw
endfunction


" Key maps
"" Terminal
nn  <M-`> :call Term()<CR>i
ino <M-`> <Esc>:call Term()<CR>i

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
nn <silent> <M-a> ggVG
ino <silent> <M-a> <Esc>ggVG
""" Explorer
nn  <M-e> :call Expl()<CR>
ino <M-e> <Esc>:call Expl()<CR>

"" Search cword in web browser; <leader> f* -> f(ind)
for key in keys(s:web_list)
  exe 'nnoremap <silent> <leader>f' . key . ' :call <SID>util_search_web("n", "' . key . '")<CR>'
  exe 'vnoremap <silent> <leader>f' . key . ' :<C-u>call <SID>util_search_web("v", "' . key . '")<CR>'
endfor


" Command
command! -nargs=? -complete=file PDF :call PDFView(<f-args>)
