" Python3 path
let g:python3_host_prog=$HOME.'/Appdata/Local/Programs/Python/Python38/python.EXE'


" Ignore certain files and folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz


" Function
function! s:dep_terminal()
  call Lib_Belowright_Split(15)
  terminal powershell.exe -nologo
endfunction

function! s:dep_explorer()
  exe ':!explorer.exe .'
  redraw
endfunction

function! s:dep_pdf_view(...)
  if a:0 > 0
    let name = a:1
  else
    let name = expand('%:r') . '.pdf'
  endif
  exe '!start SumatraPDF.exe -reuse-instance ' . name
  redraw
endfunction


" Key maps
"" Terminal
nn  <M-t>      :call <SID>dep_terminal()<CR>i
ino <M-t> <Esc>:call <SID>dep_terminal()<CR>i

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
nn  <F4>      :call <SID>dep_explorer()<CR>
ino <F4> <Esc>:call <SID>dep_explorer()<CR>


" Command
command! -nargs=? -complete=file PDF :call <SID>dep_pdf_view(<f-args>)
