""" Basics
set showmode
set completeopt=longest,menuone


""" netrw
let g:netrw_altv = 1
let g:netrw_banner = 0
let g:netrw_winsize = 85
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
nnoremap <silent> <F3> :15Lexplore<CR>
inoremap <silent> <F3> <ESC>:15Lexplore<CR>
tnoremap <silent> <F3> <C-\><C-N>:15Lexplore<CR>


""" Completion
inoremap <silent><expr> <Tab>
            \ or(Lib_Is_Letter(Lib_Get_Char(0)), Lib_Is_Hanzi(Lib_Get_Char(0))) ?
            \ "\<C-N>" :
            \ "\<Tab>"
inoremap <silent><expr> <S-TAB>
            \ pumvisible() ?
            \ "\<C-p>" :
            \ "\<C-h>"
inoremap <silent><expr> <CR>
            \ pumvisible() ? "\<C-y>" :
            \ index(["()", "[]", "{}"], Lib_Get_Char(0) . Lib_Get_Char(1)) >= 0 ?
                \ "\<CR>\<ESC>O" :
                \ "\<CR>"


"" {<space>cursor<space>}
inoremap <silent><expr> <space>
            \ [Lib_Get_Char(0), Lib_Get_Char(1)] == ["{", "}"] ?
            \ "\<space>\<space>\<Left>" :
            \ "\<space>"
