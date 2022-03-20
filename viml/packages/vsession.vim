let g:vsession_path = stdpath('data') . '/sessions'
let g:vsession_save_last_on_leave = 0

function! s:save_session() abort
  let l:file = getcwd()
  let l:file = substitute(l:file, '\v[\\/]', '__', 'g')
  let l:file = substitute(l:file, ':', '++', 'g')
  let l:path = g:vsession_path . '/' . l:file
  execute 'silent mksession!' l:path
endfunction

augroup vsession_config
  autocmd!
  autocmd VimLeave * call s:save_session()
augroup END
