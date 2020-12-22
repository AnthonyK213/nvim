" Python3 path
let g:python3_host_prog='/usr/bin/python3'


" Ignore certain files and folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz


" Function
function! Term()
  call Lib_Belowright_Split(15)
  terminal bash
endfunction

function! Expl()
  exe '!explorer.exe .'
  redraw
endfunction


" Key maps
"" Terminal
nn  <M-`> :call Term()<CR>i
ino <M-`> <Esc>:call Term()<CR>i

"" Windows-like behaviors
""" Save
nn  <silent> <C-s> :w<CR>
ino <silent> <C-s> <Esc>:w<CR>a
""" Undo
nn  <silent> <C-z> u
ino <silent> <C-z> <Esc>ua
""" Copy/Paste
vn  <silent> <M-c> "+y
vn  <silent> <M-x> "+x
nn  <silent> <M-v> "+p
vn  <silent> <M-v> "+p
ino <silent> <M-v> <Esc>"+pa
""" Select
nn  <silent> <M-a> ggVG
ino <silent> <M-a> <Esc>ggVG

"" File Manager
nn  <M-e> :call Expl()<CR>
ino <M-e> <Esc>:call Expl()<CR>
