""" Global variables.
" Leader key
let g:mapleader = "\<Space>"
" Pairs
let g:usr_pairs = {
    \ "("  : ")",
    \ "["  : "]",
    \ "{"  : "}",
    \ "'"  : "'",
    \ "\"" : "\"",
    \ "`"  : "`",
    \ "*"  : "*",
    \ "**" : "**",
    \ "***": "***",
    \ "<"  : ">",
    \ "$"  : "$"
  \ }
" Directories
if !empty(glob(expand('$ONEDRIVE')))
    let g:onedrive_path = expand('$ONEDRIVE')
    let g:usr_desktop = expand(fnamemodify(g:onedrive_path, ':h') . "/Desktop")
else
    let g:onedrive_path = expand('$HOME')
    let g:usr_desktop = expand('$HOME/Desktop')
endif


""" Functions
" Mouse toggle
function! MouseToggle()
    if &mouse == 'a'
        set mouse=
        echom "Mouse disabled"
    else
        set mouse=a
        echom "Mouse enabled"
    endif
endfunction

" Pairs
let g:usr_quote = []
for [key, value] in items(g:usr_pairs)
    if key ==# value | let g:usr_quote += [key] | endif
endfor

augroup specialquote
    autocmd!
    au BufEnter,BufRead *      let g:last_spec = []         | let g:next_spec = []
    au BufEnter,BufRead *.rs   let g:last_spec = ["<", "&"] | let g:next_spec = []
    au BufEnter,BufRead *.lisp let g:last_spec = []         | let g:next_spec = ["("]
    au BufEnter,BufRead *.vim  let g:last_spec = [""]       | let g:next_spec = []
augroup end

function! IsEncompByPair(pair_dict)
    return index(items(a:pair_dict), [Lib_Get_Char(0), Lib_Get_Char(1)]) >= 0
endfunction

function! PairEnter()
    return IsEncompByPair(g:usr_pairs) ? "\<CR>\<ESC>O" : "\<CR>"
endfunction

function! PairBacks()
    return IsEncompByPair(g:usr_pairs) ? "\<C-g>U\<Right>\<BS>\<BS>" : "\<BS>"
endfunction

function! PairMates(pair_a)
    return Lib_Is_Word(Lib_Get_Char(1)) ? a:pair_a : a:pair_a . g:usr_pairs[a:pair_a] . repeat("\<C-g>U\<Left>", len(g:usr_pairs[a:pair_a]))
endfunction

function! PairClose(pair_b)
    return Lib_Get_Char(1) ==# a:pair_b ? "\<C-g>U\<Right>" : a:pair_b
endfunction

function! PairQuote(quote)
    let last_char = Lib_Get_Char(0)
    let next_char = Lib_Get_Char(1)
    let l_is_word = Lib_Is_Word(last_char)
    let n_is_word = Lib_Is_Word(next_char)
    if next_char ==# a:quote && (last_char ==# a:quote || l_is_word)
        return "\<C-g>U\<Right>"
    elseif l_is_word || n_is_word || index(g:usr_quote + g:last_spec, last_char) >= 0 || index(g:usr_quote + g:next_spec, next_char) >= 0
        return a:quote
    else
        return a:quote . a:quote . "\<C-g>U\<Left>"
    endif
endfunction

""" Hanzi count.
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


""" Auto groups
augroup filetypesbehave
    autocmd!
    au BufEnter *.md,*.org,*.yml setlocal ts=2 sw=2 sts=2 nowrap nolinebreak
    au BufEnter *.cs,*.pde,*.tex,*.java,*.lisp setlocal ts=2 sw=2 sts=2
augroup end


""" Commands
" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')


""" Key mapping
" Ctrl
" For wrapped lines
nnoremap <C-j> gj
nnoremap <C-k> gk
vnoremap <C-j> gj
vnoremap <C-k> gk
" Insert an orgmode-style timestamp at the end of the line
nnoremap <silent> <C-c><C-c> m'A<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>
" Meta
" Open .vimrc(init.vim)
nnoremap <M-,> :tabnew $MYVIMRC<CR>
" Terminal
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <M-d> <C-\><C-N>:q<CR>
" Nevigate
for direct in ['h', 'j', 'k', 'l', 'w']
    exe 'nnoremap <M-' . direct . '> <C-w>'            . direct
    exe 'inoremap <M-' . direct . '> <ESC><C-w>'       . direct
    exe 'tnoremap <M-' . direct . '> <C-\><C-n><C-w>'  . direct
endfor
" Leader
" Buffer
nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>
nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>cd :lcd %:p:h<CR>
" Highlight off
nnoremap <silent> <leader>h :noh<CR>
" Spell check
nnoremap <silent> <leader>ss :set spell spelllang=en_us<CR>
nnoremap <silent> <leader>se :set nospell<CR>
" Mouse toggle
nnoremap <silent> <F2> :call MouseToggle()<CR>
" Pairs
" <CR> could be remapped by other plugin.
inoremap <silent>  <CR> <C-r>=PairEnter()<CR>
inoremap <silent>  <BS> <C-r>=PairBacks()<CR>
inoremap <silent>   (   <C-r>=PairMates("(")<CR>
inoremap <silent>   [   <C-r>=PairMates("[")<CR>
inoremap <silent>   {   <C-r>=PairMates("{")<CR>
inoremap <silent>   )   <C-r>=PairClose(")")<CR>
inoremap <silent>   ]   <C-r>=PairClose("]")<CR>
inoremap <silent>   }   <C-r>=PairClose("}")<CR>
inoremap <silent>   '   <C-r>=PairQuote("'")<CR>
inoremap <silent>   "   <C-r>=PairQuote("\"")<CR>
" Markdown
inoremap <silent> <M-p> <C-r>=PairMates("`")<CR>
inoremap <silent> <M-i> <C-r>=PairMates("*")<CR>
inoremap <silent> <M-b> <C-r>=PairMates("**")<CR>
inoremap <silent> <M-m> <C-r>=PairMates("***")<CR>
" Hanzi count
nnoremap <silent> <leader>wc :echo      'Chinese characters count: ' . HanziCount("n")<CR>
vnoremap <silent> <leader>wc :<C-u>echo 'Chinese characters count: ' . HanziCount("v")<CR>
