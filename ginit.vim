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

function! s:nvimqt_bg()
  let l:hour = str2nr(strftime('%H'))
  let &bg = l:hour >= 6 && l:hour < 18 ? 'light' : 'dark'
endfunction

function! s:nvimqt_bg_checker(timer_id)
  call s:nvimqt_bg()
endfunction

function! s:nvimqt_memo_lazy_save()
  if expand('%:t') ==? ''
    if exists('g:onedrive_path')
      silent exe 'w' g:onedrive_path . '/Documents/Agenda/diary/memo_' . strftime("%Y-%m-%d_%H%M") . '.wiki | e!'
    else
      silent exe 'w' g:usr_desktop . '/memo_' . strftime("%Y-%m-%d_%H%M") . '.wiki | e!'
    end
  else
    exe 'w'
  endif
endfunction


"" Set behaviors
if exists('g:usr_desktop')
  exe 'cd' g:usr_desktop
endif
lcd %:p:h
set mouse=a

"" GUI
GuiTabline   0
GuiPopupmenu 0
GuiLinespace 0

if exists('g:gui_background') && !empty(g:gui_background)
  let &bg = g:gui_background
else
  call s:nvimqt_bg()
endif

let timer_id = timer_start(1800000, function('<SID>nvimqt_bg_checker'), { 'repeat': -1 })

"" Font
if !exists('g:gui_font_size')
  let g:gui_font_size = 10
endif
if !exists('gui_font_family')
  let g:gui_font_family = 'Monospace'
endif
call s:nvimqt_font_set(g:gui_font_family, g:gui_font_size)

let s:gui_font_step = 2
let g:gui_font_size_origin = g:gui_font_size

nn  <silent> <C-0> <cmd>call       <SID>nvimqt_font_origin()<CR>
ino <silent> <C-0> <C-\><C-o>:call <SID>nvimqt_font_origin()<CR>

for [key, val] in items({ '=':'expand', '-':'shrink', 'ScrollWheelUp':'expand', 'ScrollWheelDown':'shrink' })
  exe 'nn'  '<silent> <C-' . key . '> <cmd>call       <SID>nvimqt_font_' . val . '()<CR>'
  exe 'ino' '<silent> <C-' . key . '> <C-\><C-O>:call <SID>nvimqt_font_' . val . '()<CR>'
endfor

"" Lazy save the memo.
nn <silent> <C-s> :call <SID>nvimqt_memo_lazy_save()<CR>
