" Configuration just for nvim-qt
"" Functions
function! s:nvimqt_set_font(family, size)
  exe ':GuiFont! ' . a:family . ':h' . a:size
endfunction

function! s:nvimqt_expand_font()
  let g:gui_font_size += s:gui_font_step
  call s:nvimqt_set_font(g:gui_font_family, g:gui_font_size)
endfunction

function! s:nvimqt_shrink_font()
  let g:gui_font_size = max([g:gui_font_size - s:gui_font_step, 3])
  call s:nvimqt_set_font(g:gui_font_family, g:gui_font_size)
endfunction

function! s:nvimqt_origin_font()
  let g:gui_font_size = g:gui_font_size_origin
  call s:nvimqt_set_font(g:gui_font_family, g:gui_font_size)
endfunction

function! s:lazy_save_memo()
  silent exe 'w ' . g:usr_desktop . '/memo_' . strftime("%y%m%d_%H%M") . '.md'
  silent exe 'e!'
endfunction


"" Set behaviors
exe 'cd ' . g:usr_desktop
lcd %:p:h
set mouse=a

"" GUI
:GuiTabline   0
:GuiPopupmenu 0
:GuiLinespace 0

"" Font
let g:gui_font_size = 10
let g:gui_font_family = '等距更纱黑体 SC'
call s:nvimqt_set_font(g:gui_font_family, g:gui_font_size)

let s:gui_font_step = 2
let g:gui_font_size_origin = g:gui_font_size

nn  <silent> <C-=> :call <SID>nvimqt_expand_font()<CR>
nn  <silent> <C--> :call <SID>nvimqt_shrink_font()<CR>
nn  <silent> <C-0> :call <SID>nvimqt_origin_font()<CR>
ino <silent> <C-=> <C-o>:call <SID>nvimqt_expand_font()<CR>
ino <silent> <C--> <C-o>:call <SID>nvimqt_shrink_font()<CR>
ino <silent> <C-0> <C-o>:call <SID>nvimqt_origin_font()<CR>

" Lazy save the memo.
nn <silent> <M-s> :call <SID>lazy_save_memo()<CR><CR>
