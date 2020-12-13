" Functions
"" Mouse toggle
function! MouseToggle()
    if &mouse == 'a'
        set mouse=
        echom "Mouse disabled"
    else
        set mouse=a
        echom "Mouse enabled"
    endif
endfunction

"" Hanzi count.
function! HanziCount(mode)
    if a:mode ==? "n"
        let content = readfile(expand('%:p'))
        let h_count = 0
        for line in content
            for char in split(line, '.\zs')
                if Lib_Is_Hanzi(char) | let h_count += 1 | endif
            endfor
        endfor
        return h_count
    elseif a:mode ==? "v"
        let select = split(Lib_Get_Visual_Selection(), '.\zs')
        let h_count = 0
        for char in select
            if Lib_Is_Hanzi(char) | let h_count += 1 | endif
        endfor
        return h_count
    else
        echom "Invalid mode argument."
    endif
endfunction

"" Latex recipes (alternative)
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

"" Git push all
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

"" Run code
function! RunOrCompile(option)
    let optn = a:option
    let size = 30
    let cmdh = 'term '
    let file = expand('%:t')
    let name = expand('%:r')
    let exts = expand('%:e')
    " PYTHON
    if exts ==? 'py'
        call Lib_Belowright_Split(size)
        exe cmdh . 'python ' . file
        redraw
    " C
    elseif exts ==? 'c'
        if optn ==? ''
            call Lib_Belowright_Split(size)
            exe cmdh . 'gcc ' . file . ' -o ' . name . ' & ' . name
        elseif optn ==? 'check'
            call Lib_Belowright_Split(size)
            exe cmdh . 'gcc ' . file . ' -g -o ' . name
        elseif optn ==? 'build'
            call Lib_Belowright_Split(size)
            exe cmdh . 'gcc ' . file . ' -O2 -o ' . name
        else
            echo "Invalid argument."
        endif
        redraw
    " C++
    elseif exts ==? 'cpp'
        call Lib_Belowright_Split(size)
        exe cmdh . 'g++ ' . file
        redraw
    " RUST
    elseif exts ==? 'rs'
        if optn ==? ''
            call Lib_Belowright_Split(size)
            exe cmdh . 'cargo run'
        elseif optn ==? 'rustc'
            call Lib_Belowright_Split(size)
            exe cmdh . 'rustc ' . file . ' & ' . name
        elseif optn ==? 'clean'
            exe '!cargo clean'
        elseif optn ==? 'check'
            call Lib_Belowright_Split(size)
            exe cmdh . 'cargo check'
        elseif optn ==? 'build'
            call Lib_Belowright_Split(size)
            exe cmdh . 'cargo build --release'
        else
            echo "Invalid argument."
        endif
        redraw
    " VIML
    elseif exts ==? 'vim'
        exe 'source %'
    " LUA
    elseif exts ==? 'lua'
        exe 'luafile %'
    " ERROR
    else
        echo 'Unknown file type: .' . exts
    endif
endfunction


" Key maps
"" Echo git status: <leader> v* -> v(ersion control)
nnoremap <silent> <leader>vs :!git status<CR>
"" Mouse toggle
nnoremap <silent> <F2> :call MouseToggle()<CR>
inoremap <silent> <F2> <C-o>:call MouseToggle()<CR>
"" Hanzi count; <leader> wc -> w(ord)c(ount)
nnoremap <silent> <leader>wc :echo      'Chinese characters count: ' . HanziCount("n")<CR>
vnoremap <silent> <leader>wc :<C-u>echo 'Chinese characters count: ' . HanziCount("v")<CR>
"" Insert an orgmode-style timestamp at the end of the line
nnoremap <silent> <C-c><C-c> m'A<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>


" Commands
"" Latex
command! Xe1 call Xelatex()
command! Xe2 call Xelatex2()
command! Bib call Biber()
"" Git
command! -nargs=* PushAll :call GitPushAll(<f-args>)
"" Run code
command! -nargs=? CodeRun :call RunOrCompile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
