""" Configuration just for nvim-qt
" Set behaviors
try
  exe 'cd ' . g:usr_desktop
catch
endtry
lcd %:p:h
set mouse=a

" GUI
"set title
:GuiTabline   0
:GuiPopupmenu 0
:GuiLinespace 0
:GuiFont! Cascadia\ Code\ PL:h9
