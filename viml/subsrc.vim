" Basics
set showmode
let mapleader = "\<SPACE>"


if !has("nvim")
  set noeb vb t_vb=
endif


" Comments leader
augroup subsrc_comments
  autocmd!
  au BufEnter *.md setlocal fo=ctnqro com=b:>
  au BufEnter *.md exe 'syntax region markdownBlockquote start=/^\s*>/ end=/$/ contains=@Spell'
augroup end


" netrw
let g:netrw_altv = 1
let g:netrw_banner = 0
let g:netrw_winsize = 80
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
nn  <silent> <leader>op :20Lexplore<CR>


" Pairs
"" Directional operation which won't break the history.
let g:subsrc_dir_l = "\<C-g>U\<Left>"
let g:subsrc_dir_d = "\<C-g>U\<Down>"
let g:subsrc_dir_u = "\<C-g>U\<Up>"
let g:subsrc_dir_r = "\<C-g>U\<Right>"

let s:subsrc_pairs_dict = {
      \ "("  : ")",
      \ "["  : "]",
      \ "{"  : "}",
      \ "'"  : "'",
      \ '"'  : '"',
      \ "`"  : "`",
      \ "*"  : "*",
      \ "**" : "**",
      \ "***": "***",
      \ "<u>": "</u>"
      \ }

function! s:subsrc_get_context() abort
  let col = col('.')
  let line = getline('.')
  let back = strpart(line, 0, col - 1)
  let fore = strpart(line, col - 1)
  return {
        \ "b" : back,
        \ "f" : fore,
        \ "p" : empty(back) ? "" : nr2char(strgetchar(back, strchars(back) - 1)),
        \ "n" : empty(fore) ? "" : nr2char(strgetchar(fore, 0))
        \ }
endfunction

function! s:subsrc_is_surrounded(match_list) abort
  let l:context = s:subsrc_get_context()
  return index(a:match_list, l:context["p"] . l:context["n"]) >= 0
endfunction

function! s:subsrc_pairs_backs() abort
  let l:context = s:subsrc_get_context()
  if s:subsrc_is_surrounded(['()', '[]', '{}', '""', "''", "`", '**', '<>'])
    return g:subsrc_dir_r . "\<BS>\<BS>"
  elseif l:context["b"] =~ '\v\{\s$' && l:context["f"] =~ '\v^\s\}'
    return "\<C-\>\<C-O>_diB"
  else
    return "\<BS>"
  end
endfunction

function! s:subsrc_pairs_supbs() abort
  let l:context = s:subsrc_get_context()
  let l:back = l:context["b"]
  let l:fore = l:context["f"]
  if l:back =~ '\v\{\s$' && l:fore =~ '\v^\s\}'
    return "\<C-g>U\<Left>\<C-\>\<C-o>2x"
  endif
  let l:res = [0, 0, 0]
  for [l:key, l:val] in items(s:subsrc_pairs_dict)
    let l:key_esc = '\v' . escape(l:key, ' ()[]{}<>*') . '$'
    let l:val_esc = '\v^' . escape(l:val, ' ()[]{}<>*')
    if l:back =~ l:key_esc && l:fore =~ l:val_esc &&
          \ len(l:key) + len(l:val) > l:res[1] + l:res[2]
      let l:res = [1, len(l:key), len(l:val)]
    endif
  endfor
  if l:res[0]
    return repeat("\<C-G>U\<Left>", l:res[1]) .
          \ "\<C-\>\<C-O>" . (l:res[1] + l:res[2]) . "x"
  elseif l:back =~ '\v\{\s*$' && l:fore =~ '\v^\s*\}'
    return "\<C-\>\<C-O>_diB"
  else
    return "\<C-\>\<C-O>_db"
  endif
endfunction

