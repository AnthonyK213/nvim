Plug 'rakr/vim-one'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

set relativenumber
set foldenable
set foldmethod=syntax
set foldlevelstart=99
set foldmethod=manual
set clipboard=unnamed

set whichwrap=b,s,<,>,[,]
set backspace=indent,eol,start whichwrap+=<,>,[,]
set textwidth=0
set wrapmargin=0
set formatoptions-=tc
set formatoptions+=l
set signcolumn=number

highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE

augroup remember_folds
    autocmd!
    au BufWinLeave ?* mkview 1
    au BufWinEnter ?* silent! loadview 1
augroup end


" Pairs
let g:custom_pairs = {
    \ "(": ")",
    \ "[": "]",
    \ "{": "}",
    \ "'": "'",
    \ "\"": "\""
  \ }

function! Is_Encomp_By_Pair(pair_dict)
    let back = Lib_Get_Char(0)
    let fore = Lib_Get_Char(1)
    if has_key(a:pair_dict, back)
        if a:pair_dict[back] ==# fore | return 1 | endif
    endif
    return 0
endfunction

function! Pair_Enter()
    return Is_Encomp_By_Pair(g:custom_pairs) ? "\<CR>\<ESC>O" : "\<CR>"
endfunction

function! Pair_Backs()
    return Is_Encomp_By_Pair(g:custom_pairs) ? "\<C-G>U\<Right>\<BS>\<BS>" : "\<BS>"
endfunction

function! Pair_Mates(pair_a)
    return Lib_Is_Word(Lib_Get_Char(1)) ? a:pair_a : a:pair_a . g:custom_pairs[a:pair_a] . "\<C-G>U\<Left>"
endfunction

function! Pair_Close(pair_b)
    return Lib_Get_Char(1) ==# a:pair_b ? "\<C-G>U\<Right>" : a:pair_b
endfunction

function! Pair_Quote(quote)
    let last_char = Lib_Get_Char(0)
    let next_char = Lib_Get_Char(1)
    let l_is_word = Lib_Is_Word(last_char)
    let n_is_word = Lib_Is_Word(next_char)
    let quote_list = ["\"", "'"]
    let rust_quote = ["<", "&"]    " Rust lifetime annotation.
    let lisp_quote = ["("]         " Lisp quote.
    if next_char ==# a:quote && (last_char ==# a:quote || l_is_word) 
        return "\<C-G>U\<Right>"
    endif
    if l_is_word || n_is_word || index(quote_list + rust_quote, last_char) >= 0 || index(quote_list + lisp_quote, next_char) >= 0
        return a:quote
    endif
    return a:quote . a:quote . "\<C-G>U\<Left>"
endfunction

inoremap <silent>  (   <C-r>=Pair_Mates("(")<CR>
inoremap <silent>  [   <C-r>=Pair_Mates("[")<CR>
inoremap <silent>  {   <C-r>=Pair_Mates("{")<CR>
inoremap <silent>  )   <C-r>=Pair_Close(")")<CR>
inoremap <silent>  ]   <C-r>=Pair_Close("]")<CR>
inoremap <silent>  }   <C-r>=Pair_Close("}")<CR>
inoremap <silent>  '   <C-r>=Pair_Quote("'")<CR>
inoremap <silent>  "   <C-r>=Pair_Quote("\"")<CR>
inoremap <silent> <CR> <C-r>=Pair_Enter()<CR>
inoremap <silent> <BS> <C-r>=Pair_Backs()<CR>
