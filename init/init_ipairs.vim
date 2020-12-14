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
let g:pairs_is_word = 'a-z_\u4e00-\u9fa5'
augroup pairs_special
    autocmd!
    au BufEnter *      let g:last_spec = '"''\\'   | let g:next_spec = '"'''
    au BufEnter *.rs   let g:last_spec = '"''\\&<' | let g:next_spec = '"'''
    au BufEnter *.vim  let g:last_spec = '"''\\'   | let g:next_spec = '"'''
augroup end


" Functions
function! s:ipairs_reg(str) 
    return '[' . a:str . ']' 
endfunction

"" Get the character around the cursor.
let g:pairs_context = {
    \ 'l' : ['.\%',   'c'],
    \ 'n' : ['\%',   'c.'],
    \ 'b' : ['^.*\%', 'c'],
    \ 'f' : ['\%', 'c.*$']
  \ }
function! g:pairs_context.impl(arg) abort
    return matchstr(getline('.'), self[a:arg][0] . col('.') . self[a:arg][1])
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
    return index(items(a:pair_dict), [g:pairs_context.impl('l'), g:pairs_context.impl('n')]) >= 0
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
    return g:pairs_context.impl('n') =~ s:ipairs_reg(g:pairs_is_word) ?
                \ a:pair_a :
                \ a:pair_a . g:pairs_usr_def[a:pair_a] .
                    \ repeat("\<C-g>U\<Left>", len(g:pairs_usr_def[a:pair_a]))
endfunction

function! s:ipairs_close(pair_b)
    return g:pairs_context.impl('n') ==# a:pair_b ?
                \ "\<C-g>U\<Right>" :
                \ a:pair_b
endfunction

function! s:ipairs_quote(quote)
    let last_char = g:pairs_context.impl('l')
    let next_char = g:pairs_context.impl('n')
    if next_char ==# a:quote &&
       \ (last_char ==# a:quote || last_char =~ s:ipairs_reg(g:pairs_is_word))
        return "\<C-g>U\<Right>"
    elseif last_char =~ s:ipairs_reg(g:pairs_is_word . g:last_spec) ||
         \ next_char =~ s:ipairs_reg(g:pairs_is_word . g:next_spec)
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
    exe 'inoremap <silent><expr> ' . a:key . ' <SID>ipairs_' . a:fn . '(' . key . ')'
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
    au BufLeave *.el,*.lisp  call <SID>ipairs_def_map("'", "quote")
    au BufEnter *.xml,*.html call <SID>ipairs_def_map("<", "mates") | call <SID>ipairs_def_map(">", "close")
    au BufLeave *.xml,*.html exe 'inoremap < <' | exe 'inoremap > >'
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
vnoremap <silent> <M-u> :<C-u>call <SID>ipairs_surround("<u>", "</u>")<CR>
