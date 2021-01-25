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