ino ( ()<C-g>U<Left>
ino [ []<C-g>U<Left>
ino { {}<C-g>U<Left>
ino <expr> ) <SID>subsrc_get_context()['n'] ==# ")" ? g:subsrc_dir_r : ")"
ino <expr> ] <SID>subsrc_get_context()['n'] ==# "]" ? g:subsrc_dir_r : "]"
ino <expr> } <SID>subsrc_get_context()['n'] ==# "}" ? g:subsrc_dir_r : "}"
ino <expr> "
      \ <SID>subsrc_get_context()['n'] ==# "\"" ?
      \ g:subsrc_dir_r : or(<SID>subsrc_get_context()['p'] =~ '\v[\\''"]',
      \ and(<SID>subsrc_get_context()['b'] =~ '\v^\s*$', &filetype == 'vim')) ?
      \ '"' : '""' . g:subsrc_dir_l
ino <expr> '
      \ <SID>subsrc_get_context()['n'] ==# "'" ?
      \ g:subsrc_dir_r : <SID>subsrc_get_context()['p'] =~ '\v[''"]' ?
      \ "'" : "''" . g:subsrc_dir_l
ino <expr> <SPACE>
      \ <SID>subsrc_is_surrounded(['{}']) ?
      \ "\<SPACE>\<SPACE>" . g:subsrc_dir_l : "\<SPACE>"
ino <expr> <BS> <SID>subsrc_pairs_backs()
ino <expr> <M-BS> <SID>subsrc_pairs_supbs()
"" Markdown
ino <expr> <M-P> "``" . g:subsrc_dir_l
ino <expr> <M-I> "**" . g:subsrc_dir_l
ino <expr> <M-B> "****" . repeat(g:subsrc_dir_l, 2)
ino <expr> <M-M> "******" . repeat(g:subsrc_dir_l, 3)
ino <expr> <M-U> "<u></u>" . repeat(g:subsrc_dir_l, 4)


" Completion
ino <silent><expr> <CR>
      \ pumvisible() ? "\<C-y>" :
      \ <SID>subsrc_is_surrounded(['()', '[]', '{}']) ?
      \ "\<CR>\<C-\>\<C-o>O" :
      \ "\<CR>"
ino <silent><expr> <TAB>
      \ or(<SID>subsrc_get_context()['p'] =~ '\v[a-z_\u4e00-\u9fa5]', pumvisible()) ?
      \ "\<C-n>" : <SID>subsrc_get_context()['b'] =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
      \ "\<C-\>\<C-o>>>" . repeat(g:subsrc_dir_r, &ts) : "\<TAB>"
ino <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"


" Navigate windows
for s:direct in ['h', 'j', 'k', 'l', 'w']
  exe 'nn'  '<M-' . s:direct . '>' '<C-W>' . s:direct
  exe 'ino' '<M-' . s:direct . '>' '<ESC><C-W>' . s:direct
  exe 'tno' '<M-' . s:direct . '>' '<C-\><C-N><C-W>' . s:direct
endfor


" Emacs shit
nn  <M-x> :
ino <M-x> <C-\><C-O>:
ino <M-b> <C-\><C-O>b
ino <M-f> <C-\><C-O>e<Right>
nn  <M-b> b
nn  <M-f> e
ino <C-A> <C-\><C-O>g0
ino <C-E> <C-\><C-O>g$
ino <C-K> <C-\><C-O>D
nn  <C-N> gj
nn  <C-P> gk
vn  <C-N> gj
vn  <C-P> gk
ino <C-N> <C-\><C-O>gj
ino <C-P> <C-\><C-O>gk
ino <expr> <C-F> col('.') >= col('$') ? "<C-\><C-O>+" : g:subsrc_dir_r
ino <expr> <C-B> col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:subsrc_dir_l


" Command mode.
cno <C-A>  <C-B>
cno <C-B>  <LEFT>
cno <C-F>  <RIGHT>
cno <C-H>  <C-F>
cno <M-b>  <C-LEFT>
cno <M-f>  <C-RIGHT>
cno <M-BS> <C-W>


" MISC
nn <leader>bc :cd %:p:h<CR>:pwd<CR>
nn <leader>bd :bd<CR>
nn <leader>bg :let &bg = &bg ==# 'dark' ? 'light' : 'dark'<CR>
nn <leader>bh :noh<CR>
nn <leader>bl :ls<CR>
nn <leader>bn :bn<CR>
nn <leader>bp :bp<CR>
nn <leader>ot :term<CR>
