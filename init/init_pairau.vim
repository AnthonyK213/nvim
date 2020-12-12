" Global variables.
"" Can be overwritten.
""" User defined pairs.
let g:pairs_usr_def = {
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
""" Surround. Elements should be able to be found in pairs_usr_def.
let g:pairs_sur_list = [
    \ "(", "[", "{",
    \ "'", "\"",
    \ "<", "$"]

"" For key maps.
""" Common.
let g:pairs_common_map = {
    \ "("   : "Mates",
    \ "["   : "Mates",
    \ "{"   : "Mates",
    \ ")"   : "Close",
    \ "]"   : "Close",
    \ "}"   : "Close",
    \ "'"   : "Quote",
    \ "\""  : "Quote",
    \ "<CR>": "Enter",
    \ "<BS>": "Backs"
  \ }
""" Markdown pairs.
let g:pairs_md_map = {
    \ "`"  : "p",
    \ "*"  : "i",
    \ "**" : "b",
    \ "***": "m"
  \ }

"" Pair special quotes.
augroup pair_special
    autocmd!
    au BufEnter *      let g:last_spec = []         | let g:next_spec = []
    au BufEnter *.rs   let g:last_spec = ["<", "&"] | let g:next_spec = []
    au BufEnter *.vim  let g:last_spec = [""]       | let g:next_spec = []
augroup end

"" Quotes
let g:pairs_usr_quote = []
for [key, value] in items(g:pairs_usr_def)
    if key ==# value | let g:pairs_usr_quote += [key] | endif
endfor


" CONSTANT: Quote escape.
let g:pairs_esc_quote = {
    \ "\"": "\\\""
  \ }


" Functions
"" Pairs
function! IsEncompByPair(pair_dict)
    return index(items(a:pair_dict), [Lib_Get_Char(0), Lib_Get_Char(1)]) >= 0
endfunction

function! PairEnter()
    return IsEncompByPair(g:pairs_usr_def) ?
                \ "\<CR>\<ESC>O" :
                \ "\<CR>"
endfunction

function! PairBacks()
    return IsEncompByPair(g:pairs_usr_def) ?
                \ "\<C-g>U\<Right>\<BS>\<BS>" :
                \ "\<BS>"
endfunction

function! PairMates(pair_a)
    return Lib_Is_Word(Lib_Get_Char(1)) ?
                \ a:pair_a :
                \ a:pair_a . g:pairs_usr_def[a:pair_a] .
                    \ repeat("\<C-g>U\<Left>", len(g:pairs_usr_def[a:pair_a]))
endfunction

function! PairClose(pair_b)
    return Lib_Get_Char(1) ==# a:pair_b ?
                \ "\<C-g>U\<Right>" :
                \ a:pair_b
endfunction

function! PairQuote(quote)
    let last_char = Lib_Get_Char(0)
    let next_char = Lib_Get_Char(1)
    let l_is_word = Lib_Is_Word(last_char)
    let n_is_word = Lib_Is_Word(next_char)
    if next_char ==# a:quote && (last_char ==# a:quote || l_is_word)
        return "\<C-g>U\<Right>"
    elseif l_is_word ||
         \ n_is_word ||
         \ index(g:pairs_usr_quote + g:last_spec, last_char) >= 0 ||
         \ index(g:pairs_usr_quote + g:next_spec, next_char) >= 0
        return a:quote
    else
        return a:quote . a:quote . "\<C-g>U\<Left>"
    endif
endfunction

function! PairMkMap(key, fn)
    if a:key ==? "<CR>" || a:key ==? "<BS>"
        let key = ""
    else
        let key = "\"" . Lib_Str_Escape(a:key, g:pairs_esc_quote) . "\""
    endif
    exe 'inoremap <silent> ' . a:key . ' <C-r>=Pair' . a:fn . '(' . key . ')<CR>'
endfunction

"" Surround.
function! SelSurrnd(quote_a, quote_b)
    let [ln_stt, co_stt] = getpos("'<")[1:2]
    let [ln_end, co_end] = getpos("'>")[1:2]
    call setpos('.', [0, ln_end, co_end])
    exe "normal! a" . a:quote_b
    call setpos('.', [0, ln_stt, co_stt])
    exe "normal! i" . a:quote_a
endfunction

function! SurrndMap(key)
    let key = "\"" . Lib_Str_Escape(a:key, g:pairs_esc_quote) . "\", "
    let val = "\"" . Lib_Str_Escape(g:pairs_usr_def[a:key], g:pairs_esc_quote) . "\""
    exe 'vnoremap <silent> <leader>e' . a:key . ' :<C-u>call SelSurrnd(' . key . val . ')<CR>'
endfunction


" Key mapping
"" <CR> could be remapped by other plugin.
for [key, fn] in items(g:pairs_common_map) | call PairMkMap(key, fn) | endfor
augroup pair_type
    autocmd!
    au BufEnter *.el,*.lisp  exe "iunmap '"
    au BufLeave *.el,*.lisp  call PairMkMap("'", "Quote")
    au BufEnter *.xml,*.html call PairMkMap("<", "Mates") | call PairMkMap(">", "Close")
    au BufLeave *.xml,*.html exe 'iunmap <' | exe 'iunmap >'
augroup end

"" Surround; <leader> e* -> e(ncompass)
for item in g:pairs_sur_list | call SurrndMap(item) | endfor

"" Markdown pair & surround
for [key, val] in items(g:pairs_md_map)
    let head = 'noremap <silent> <M-' . val . '> '
    let args = '"' . key . '", "' . g:pairs_usr_def[key] . '"'
    exe 'i' . head . '<C-r>=PairMates("' . key . '")<CR>'
    exe 'v' . head . ':<C-u>call SelSurrnd(' . args . ')<CR>'
endfor
vnoremap <silent> <M-u> :<C-u>call SelSurrnd("<u>", "</u>")<CR>
