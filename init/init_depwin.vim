""" Python3 path
let g:python3_host_prog=$HOME.'/Appdata/Local/Programs/Python/Python38/python.EXE'


""" Ignore certain files and folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz


""" Functions
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

function! SearchWeb(mode, site)
    let mode = a:mode
    let site = a:site
    let del_list = [".", ",", "'", "\"", ";", "*", "~", "`", "(", ")", "[", "]", "{", "}"]
    if mode ==? "word"
        let search_obj = Lib_Url_Format(Lib_Get_Clean_CWORD(del_list))
    elseif mode ==? "sele"
        let search_obj = Lib_Url_Format(Lib_Get_Visual_Selection())
    else
        echom "Invalid mode argument."
    endif
    if site ==? "baidu"
        let url = "https://www.baidu.com/s?wd=" .      search_obj
    elseif site ==? "google"
        let url = "https://www.google.com/search?q=" . search_obj
    elseif site ==? "github"
        let url = "https://github.com/search?q=" .     search_obj
    elseif site ==? "youdao"
        let url = "https://dict.youdao.com/w/eng/" .   search_obj
    else
        echom "Invalid site argument."
    endif
    silent exe '!start ' . url
    redraw
endfunction


""" Command
command! -nargs=? -complete=file PDF :call PDFView(<f-args>)


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
" Explorer
nnoremap <M-e> :call Expl()<CR>
inoremap <M-e> <Esc>:call Expl()<CR>
" Search cword in web browser
nnoremap <silent> <leader>fb :call SearchWeb("word", "baidu")<CR>
nnoremap <silent> <leader>fg :call SearchWeb("word", "google")<CR>
nnoremap <silent> <leader>fh :call SearchWeb("word", "github")<CR>
nnoremap <silent> <leader>fy :call SearchWeb("word", "youdao")<CR>
vnoremap <silent> <leader>fb :<C-u>call SearchWeb("sele", "baidu")<CR>
vnoremap <silent> <leader>fg :<C-u>call SearchWeb("sele", "google")<CR>
vnoremap <silent> <leader>fh :<C-u>call SearchWeb("sele", "github")<CR>
vnoremap <silent> <leader>fy :<C-u>call SearchWeb("sele", "youdao")<CR>
