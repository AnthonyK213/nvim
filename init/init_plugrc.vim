" Onedark
colorscheme onedark
let g:airline_theme = 'onedark'


" NERDTree
augroup nerdtree_behave
  autocmd!
  " Open NERDTree automatically when vim starts up on opening a directory
  autocmd StdinReadPre * let s:std_in = 1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
  " Close vim if the only window left open is a NERDTree
  "autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup end
let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nnoremap <silent> <F3> :NERDTreeToggle<CR>
inoremap <silent> <F3> <Esc>:NERDTreeToggle<CR>
tnoremap <silent> <F3> <C-\><C-N>:NERDTreeToggle<CR>
nnoremap <silent> <M-n> :NERDTreeFocus<CR>
inoremap <silent> <M-n> <Esc>:NERDTreeFocus<CR>
tnoremap <silent> <M-n> <C-\><C-N>:NERDTreeFocus<CR>


" signify
"" Signs
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '~'
"" Disable the numbers disctracting
let g:signify_sign_show_count = 0
let g:signify_sign_show_text  = 1
"" <leader> h* -> h(unk)
nmap <leader>hj <plug>(signify-next-hunk)
nmap <leader>hk <plug>(signify-prev-hunk)
nmap <leader>hJ 9999<plug>(signify-next-hunk)
nmap <leader>hK 9999<plug>(signify-prev-hunk)
nnoremap <silent> <leader>ht :SignifyToggle<CR>


" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled  = 1
"" Symbols
let g:airline_symbols = {}
let g:airline_symbols.branch = ''
"" Mode abbr.
let g:airline_mode_map = {
      \ '__'    : '-',
      \ 'c'     : 'C',
      \ 'i'     : 'I',
      \ 'ic'    : 'I',
      \ 'ix'    : 'I',
      \ 'n'     : 'N',
      \ 'multi' : 'M',
      \ 'ni'    : 'Ĩ',
      \ 'no'    : 'N',
      \ 'R'     : 'R',
      \ 'Rv'    : 'R',
      \ 's'     : 'S',
      \ 'S'     : 'S',
      \ ''    : 'S',
      \ 't'     : 'T',
      \ 'v'     : 'V',
      \ 'V'     : 'Ṿ',
      \ ''    : 'Ṽ',
      \ }
"" Separators
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
"" Tab
let g:airline#extensions#tabline#formatter = 'unique_tail'


" vim-markdown
let g:vim_markdown_math = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 2
"" <leader> m* -> m(arkdown)
nnoremap <silent> <leader>mh :Toch<CR>:resize 15<CR>
nnoremap <silent> <leader>mv :Tocv<CR>:vertical resize 50<CR>


" markdown preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_preview_options = {
      \ 'mkit': {},
      \ 'katex': {},
      \ 'uml': {},
      \ 'maid': {},
      \ 'disable_sync_scroll': 0,
      \ 'sync_scroll_type': 'middle',
      \ 'hide_yaml_meta': 1,
      \ 'sequence_diagrams': {},
      \ 'flowchart_diagrams': {},
      \ 'content_editable': v:false
      \ }


" vim-table-mode
augroup vimtable
  autocmd!
  au BufEnter *    let g:table_mode_corner = '+'
  au BufEnter *.md let g:table_mode_corner = '|'
augroup end
"" <leader> t* -> t(able-mode)
nnoremap <silent> <leader>ta :TableAddFormula<CR>
nnoremap <silent> <leader>tf :TableModeRealign<CR>
nnoremap <silent> <leader>tc :TableEvalFormulaLine<CR>


" vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_general_viewer = 'SumatraPDF'
let g:vimtex_view_general_options
      \ = '-reuse-instance -forward-search @tex @line @pdf'
let g:vimtex_view_general_options_latexmk = '-reuse-instance'
let g:vimtex_compiler_progname = 'nvr'


" vim-orgmode
"let g:org_indent=2
let agenda_path = expand(g:onedrive_path . "/Documents/Agenda/Agenda.org")
let g:org_agenda_files = [agenda_path]
command! OrgAgenda :exe ":tabnew " . agenda_path


" IndentLine
let g:indentLine_char = '¦'
let g:indentLine_setConceal = 1
augroup indentline
  autocmd!
  au BufEnter,BufRead * let g:indentLine_enabled = 1
  au BufEnter,BufRead *.md,*.org,*.json,*.txt,*.tex let g:indentLine_enabled = 0
augroup end


" vim-ipairs
let g:pairs_map_ret = 0
let g:pairs_map_bak = 1
let g:pairs_usr_extd = {
      \ "$"  : "$",
      \ "`"  : "`",
      \ "*"  : "*",
      \ "**" : "**",
      \ "***": "***",
      \ "<u>": "</u>"
      \ }
let g:pairs_usr_extd_map = {
      \ "<M-p>" : "`",
      \ "<M-i>" : "*",
      \ "<M-b>" : "**",
      \ "<M-m>" : "***",
      \ "<M-u>" : "<u>"
      \ }
