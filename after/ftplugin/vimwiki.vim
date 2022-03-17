setlocal textwidth=0 nowrap nolinebreak
let b:table_mode_corner = '|'
let b:presenting_slide_separator = '\v(^|\n)\ze#{1,2}[^#]'

call usr#misc#md_kbd()
nnoremap <buffer><silent> <TAB>   za
nnoremap <buffer><silent> <S-TAB> zA
