""" Python3 path
let g:python3_host_prog='/usr/bin/python3'


"" Ignore certain files and folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz


""" Functions
function! Term()
    call Lib_Belowright_Split(15)
    terminal bash
endfunction

function! Expl()
    exe '!explorer.exe .'
    redraw
endfunction


""" Key mapping
" Terminal
nnoremap <M-`> :call Term()<CR>i
inoremap <M-`> <Esc>:call Term()<CR>i

" Windows-like behaviors
" Save
nnoremap <silent> <C-s> :w<CR>
inoremap <silent> <C-s> <Esc>:w<CR>a
" Undo
nnoremap <silent> <C-z> u
inoremap <silent> <C-z> <Esc>ua
" Copy/Paste
vnoremap <silent> <M-c> "+y
vnoremap <silent> <M-x> "+x
nnoremap <silent> <M-v> "+p
vnoremap <silent> <M-v> "+p
inoremap <silent> <M-v> <Esc>"+pa
" Select
nnoremap <silent> <M-a> ggVG
inoremap <silent> <M-a> <Esc>ggVG
" File Manager
nnoremap <M-e> :call Expl()<CR>
inoremap <M-e> <Esc>:call Expl()<CR>
