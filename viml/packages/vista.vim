let g:vista_default_executive = g:_my_use_coc ? "coc" : "vim_lsp"
let g:vista_executive_for = {
      \ 'markdown': 'toc',
      \ 'vimwiki': 'markdown'
      \ }

nn <silent> <leader>fa :Clap tags<CR>
nn <silent> <leader>mv :Vista!!<CR>
