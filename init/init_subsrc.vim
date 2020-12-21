" Basics
set showmode
set completeopt=longest,menuone


" Comments leader
augroup subsrc_comments
  autocmd!
  au BufEnter *.md setlocal fo=ctnqro com=b:*,b:+,b:-,b:>
  au BufEnter *.md exe 'syntax region markdownBlockquote start=/^\s*>/ end=/$/ contains=@Spell'
augroup end


" netrw
let g:netrw_altv = 1
let g:netrw_banner = 0
let g:netrw_winsize = 80
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
nnoremap <silent> <F3> :20Lexplore<CR>
inoremap <silent> <F3> <ESC>:20Lexplore<CR>
tnoremap <silent> <F3> <C-\><C-N>:20Lexplore<CR>


" Pairs
function! s:subrc_is_surrounded(match_list)
  return index(a:match_list, Lib_Get_Char(0) . Lib_Get_Char(1)) >= 0
endfunction

let g:subsrc_left  = "\<C-g>U\<Left>"
let g:subsrc_right = "\<C-g>U\<Right>"

inoremap ( ()<C-g>U<Left>
inoremap [ []<C-g>U<Left>
inoremap { {}<C-g>U<Left>
inoremap <expr> )
      \ Lib_Get_Char(1) ==# ")" ?
      \ g:subsrc_right : ")"
inoremap <expr> ]
      \ Lib_Get_Char(1) ==# "]" ?
      \ g:subsrc_right : "]"
inoremap <expr> }
      \ Lib_Get_Char(1) ==# "}" ?
      \ g:subsrc_right : "}"
inoremap <expr> "
      \ Lib_Get_Char(1) ==# "\"" ?
      \ g:subsrc_right :
      \ or(Lib_Get_Char(0) =~ '\v[\\''"]', col('.') == 1) ?
      \ "\"" :
      \ "\"\"" . g:subsrc_left
inoremap <expr> '
      \ Lib_Get_Char(1) ==# "'" ?
      \ g:subsrc_right :
      \ Lib_Get_Char(0) =~ '\v[''"]' ?
      \ "'" :
      \ "''" . g:subsrc_left
inoremap <expr> <SPACE>
      \ Lib_Get_Char(0) . Lib_Get_Char(1) == "{}" ?
      \ "\<SPACE>\<SPACE>" . g:subsrc_left :
      \ "\<SPACE>"
inoremap <expr> <BS>
      \ <SID>subrc_is_surrounded(["()", "[]", "{}", "''", '""', '**', '``']) ?
      \ g:subsrc_right . "\<BS>\<BS>" :
      \ "\<BS>"
inoremap <expr> <M-p> "``" . g:subsrc_left
inoremap <expr> <M-i> "**" . g:subsrc_left
inoremap <expr> <M-b> "****" . repeat(g:subsrc_left, 2)
inoremap <expr> <M-m> "******" . repeat(g:subsrc_left, 3)
inoremap <expr> <M-u> "<u></u>" . repeat(g:subsrc_left, 4)


" Completion
inoremap <expr> <TAB>
      \ Lib_Get_Char(0) =~ '\v[a-z_\u4e00-\u9fa5]' ?
      \ "\<C-N>" :
      \ "\<Tab>"
inoremap <expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-p>" :
      \ "\<C-h>"
inoremap <expr> <CR>
      \ pumvisible() ? "\<C-y>" :
      \ <SID>subrc_is_surrounded(["()", "[]", "{}"]) ?
      \ "\<CR>\<ESC>O" :
      \ "\<CR>"
