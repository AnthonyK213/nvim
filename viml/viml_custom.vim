" Global variables.
"" Leader key
let g:mapleader = "\<SPACE>"
"" Directories
if !empty(glob(expand('$ONEDRIVE')))
  let g:onedrive_path = expand('$ONEDRIVE')
  let g:usr_desktop = expand(fnamemodify(g:onedrive_path, ':h') . "/Desktop")
else
  let g:onedrive_path = expand('$HOME')
  let g:usr_desktop = expand('$HOME/Desktop')
endif


" Key maps
"" Ctrl
""" Indent entire line.
nn <C-j> V<
nn <C-k> V>
""" Adjust window size.
nn <C-UP>    <C-W>-
nn <C-DOWN>  <C-W>+
nn <C-LEFT>  <C-W>>
nn <C-RIGHT> <C-w><
"" Meta
""" Switch tab
let tab_num = 1
while tab_num <= 10
  let tab_key = tab_num == 10 ? 0 : tab_num
  exe 'nn  <silent> <M-' . tab_key . '>      :tabn' tab_num . '<CR>'
  exe 'ino <silent> <M-' . tab_key . '> <C-o>:tabn' tab_num . '<CR>'
  let tab_num += 1
endwhile
""" Open .vimrc(init.vim)
nn  <M-,> :tabnew $MYVIMRC<CR>
""" Terminal
tno <Esc> <C-\><C-n>
tno <silent> <M-d> <C-\><C-N>:bd!<CR>
""" Navigate
for direct in ['h', 'j', 'k', 'l', 'w']
  exe 'nn  <M-' . direct . '> <C-w>'            . direct
  exe 'ino <M-' . direct . '> <ESC><C-w>'       . direct
  exe 'tno <M-' . direct . '> <C-\><C-n><C-w>'  . direct
endfor
""" Find and replace
nn <M-f> :%s/
vn <M-f> :s/
""" Normal command
nn <M-n> :%normal 
vn <M-n> :normal 
"" Leader
""" Buffer
nn <silent> <leader>bc :lcd %:p:h<CR>
nn <expr><silent> <leader>bd
      \ index(['help','terminal','nofile'], &buftype) >= 0 \|\|
      \ len(getbufinfo({'buflisted':1})) <= 2 ?
      \ ":bd\<CR>" : ":bp\|bd#\<CR>"
nn <silent> <leader>bh :noh<CR>
nn <silent> <leader>bn :bn<CR>
nn <silent> <leader>bp :bp<CR>
""" Toggle spell check
nn <silent> <Leader>cs :setlocal spell! spelllang=en_us<CR>


" Commands
"" Scroll off.
augroup filetype_behave
  autocmd!
  au BufEnter *    setlocal so=5
  au BufEnter *.md setlocal so=999
augroup end
