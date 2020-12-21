" Configuration just for nvim-qt
"" Functions
function! s:nvimqt_set_font(family, size)
  exe ':GuiFont! ' . a:family . ':h' . a:size
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
"call s:nvimqt_set_font('Cascadia Code PL', 9)
call s:nvimqt_set_font('等距更纱黑体 SC', 9)

"augroup gui_switch_font
"  autocmd!
"  au BufEnter * call s:nvimqt_set_font('Cascadia Code PL', 9)
"  au BufEnter *.md,*.org,*.txt call s:nvimqt_set_font('等距更纱黑体 SC', 9)
"augroup end
