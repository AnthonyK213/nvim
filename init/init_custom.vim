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


" Filetype behave
augroup filetype_behave
    autocmd!
    au BufEnter * setlocal so=5
    au BufEnter *.md,*.org,*.yml setlocal ts=2 sw=2 sts=2 so=999 nowrap nolinebreak
    au BufEnter *.cs,*.pde,*.tex,*.java,*.lisp,*.vim setlocal ts=2 sw=2 sts=2
augroup end


" Key maps
"" Ctrl
""" Moving cursor like emacs
for [key, val] in items({"n":"j", "p":"k"})
    exe 'nnoremap <C-' . key . '> g' . val
    exe 'vnoremap <C-' . key . '> g' . val
    exe 'inoremap <silent> <C-' . key . '> <C-o>g' . val
endfor
inoremap <silent> <C-a> <C-o>g0
inoremap <silent> <C-e> <C-o>g$
inoremap <silent><expr> <C-f> col('.') >= col('$') ? "\<C-o>+" : "\<Right>"
inoremap <silent><expr> <C-b> col('.') == 1 ? "\<C-o>-\<C-o>$" : "\<Left>"
"" Meta
""" Emacs command line
inoremap <M-x> <C-o>:
nnoremap <M-x> :
""" Open .vimrc(init.vim)
nnoremap <M-,> :tabnew $MYVIMRC<CR>
""" Terminal
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <M-d> <C-\><C-N>:q<CR>
""" Navigate
for direct in ['h', 'j', 'k', 'l', 'w']
    exe 'nnoremap <M-' . direct . '> <C-w>'            . direct
    exe 'inoremap <M-' . direct . '> <ESC><C-w>'       . direct
    exe 'tnoremap <M-' . direct . '> <C-\><C-n><C-w>'  . direct
endfor
"" Leader
""" Buffer
nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>
nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>cd :lcd %:p:h<CR>
""" Highlight off
nnoremap <silent> <leader>nh :noh<CR>
""" Spell check; <leader> s* -> s(pell)
nnoremap <silent> <leader>se :set nospell<CR>
nnoremap <silent> <leader>ss :set spell spelllang=en_us<CR>
