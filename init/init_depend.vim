""" Functions
" Latex recipes (alternative)
function! Xelatex()
    let name = expand('%:r')
    exe '!xelatex -synctex=1 -interaction=nonstopmode -file-line-error ' . name . '.tex'
endfunction

function! Xelatex2()
    call Xelatex()
    call Xelatex()
endfunction

function! Biber()
    let name = expand('%:r')
    call Xelatex()
    exe '!biber ' . name . '.bcf'
    call Xelatex()
    call Xelatex()
endfunction

" Git push all
function! GitPushAll(...)
    let arg_list = a:000
    let git_root = Lib_Get_Git_Root()
    if git_root[0] == 0
        echom "Not a git repository."
    elseif git_root[0] == 1
        echo "Git root path: " . git_root[1]
        exe 'cd ' . git_root[1]
        if len(arg_list) % 2 == 0
            exe '!git add *'
            let m_index = index(arg_list, "-m")
            let b_index = index(arg_list, "-b")
            let time = strftime('%y%m%d')
            if (m_index >= 0) && (m_index % 2 == 0)
                exe '!git commit -m ' . arg_list[m_index + 1]
            elseif m_index < 0
                exe '!git commit -m ' . time
            else
                echom "Invalid commit argument."
            endif
            if (b_index >= 0) && (b_index % 2 == 0)
                exe '!git push origin ' . arg_list[b_index + 1]
            elseif b_index < 0
                exe '!git push'
            else
                echom "Invalid branch argument."
            endif
        else
            echom "Wrong number of arguments is given."
        endif
    endif
endfunction

" Run code
function! RunOrCompile(option)
    let optn = a:option
    let file = expand('%:t')
    let name = expand('%:r')
    let exts = expand('%:e')
    let cmdh = 'term '
    " PYTHON
    if exts ==? 'py'
        call Lib_Belowright_Split(30)
        exe cmdh . 'python ' . file
    " C
    elseif exts ==? 'c'
        if optn ==? ''
            call Lib_Belowright_Split(30)
            exe cmdh . 'gcc ' . file . ' -o ' . name
        elseif optn ==? 'check'
            call Lib_Belowright_Split(30)
            exe cmdh . 'gcc ' . file . ' -g -o ' . name
        elseif optn ==? 'build'
            call Lib_Belowright_Split(30)
            exe cmdh . 'gcc ' . file . ' -O2 -o ' . name
        else
            echo "Invalid argument."
        endif
    " C++
    elseif exts ==? 'cpp'
        call Lib_Belowright_Split(30)
        exe cmdh . 'g++ ' . file
    " RUST
    elseif exts ==? 'rs'
        if optn ==? ''
            call Lib_Belowright_Split(30)
            exe cmdh . 'cargo run'
        elseif optn ==? 'rustc'
            call Lib_Belowright_Split(30)
            exe cmdh . 'rustc ' . file . ' & ' . name
        elseif optn ==? 'clean'
            exe '!cargo clean'
        elseif optn ==? 'check'
            call Lib_Belowright_Split(30)
            exe cmdh . 'cargo check'
        elseif optn ==? 'build'
            call Lib_Belowright_Split(30)
            exe cmdh . 'cargo build --release'
        else
            echo "Invalid argument."
        endif
    " ERROR
    else
        echo 'Unknown file type: .' . exts
    endif
    redraw
endfunction


""" Commands
" Latex
command! Xe1 call Xelatex()
command! Xe2 call Xelatex2()
command! Bib call Biber()
" Git
command! -nargs=* PushAll :call GitPushAll(<f-args>)
" Run code
command! -nargs=? CodeRun :call RunOrCompile(<q-args>)


" Echo git status
nnoremap <silent> <leader>vs :!git status<CR>
