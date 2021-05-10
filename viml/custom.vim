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
"" OS
if has("win32")
  let g:python3_host_prog = get(g:, 'python3_exec_path', $HOME . '/Appdata/Local/Programs/Python/Python38/python.EXE')
  set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
  set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
  set wildignore+=*.pyc
  set wildignore+=*.DS_Store
  set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz
elseif has("unix")
  let g:python3_host_prog = get(g:, 'python3_exec_path', '/usr/bin/python3')
  set wildignore+=*.so
endif


" Key maps
"" Ctrl
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
  exe 'nn  <silent> <M-' . tab_key . '>           :tabn' tab_num . '<CR>'
  exe 'ino <silent> <M-' . tab_key . '> <C-\><C-O>:tabn' tab_num . '<CR>'
  let tab_num += 1
endwhile
""" Open .vimrc(init.vim)
nn <expr><silent> <M-,> (expand("%:t") == '' ? ":e $MYVIMRC<CR>" : ":tabnew $MYVIMRC<CR>") . ":cd %:p:h<CR>"
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
      \ index(['help','terminal','nofile', 'quickfix'], &buftype) >= 0 \|\|
      \ len(getbufinfo({'buflisted':1})) <= 2 ?
      \ ":bd<CR>" : ":bp\|bd#<CR>"
nn <silent> <leader>bh :noh<CR>
nn <silent> <leader>bn :bn<CR>
nn <silent> <leader>bp :bp<CR>
""" Toggle spell check
nn <silent> <Leader>cs :setlocal spell! spelllang=en_us<CR>


" Scroll off
augroup scroll_off
  autocmd!
  au BufEnter * setlocal so=5
  au BufEnter *.md setlocal so=999
augroup end
