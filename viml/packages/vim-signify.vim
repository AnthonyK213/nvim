let g:signify_sign_add = '+'
let g:signify_sign_delete = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change = '~'
let g:signify_sign_show_count = 0
let g:signify_sign_show_text  = 1

nmap <silent> <leader>gj <plug>(signify-next-hunk)
nmap <silent> <leader>gk <plug>(signify-prev-hunk)
nmap <silent> <leader>gJ 9999<plug>(signify-next-hunk)
nmap <silent> <leader>gK 9999<plug>(signify-prev-hunk)
