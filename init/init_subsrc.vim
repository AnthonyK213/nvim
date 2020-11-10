""" Basics
set showmode
set completeopt=longest,menuone


""" netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 85
let g:netrw_altv = 1
nnoremap <silent> <F3> :15Lexplore<CR>
inoremap <silent> <F3> <ESC>:15Lexplore<CR>
tnoremap <silent> <F3> <C-\><C-N>:15Lexplore<CR>


""" Completion
inoremap <silent><expr> <CR>    pumvisible() ? "\<C-y>" : Pair_Enter()
inoremap <silent><expr> <TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
