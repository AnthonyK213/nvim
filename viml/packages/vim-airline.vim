set showtabline=2

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled  = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_symbols = {}
let g:airline_symbols.branch = "\uE0A0"
let g:airline_mode_map = {
      \ '__'    : '-',
      \ 'c'     : 'C',
      \ 'i'     : 'I',
      \ 'ic'    : 'I',
      \ 'ix'    : 'I',
      \ 'n'     : 'N',
      \ 'multi' : 'M',
      \ 'niI'   : 'Ĩ',
      \ 'no'    : 'N',
      \ 'R'     : 'R',
      \ 'Rv'    : 'R',
      \ 's'     : 's',
      \ 'S'     : 'S',
      \ ''    : 'S',
      \ 't'     : 'T',
      \ 'v'     : 'v',
      \ 'V'     : 'V',
      \ ''    : 'B',
      \ }
