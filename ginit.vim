"""""""" Configuration for neovim GUI using ginit.vim

" Variables
let s:gui_size_kbd = {
      \ '=' : 'expand',
      \ '-' : 'shrink',
      \ 'ScrollWheelUp' : 'expand',
      \ 'ScrollWheelDown' : 'shrink',
      \ }

let s:nvimqt_option_table = {
      \ 'GuiTabline'         : 0,
      \ 'GuiPopupmenu'       : 1,
      \ 'GuiLinespace'       : 0,
      \ 'GuiScrollBar'       : 1,
      \ 'GuiRenderLigatures' : 1,
      \ 'GuiAdaptiveColor'   : 1,
      \ 'GuiWindowOpacity'   : '0.92',
      \ 'GuiAdaptiveStyle'   : 'Fusion',
      \ }


" Functions
function! s:gui_font_set(family, size)
  if exists(':GuiFont')
    exe 'GuiFont!' a:family . ':h' . a:size
  else
    exe 'set guifont=' . escape(a:family, ' ') . ':h' . a:size
  endif
endfunction

function! s:gui_font_expand()
  let g:gui_font_size += s:gui_font_step
  call s:gui_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:gui_font_shrink()
  let g:gui_font_size = max([g:gui_font_size - s:gui_font_step, 3])
  call s:gui_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:gui_font_origin()
  let g:gui_font_size = g:gui_font_size_origin
  call s:gui_font_set(g:gui_font_family, g:gui_font_size)
endfunction

function! s:gui_fullscreen_toggle()
  if exists('*GuiWindowFullScreen')
    if g:GuiWindowFullScreen == 0
      call GuiWindowFullScreen(1)
      if exists(':GuiScrollBar')
        GuiScrollBar 0
      endif
    else
      call GuiWindowFullScreen(0)
      if exists(':GuiScrollBar')
        exe 'GuiScrollBar' s:nvimqt_option_table['GuiScrollBar']
      endif
    endif
  elseif exists(':FVimToggleFullScreen')
    FVimToggleFullScreen
  endif
endfunction

function! s:nvimqt_set_option(opt, arg)
  if exists(':' . a:opt)
    silent exe a:opt a:arg
  endif
endfunction

function! s:gui_number_toggle()
  if &rnu == 1 | set nornu | endif | set invnu
endfunction

function! s:gui_relative_number_toggle()
  if &nu == 1 | set invrnu | else | set nu rnu | endif
endfunction

function! s:gui_memo_lazy_save()
  if !empty(&bt)
    return
  elseif empty(expand('%:t'))
    if exists('g:path_cloud')
      silent exe 'w' g:path_cloud .
            \ '/Documents/Agenda/diary/memo_' .
            \ strftime("%Y-%m-%d_%H%M") . '.wiki | e!'
    else
      silent exe 'w' g:path_desktop .
            \ '/memo_' . strftime("%Y-%m-%d_%H%M") . '.wiki | e!'
    end
  else
    exe 'w'
  endif
endfunction


" Set behaviors
if exists('g:path_desktop')
  exe 'cd' g:path_desktop
endif
cd %:p:h
set mouse=a


" GUI
"" neovim-qt GUI
for [s:opt, s:arg] in items(s:nvimqt_option_table)
  call s:nvimqt_set_option(s:opt, s:arg)
endfor
"" Fvim GUI
if exists('g:fvim_loaded')
  FVimUIPopupMenu           v:true
  FVimFontLigature          v:true
  FVimFontLineHeight        '+2.0'
  FVimBackgroundOpacity     0.92
  FVimCursorSmoothMove      v:true
  FVimBackgroundComposition 'blur'
  FVimCustomTitleBar        v:true
  FVimFontAntialias         v:true
endif
"" Background
if exists('g:gui_background') && !empty(g:gui_background)
  let &bg = g:gui_background
endif
if exists('g:colors_name') && g:colors_name ==# 'nanovim'
  call usr#util#time_background()
endif


" Font
if !exists('g:gui_font_size')
  let g:gui_font_size = 10
endif

if !exists('gui_font_family')
  let g:gui_font_family = 'Monospace'
endif

let s:gui_font_step = 2
let g:gui_font_size_origin = g:gui_font_size
call s:gui_font_set(g:gui_font_family, g:gui_font_size)


" GUI key bindings
"" Font size
nn  <silent> <C-0> <cmd>call       <SID>gui_font_origin()<CR>
ino <silent> <C-0> <C-\><C-o>:call <SID>gui_font_origin()<CR>

for [s:key, s:val] in items(s:gui_size_kbd)
  exe 'nn'  '<silent> <C-' . s:key . '> <cmd>call'
        \ '<SID>gui_font_' . s:val . '()<CR>'
  exe 'ino' '<silent> <C-' . s:key . '> <C-\><C-O>:call'
        \ '<SID>gui_font_' . s:val . '()<CR>'
endfor
"" Toggle line number display
nn  <silent> <F9> :call <SID>gui_number_toggle()<CR>
ino <silent> <F9> <C-\><C-o>:call <SID>gui_number_toggle()<CR>
"" Toggle relative line number display
nn  <silent> <F10> :call <SID>gui_relative_number_toggle()<CR>
ino <silent> <F10> <C-\><C-o>:call <SID>gui_relative_number_toggle()<CR>
"" Toggle full screen
nn  <silent> <F11> :call <SID>gui_fullscreen_toggle()<CR>
ino <silent> <F11> <C-\><C-o>:call <SID>gui_fullscreen_toggle()<CR>
"" Lazy save the memo.
nn <silent> <C-S> :call <SID>gui_memo_lazy_save()<CR>
"" Toggle tree view
if exists(':GuiTreeviewToggle')
  nn <silent> <F3> :GuiTreeviewToggle<CR>
endif
