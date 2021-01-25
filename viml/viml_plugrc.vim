" vim-one
packadd vim-one
function! s:plugrc_one_extend()
  call one#highlight('Constant',         'd19a66', '', '')
  call one#highlight('SpellBad',         'e06c75', '', 'underline')
  call one#highlight('SpellCap',         'd19a66', '', 'underline')
  call one#highlight('mkdBold',          '4b5263', '', '')
  call one#highlight('mkdItalic',        '4b5263', '', '')
  call one#highlight('mkdBoldItalic',    '4b5263', '', '')
  call one#highlight('mkdCodeDelimiter', '4b5263', '', '')
  call one#highlight('htmlBold',         'd19a66', '', 'bold')
  call one#highlight('htmlItalic',       'c678dd', '', 'italic')
  call one#highlight('htmlBoldItalic',   'e5c07b', '', 'bold,italic')
endfunction
"" When colorscheme changes.
augroup vim_one_extend
  autocmd!
  au ColorScheme one call s:plugrc_one_extend()
augroup end


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


" vim-table-mode
augroup vim_table_mode_style
  autocmd!
  au BufEnter *    let g:table_mode_corner = '+'
  au BufEnter *.md let g:table_mode_corner = '|'
augroup end


" IndentLine
augroup indentLine
  autocmd!
  au BufEnter,BufRead * let g:indentLine_enabled = 1
  au BufEnter,BufRead *.md,*.org,*.json,*.txt,*.tex let g:indentLine_enabled = 0
augroup end


" completion_nvim
augroup completion_nvim_enable_all
  autocmd!
  au BufEnter * lua require'completion'.on_attach()
augroup end
imap <expr> <CR>
      \ pumvisible() ? complete_info()["selected"] != "-1" ?
      \ "\<Plug>(completion_confirm_completion)" : "\<c-e>\<CR>" :
      \ "\<Plug>(ipairs_enter)"
imap <silent><expr> <TAB>
      \ Lib_Get_Char('b') =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
      \ "\<C-o>V>" . repeat(lib_const_r, &ts) :
      \ "\<Plug>(completion_smart_tab)"
imap <S-Tab> <Plug>(completion_smart_s_tab)
imap <C-J>   <Plug>(completion_next_source)
imap <C-K>   <Plug>(completion_prev_source)


" LSP
function! s:plugrc_show_documentation()
  if index(['vim','help'], &filetype) >= 0
    execute 'h '.expand('<cword>')
  else 
    lua vim.lsp.buf.hover()
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
