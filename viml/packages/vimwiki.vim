let g:vimwiki_list = [{
      \ 'path' : expand(g:_my_path_cloud . '/Notes/'),
      \ 'path_html' : expand(g:_my_path_cloud . '/Notes/html/'),
      \ 'syntax' : 'markdown',
      \ 'ext' : '.markdown'
      \ }]
let g:vimwiki_folding = 'syntax'
let g:vimwiki_ext2syntax = { '.markdown' : 'markdown' }
