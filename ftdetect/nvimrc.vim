augroup nvimrc_ftdetect
  autocmd!
  au BufRead,BufNewFile .nvimrc set filetype=json
  au BufRead,BufNewFile _nvimrc set filetype=json
augroup END
