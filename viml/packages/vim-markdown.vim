let g:vim_markdown_math = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_autowrite = 1
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 2

nn <silent> <leader>mh :Toch<CR>:resize 15<CR>
nn <silent> <leader>mm :call my#compat#vim_markdown_math_toggle()<CR>
