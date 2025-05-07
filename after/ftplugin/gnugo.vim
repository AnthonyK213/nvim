function! s:change_mode() abort
  let l:mode_list = ['black', 'white', 'manual']
  if exists("b:runner") && exists(":ChangeMode")
    let l:mode = b:runner["mode"]
    let l:index = index(l:mode_list, l:mode)
    let l:next = l:mode_list[(l:index + 1) % 3]
    exe 'ChangeMode' l:next
    echom 'Mode changed to' l:next
  endif
endfunction

nn <buffer> c <Cmd>Cheat<CR>
nn <buffer> u <Cmd>Undo<CR>
nn <buffer> s <Cmd>call <SID>change_mode()<CR>
