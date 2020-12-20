" Basics
set showmode
set completeopt=longest,menuone


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

inoremap ( ()<C-g>U<Left>
inoremap [ []<C-g>U<Left>
inoremap { {}<C-g>U<Left>
inoremap <expr> )
      \ Lib_Get_Char(1) ==# ")" ?
      \ "\<C-g>U\<Right>" : ")"
inoremap <expr> ]
      \ Lib_Get_Char(1) ==# "]" ?
      \ "\<C-g>U\<Right>" : "]"
inoremap <expr> }
      \ Lib_Get_Char(1) ==# "}" ?
      \ "\<C-g>U\<Right>" : "}"
inoremap <expr> "
      \ Lib_Get_Char(1) ==# "\"" ?
      \ "\<C-g>U\<Right>" :
      \ or(Lib_Get_Char(0) =~ '\v[\\''"]', col('.') == 1) ?
      \ "\"" :
      \ "\"\"\<C-g>U\<Left>"
inoremap <expr> '
      \ Lib_Get_Char(1) ==# "'" ?
      \ "\<C-g>U\<Right>" :
      \ Lib_Get_Char(0) =~ '\v[''"]' ?
      \ "'" :
      \ "''\<C-g>U\<Left>"
inoremap <expr> <SPACE>
      \ Lib_Get_Char(0) . Lib_Get_Char(1) == "{}" ?
      \ "\<space>\<space>\<Left>" :
      \ "\<space>"
inoremap <expr> <BS>
      \ <SID>subrc_is_surrounded(["()", "[]", "{}", "''", '""']) ?
      \ "\<C-g>U\<Right>\<BS>\<BS>" :
      \ "\<BS>"


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
