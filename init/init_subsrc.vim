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
nn  <silent> <F3> :20Lexplore<CR>
ino <silent> <F3> <ESC>:20Lexplore<CR>
tno <silent> <F3> <C-\><C-N>:20Lexplore<CR>


" Pairs
function! s:subrc_is_surrounded(match_list)
  return index(a:match_list, Lib_Get_Char(0) . Lib_Get_Char(1)) >= 0
endfunction

ino ( ()<C-g>U<Left>
ino [ []<C-g>U<Left>
ino { {}<C-g>U<Left>
ino <expr> )
      \ Lib_Get_Char(1) ==# ")" ?
      \ g:custom_r : ")"
ino <expr> ]
      \ Lib_Get_Char(1) ==# "]" ?
      \ g:custom_r : "]"
ino <expr> }
      \ Lib_Get_Char(1) ==# "}" ?
      \ g:custom_r : "}"
ino <expr> "
      \ Lib_Get_Char(1) ==# "\"" ?
      \ g:custom_r :
      \ or(Lib_Get_Char(0) =~ '\v[\\''"]', col('.') == 1) ?
      \ "\"" :
      \ "\"\"" . g:custom_l
ino <expr> '
      \ Lib_Get_Char(1) ==# "'" ?
      \ g:custom_r :
      \ Lib_Get_Char(0) =~ '\v[''"]' ?
      \ "'" :
      \ "''" . g:custom_l
ino <expr> <SPACE>
      \ Lib_Get_Char(0) . Lib_Get_Char(1) == "{}" ?
      \ "\<SPACE>\<SPACE>" . g:custom_l :
      \ "\<SPACE>"
ino <expr> <BS>
      \ <SID>subrc_is_surrounded(["()", "[]", "{}", "''", '""', '**', '``', "<>", "$$"]) ?
      \ g:custom_r . "\<BS>\<BS>" :
      \ "\<BS>"
"" Markdown
ino <expr> <M-p> "``" . g:custom_l
ino <expr> <M-i> "**" . g:custom_l
ino <expr> <M-b> "****" . repeat(g:custom_l, 2)
ino <expr> <M-m> "******" . repeat(g:custom_l, 3)
ino <expr> <M-u> "<u></u>" . repeat(g:custom_l, 4)


" Completion
ino <expr> <TAB>
      \ Lib_Get_Char(0) =~ '\v[a-z_\u4e00-\u9fa5]' ?
      \ "\<C-N>" :
      \ "\<Tab>"
ino <expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-p>" :
      \ "\<C-h>"
ino <expr> <CR>
      \ pumvisible() ? "\<C-y>" :
      \ <SID>subrc_is_surrounded(["()", "[]", "{}"]) ?
      \ "\<CR>\<ESC>O" :
      \ "\<CR>"
