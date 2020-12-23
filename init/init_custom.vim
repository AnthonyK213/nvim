" Global variables.
"" Leader key
let g:mapleader = "\<Space>"
"" Directories
if !empty(glob(expand('$ONEDRIVE')))
  let g:onedrive_path = expand('$ONEDRIVE')
  let g:usr_desktop = expand(fnamemodify(g:onedrive_path, ':h') . "/Desktop")
else
  let g:onedrive_path = expand('$HOME')
  let g:usr_desktop = expand('$HOME/Desktop')
endif
"" Directional operation which won't mess up the history.
let g:custom_l = "\<C-g>U\<Left>"
let g:custom_d = "\<C-g>U\<Down>"
let g:custom_u = "\<C-g>U\<Up>"
let g:custom_r = "\<C-g>U\<Right>"


" Filetype behave
augroup filetype_behave
  autocmd!
  au BufEnter * setlocal so=5
  au BufEnter *.md,*.org,*.yml setlocal ts=2 sw=2 sts=2 so=999 nowrap nolinebreak
  au BufEnter *.cs,*.pde,*.tex,*.java,*.lisp,*.vim setlocal ts=2 sw=2 sts=2
augroup end


" Key maps
"" Ctrl
""" Emacs flavor in insert mode.
for [key, val] in items({"n":"j", "p":"k"})
  exe 'nnoremap <C-' . key . '> g' . val
  exe 'vnoremap <C-' . key . '> g' . val
  exe 'inoremap <silent> <C-' . key . '> <C-o>g' . val
endfor
ino <silent> <C-a> <C-o>g0
ino <silent> <C-e> <C-o>g$
ino <silent><expr> <C-k> col('.') >= col('$') ? "" : "\<C-o>D"
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-o>+" : g:custom_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-o>-\<C-o>$" : g:custom_l
"" Meta
""" Emacs command line
nn  <M-x> :
ino <M-x> <C-o>:
ino <silent><expr> <M-d> col('.') >= col('$') ? "" : "\<C-o>dw"
""" Switch tab
let tab_num = 1
while tab_num <= 10
  let tab_key = tab_num == 10 ? 0 : tab_num
  exe 'nn  <silent> <M-' . tab_key . '>      :tabn ' . tab_num . '<CR>'
  exe 'ino <silent> <M-' . tab_key . '> <C-o>:tabn ' . tab_num . '<CR>'
  let tab_num += 1
endwhile
""" Open .vimrc(init.vim)
nn  <M-,> :tabnew $MYVIMRC<CR>
""" Terminal
tno <Esc> <C-\><C-n>
tno <silent> <M-d> <C-\><C-N>:bd!<CR>
""" Navigate
for direct in ['h', 'j', 'k', 'l', 'w']
  exe 'nnoremap <M-' . direct . '> <C-w>'            . direct
  exe 'inoremap <M-' . direct . '> <ESC><C-w>'       . direct
  exe 'tnoremap <M-' . direct . '> <C-\><C-n><C-w>'  . direct
endfor
nn <C-UP>    <C-W>-
nn <C-DOWN>  <C-W>+
nn <C-LEFT>  <C-W>>
nn <C-RIGHT> <C-w><
"" Leader
""" Buffer
nn <silent> <leader>bn :bn<CR>
nn <silent> <leader>bp :bp<CR>
nn <silent> <leader>bd :bd<CR>
nn <silent> <leader>cd :lcd %:p:h<CR>
""" Highlight off
nn <silent> <leader>nh :noh<CR>
""" Toggle spell check; <leader>sc -> s(pell)c(heck)
nn <silent> <Leader>sc :setlocal spell! spelllang=en_us<CR>
