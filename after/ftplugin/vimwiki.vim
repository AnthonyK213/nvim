setlocal textwidth=0 nowrap nolinebreak
let b:table_mode_corner = '|'
let b:presenting_slide_separator = '\v(^|\n)\ze#{1,2}[^#]'

nnoremap <buffer><silent> <TAB>   za
nnoremap <buffer><silent> <S-TAB> zA
nnoremap <buffer><silent> <F5> <Cmd>PresentingStart<CR>
nnoremap <buffer><silent> <leader>mt <Cmd>MarkdownPreviewToggle<CR>
