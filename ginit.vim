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

"" Set behaviors
try
  exe 'cd ' . g:usr_desktop
catch
endtry
lcd %:p:h
set mouse=a

"" GUI
:GuiTabline   0
:GuiPopupmenu 0
:GuiLinespace 0

"" Font
let g:gui_font_size = 10
let s:gui_font_step = 2
let g:gui_font_size_origin = g:gui_font_size
let g:gui_font_family = '等距更纱黑体 SC'
call s:nvimqt_set_font(g:gui_font_family, g:gui_font_size)

nn <silent> <C-=> :call <SID>nvimqt_expand_font()<CR>
nn <silent> <C--> :call <SID>nvimqt_shrink_font()<CR>
nn <silent> <C-0> :call <SID>nvimqt_origin_font()<CR>
