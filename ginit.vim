" Configuration for nvim-qt
"" Functions
function! s:nvimqt_font_set(family, size)
  exe 'GuiFont!' a:family . ':h' . a:size
endfunction

function! s:nvimqt_font_expand()
  let g:gui_font_size += s:gui_font_step
  call s:nvimqt_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:nvimqt_font_shrink()
  let g:gui_font_size = max([g:gui_font_size - s:gui_font_step, 3])
  call s:nvimqt_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:nvimqt_font_origin()
  let g:gui_font_size = g:gui_font_size_origin
  call s:nvimqt_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:nvimqt_memo_lazy_save()
  if expand('%:t') ==? ''
    if exists('g:onedrive_path')
      silent exe 'w' g:onedrive_path . '/Documents/Agenda/memo/memo_' . strftime("%y%m%d_%H%M") . '.md | e!'
    else
      silent exe 'w' g:usr_desktop . '/memo_' . strftime("%y%m%d_%H%M") . '.md | e!'
    end
  else
    exe 'w'
  endif
endfunction


"" Set behaviors
exe 'cd' g:usr_desktop
lcd %:p:h
set mouse=a

"" GUI
:GuiTabline   0
:GuiPopupmenu 0
:GuiLinespace 0

"" Font
let g:gui_font_size = 10
let g:gui_font_family = '等距更纱黑体 SC'
call s:nvimqt_font_set(g:gui_font_family, g:gui_font_size)

let s:gui_font_step = 2
let g:gui_font_size_origin = g:gui_font_size

nn  <silent> <C-=> :call <SID>nvimqt_font_expand()<CR>
nn  <silent> <C--> :call <SID>nvimqt_font_shrink()<CR>
nn  <silent> <C-0> :call <SID>nvimqt_font_origin()<CR>
ino <silent> <C-=> <C-o>:call <SID>nvimqt_font_expand()<CR>
ino <silent> <C--> <C-o>:call <SID>nvimqt_font_shrink()<CR>
ino <silent> <C-0> <C-o>:call <SID>nvimqt_font_origin()<CR>

" Lazy save the memo.
nn <silent> <C-s> :call <SID>nvimqt_memo_lazy_save()<CR>
