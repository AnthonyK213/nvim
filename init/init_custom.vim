""" Global variables.
" Leader key
let g:mapleader="\<Space>"
" Pairs
let g:custom_pairs = ["()", "[]", "{}", "''", "\"\""]
let g:quote_list = ["\"", "'"]
augroup specialquote
    autocmd!
    au BufEnter,BufRead *      let g:last_spec = [] | let g:next_spec = []
    au BufEnter,BufRead *.rs   let g:last_spec = ["<", "&"] | let g:next_spec = []
    au BufEnter,BufRead *.lisp let g:last_spec = [] | let g:next_spec = ["("]
    au BufEnter,BufRead *.vim,*.vimrc let g:last_spec = [""] | let g:next_spec = []
augroup end
" Directories
if !empty(glob(expand('$ONEDRIVE')))
    let g:onedrive_path = expand('$ONEDRIVE')
    let g:usr_desktop = expand(fnamemodify(g:onedrive_path, ':h') . "/Desktop")
else
    let g:onedrive_path = expand('$HOME')
    let g:usr_desktop = expand('$HOME')
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
function! IsEncompByPair(pair_list)
    let last_char = Lib_Get_Char(0)
    let next_char = Lib_Get_Char(1)
    return index(a:pair_list, last_char . next_char)
endfunction

function! PairEnter()
    return IsEncompByPair(g:custom_pairs) >= 0 ? "\<CR>\<ESC>O" : "\<CR>"
endfunction

function! PairBacks()
    return IsEncompByPair(g:custom_pairs) >= 0 ? "\<C-G>U\<Right>\<BS>\<BS>" : "\<BS>"
endfunction

function! PairMates(pair_a, pair_b)
    return Lib_Is_Word(Lib_Get_Char(1)) ? a:pair_a : a:pair_a . a:pair_b . "\<C-G>U\<Left>"
endfunction

function! PairClose(pair_b)
    return Lib_Get_Char(1) ==# a:pair_b ? "\<C-G>U\<Right>" : a:pair_b
endfunction

function! PairQuote(quote)
    let last_char = Lib_Get_Char(0)
    let next_char = Lib_Get_Char(1)
    let l_is_word = Lib_Is_Word(last_char)
    let n_is_word = Lib_Is_Word(next_char)
    if next_char ==# a:quote && (last_char ==# a:quote || l_is_word)
        return "\<C-G>U\<Right>"
    elseif l_is_word || n_is_word || index(g:quote_list + g:last_spec, last_char) >= 0 || index(g:quote_list + g:next_spec, next_char) >= 0
        return a:quote
    else
        return a:quote . a:quote . "\<C-G>U\<Left>"
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
" Nevigate
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
nnoremap <M-w> <C-w>w
inoremap <M-h> <Esc><C-w>h
inoremap <M-j> <Esc><C-w>j
inoremap <M-k> <Esc><C-w>k
inoremap <M-l> <Esc><C-w>l
inoremap <M-w> <Esc><C-w>w
tnoremap <Esc> <C-\><C-n>
tnoremap <M-h> <C-\><C-N><C-w>h
tnoremap <M-j> <C-\><C-N><C-w>j
tnoremap <M-k> <C-\><C-N><C-w>k
tnoremap <M-l> <C-\><C-N><C-w>l
tnoremap <M-w> <C-\><C-N><C-w>w
" Buffer
nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>
nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>cd :lcd %:p:h<CR>
" Spell check
nnoremap <silent> <leader>ss :set spell spelllang=en_us<CR>
nnoremap <silent> <leader>se :set nospell<CR>
" For wrapped lines
nnoremap <C-j> gj
nnoremap <C-k> gk
vnoremap <C-j> gj
vnoremap <C-k> gk
" Insert an orgmode-style timestamp at the end of the line
nnoremap <silent> <C-c><C-c> m'A<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>
" Open vimrc(init.vim)
nnoremap <M-,> :tabnew $MYVIMRC<CR>
" markdown
inoremap <M-p> ``<Esc>i
inoremap <M-i> **<Esc>i
inoremap <M-b> ****<Esc>hi
inoremap <M-m> ******<Esc>hhi
" Highlight off
nnoremap <silent> <leader>h :noh<CR>
" Terminal off
tnoremap <silent> <M-d> <C-\><C-N>:q<CR>
" Mouse toggle
nnoremap <silent> <F2> :call MouseToggle()<CR>
" Pairs
inoremap <silent>  (   <C-r>=PairMates("(", ")")<CR>
inoremap <silent>  [   <C-r>=PairMates("[", "]")<CR>
inoremap <silent>  {   <C-r>=PairMates("{", "}")<CR>
inoremap <silent>  )   <C-r>=PairClose(")")<CR>
inoremap <silent>  ]   <C-r>=PairClose("]")<CR>
inoremap <silent>  }   <C-r>=PairClose("}")<CR>
inoremap <silent>  '   <C-r>=PairQuote("'")<CR>
inoremap <silent>  "   <C-r>=PairQuote("\"")<CR>
inoremap <silent> <CR> <C-r>=PairEnter()<CR>
inoremap <silent> <BS> <C-r>=PairBacks()<CR>
