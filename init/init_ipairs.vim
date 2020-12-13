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
    \ "("   : "mates",
    \ "["   : "mates",
    \ "{"   : "mates",
    \ ")"   : "close",
    \ "]"   : "close",
    \ "}"   : "close",
    \ "'"   : "quote",
    \ "\""  : "quote",
    \ "<CR>": "enter",
    \ "<BS>": "backs"
  \ }
""" Markdown pairs.
let g:pairs_md_map = {
    \ "`"  : "p",
    \ "*"  : "i",
    \ "**" : "b",
    \ "***": "m"
  \ }

"" Pair special quotes.
augroup pairs_special
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


" Functions
"" Get the character around the cursor.
function! s:ipairs_get_char(num) abort
    return matchstr(getline('.'), '\%' . (col('.') + a:num - 1) . 'c.')
endfunction

"" Determines whether a character is a letter or a symbol.
function! s:ipairs_is_word(char)
    let code = char2nr(a:char)
    if code > 128
        return 0
    elseif code >= 48 && code <= 57
        return 1
    elseif code >= 65 && code <= 90
        return 1
    elseif code >= 97 && code <= 122
        return 1
    else
        return 0
    endif
endfunction

"" Replace chars in a string according to a dictionary.
function! s:ipairs_str_escape(str)
    let str_lst = split(a:str, '.\zs')
    let esc_dict = {
        \ "\"": "\\\""
      \ }
    let i = 0
    for char in str_lst
        if has_key(esc_dict, char)
            let str_lst[i] = esc_dict[char]
        endif
        let i = i + 1
    endfor
    return join(str_lst, '')
endfunction

"" Pairs
function! s:ipairs_is_surrounded(pair_dict)
    return index(items(a:pair_dict), [s:ipairs_get_char(0), s:ipairs_get_char(1)]) >= 0
endfunction

function! s:ipairs_enter()
    return s:ipairs_is_surrounded(g:pairs_usr_def) ?
                \ "\<CR>\<ESC>O" :
                \ "\<CR>"
endfunction

function! s:ipairs_backs()
    return s:ipairs_is_surrounded(g:pairs_usr_def) ?
                \ "\<C-g>U\<Right>\<BS>\<BS>" :
                \ "\<BS>"
endfunction

function! s:ipairs_mates(pair_a)
    return s:ipairs_is_word(s:ipairs_get_char(1)) ?
                \ a:pair_a :
                \ a:pair_a . g:pairs_usr_def[a:pair_a] .
                    \ repeat("\<C-g>U\<Left>", len(g:pairs_usr_def[a:pair_a]))
endfunction

function! s:ipairs_close(pair_b)
    return s:ipairs_get_char(1) ==# a:pair_b ?
                \ "\<C-g>U\<Right>" :
                \ a:pair_b
endfunction

function! s:ipairs_quote(quote)
    let last_char = s:ipairs_get_char(0)
    let next_char = s:ipairs_get_char(1)
    let l_is_word = s:ipairs_is_word(last_char)
    let n_is_word = s:ipairs_is_word(next_char)
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

function! s:ipairs_def_map(key, fn)
    if a:key ==? "<CR>" || a:key ==? "<BS>"
        let key = ""
    else
        let key = "\"" . s:ipairs_str_escape(a:key) . "\""
    endif
    exe 'inoremap <silent> ' . a:key . ' <C-r>=<SID>ipairs_' . a:fn . '(' . key . ')<CR>'
endfunction

"" Surround.
function! s:ipairs_surround(quote_a, quote_b)
    let [ln_stt, co_stt] = getpos("'<")[1:2]
    let [ln_end, co_end] = getpos("'>")[1:2]
    call setpos('.', [0, ln_end, co_end])
    exe "normal! a" . a:quote_b
    call setpos('.', [0, ln_stt, co_stt])
    exe "normal! i" . a:quote_a
endfunction

function! s:ipairs_sur_def_map(key)
    let key = "\"" . s:ipairs_str_escape(a:key) . "\", "
    let val = "\"" . s:ipairs_str_escape(g:pairs_usr_def[a:key]) . "\""
    exe 'vnoremap <silent> <leader>e' . a:key . ' :<C-u>call <SID>ipairs_surround(' . key . val . ')<CR>'
endfunction


" Key maps
"" <CR> could be remapped by other plugin.
for [key, fn] in items(g:pairs_common_map) | call s:ipairs_def_map(key, fn) | endfor
augroup pairs_filetype
    autocmd!
    au BufEnter *.el,*.lisp  exe "iunmap '"
    au BufLeave *.el,*.lisp  call s:ipairs_def_map("'", "Quote")
    au BufEnter *.xml,*.html call s:ipairs_def_map("<", "Mates") | call s:ipairs_def_map(">", "Close")
    au BufLeave *.xml,*.html exe 'iunmap <' | exe 'iunmap >'
augroup end

"" Surround; <leader> e* -> e(ncompass)
for item in g:pairs_sur_list | call s:ipairs_sur_def_map(item) | endfor

"" Markdown pair & surround
for [key, val] in items(g:pairs_md_map)
    let head = 'noremap <silent> <M-' . val . '> '
    let args = '"' . key . '", "' . g:pairs_usr_def[key] . '"'
    exe 'i' . head . '<C-r>=<SID>ipairs_mates("' . key . '")<CR>'
    exe 'v' . head . ':<C-u>call <SID>ipairs_surround(' . args . ')<CR>'
endfor
vnoremap <silent> <M-u> :<C-u>call s:ipairs_surround("<u>", "</u>")<CR>
