" vim-one
"" Default markdown theme sucks.
"" vim-markdown should be installed.
function! s:plugrc_mkd()
  call one#highlight('mkdBold',       '4b5263', '', '')
  call one#highlight('mkdItalic',     '4b5263', '', '')
  call one#highlight('mkdBoldItalic', '4b5263', '', '')
  call one#highlight('htmlBold',      'd19a66', '', 'bold')
  call one#highlight('htmlItalic',    'c678dd', '', 'italic')
  call one#highlight('htmlBoldItalic','e5c07b', '', 'bold,italic')
endfunction
"" When colorscheme changes.
augroup vim_one_mkd
  autocmd!
  au ColorScheme one call s:plugrc_mkd()
augroup end
"" Set colorscheme
set tgc
set bg=dark
let g:one_allow_italics = 1
colorscheme one
let g:airline_theme = 'one'


" NERDTree
"" Open NERDTree automatically when vim starts up on opening a directory
function! s:plugrc_nerdtree_start()
  if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in")
    exe 'NERDTree' argv()[0]
    wincmd p
    ene
    exe 'cd '.argv()[0]
  endif
endfunction
augroup nerdtree_behave
  autocmd!
  autocmd StdinReadPre * let s:std_in = 1
  autocmd VimEnter * call s:plugrc_nerdtree_start()
augroup end


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
"" Tab
let g:airline#extensions#tabline#formatter = 'unique_tail'


" markdown preview
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


" vim-orgmode
let agenda_path = expand(g:onedrive_path . "/Documents/Agenda/Agenda.org")
let g:org_agenda_files = [agenda_path]
command! OrgAgenda :exe ":tabnew" agenda_path


" IndentLine
augroup indentline
  autocmd!
  au BufEnter,BufRead * let g:indentLine_enabled = 1
  au BufEnter,BufRead *.md,*.org,*.json,*.txt,*.tex let g:indentLine_enabled = 0
augroup end


" vim-ipairs
let g:pairs_usr_extd = {
      \ "$"  : "$",
      \ "`"  : "`",
      \ "*"  : "*",
      \ "**" : "**",
      \ "***": "***",
      \ "<u>": "</u>"
      \ }
let g:pairs_usr_extd_map = {
      \ "<M-P>" : "`",
      \ "<M-I>" : "*",
      \ "<M-B>" : "**",
      \ "<M-M>" : "***",
      \ "<M-U>" : "<u>"
      \ }


" completion_nvim
imap <expr> <CR>
      \ pumvisible() ? complete_info()["selected"] != "-1" ?
      \ "\<Plug>(completion_confirm_completion)" : "\<c-e>\<CR>" :
      \ "\<Plug>(ipairs_enter)"


" LSP
function! s:plugrc_show_documentation()
  if index(['vim','help'], &filetype) >= 0
    execute 'h '.expand('<cword>')
  else 
  "elseif luaeval('#vim.lsp.buf_get_clients(0)') > 0
    lua vim.lsp.buf.hover()
  "else
  "  execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
"" Code navigation shortcuts
nn <silent> K          <cmd>call <SID>plugrc_show_documentation()<CR>
nn <silent> <leader>g0 <cmd>lua vim.lsp.buf.document_symbol()<CR>
nn <silent> <leader>ga <cmd>lua vim.lsp.buf.code_action()<CR>
nn <silent> <leader>gd <cmd>lua vim.lsp.buf.declaration()<CR>
nn <silent> <leader>gf <cmd>lua vim.lsp.buf.definition()<CR>
nn <silent> <leader>gh <cmd>lua vim.lsp.buf.signature_help()<CR>
nn <silent> <leader>gi <cmd>lua vim.lsp.buf.implementation()<CR>
nn <silent> <leader>gr <cmd>lua vim.lsp.buf.references()<CR>
nn <silent> <leader>gt <cmd>lua vim.lsp.buf.type_definition()<CR>
nn <silent> <leader>gw <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
"" Goto previous/next diagnostic warning/error
nn <silent> <leader>g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nn <silent> <leader>g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
"" Show diagnostic popup on cursor hold
augroup lsp_diagnositic_on_hold
  autocmd!
  au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
augroup end
