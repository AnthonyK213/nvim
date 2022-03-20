let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

nn  <silent> <leader>op :NERDTreeToggle<CR>
nn  <silent> <M-e> :NERDTreeFocus<CR>
ino <silent> <M-e> <Esc>:NERDTreeFocus<CR>
tno <silent> <M-e> <C-\><C-N>:NERDTreeFocus<CR>
