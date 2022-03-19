" GUI Configuration.
" Supported GUIs:
"   - [neovim-qt](https://github.com/equalsraf/neovim-qt)
"   - [fvim](https://github.com/yatli/fvim)
"   - [goneovim](https://github.com/akiyosi/goneovim)

" Variables
if !exists('g:_my_gui_font_half')
  let g:_my_gui_font_half = 'Monospace'
endif

if !exists('g:_my_gui_font_full')
  let g:_my_gui_font_full = 'Monospace'
endif

if !exists('g:_my_gui_font_size')
  let g:_my_gui_font_size = 10
endif

if !exists('g:_my_gui_opacity')
  let g:_my_gui_opacity = 1.0
endif

let s:nvimqt_option_table = {
      \ 'GuiTabline'         : 0,
      \ 'GuiPopupmenu'       : 1,
      \ 'GuiLinespace'       : 0,
      \ 'GuiScrollBar'       : 1,
      \ 'GuiRenderLigatures' : 1,
      \ 'GuiAdaptiveColor'   : 1,
      \ 'GuiWindowOpacity'   : string(g:_my_gui_opacity),
      \ 'GuiAdaptiveStyle'   : 'Fusion',
      \ }

let s:fvim_option_table = {
      \ 'FVimUIPopupMenu'           : 'v:true',
      \ 'FVimFontAntialias'         : 'v:true',
      \ 'FVimFontLigature'          : 'v:true',
      \ 'FVimFontLineHeight'        : '"+2.0"',
      \ 'FVimFontNoBuiltInSymbols'  : 'v:true',
      \ 'FVimBackgroundOpacity'     : string(g:_my_gui_opacity),
      \ 'FVimCursorSmoothMove'      : 'v:true',
      \ 'FVimBackgroundComposition' : '"none"',
      \ 'FVimCustomTitleBar'        : 'v:false',
      \ 'FVimKeyAutoIme'            : 'v:true',
      \ }


" Functions
function! s:gui_font_set(half, full, size) abort
  if exists(':GuiFont')
    exe 'GuiFont!' a:half . ':h' . a:size
  else
    let &gfn = a:half . ':h' . a:size
  endif
  let &gfw = a:full . ':h' . a:size
endfunction

function! s:gui_font_expand() abort
  let g:_my_gui_font_size += s:gui_font_step
  call s:gui_font_set(g:_my_gui_font_half,
                    \ g:_my_gui_font_full,
                    \ g:_my_gui_font_size)
endfunction

function! s:gui_font_shrink() abort
  let g:_my_gui_font_size = max([g:_my_gui_font_size - s:gui_font_step, 3])
  call s:gui_font_set(g:_my_gui_font_half,
                    \ g:_my_gui_font_full,
                    \ g:_my_gui_font_size)
endfunction

function! s:gui_font_origin() abort
  let g:_my_gui_font_size = g:_my_gui_font_size_origin
  call s:gui_font_set(g:_my_gui_font_half,
                    \ g:_my_gui_font_full,
                    \ g:_my_gui_font_size)
endfunction

function! s:gui_fullscreen_toggle() abort
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

function! s:gui_set_option_table(option_table) abort
  for [l:opt, l:arg] in items(a:option_table)
    if exists(':' . l:opt)
      silent exe l:opt l:arg
    endif
  endfor
endfunction

function! s:gui_number_toggle() abort
  if &rnu == 1 | set nornu | endif | set invnu
endfunction

function! s:gui_relative_number_toggle() abort
  if &nu == 1 | set invrnu | else | set nu rnu | endif
endfunction

function! s:gui_toggle_background_lock() abort
  if g:_my_lock_background == v:true
    let g:_my_lock_background = v:false
    echom "Background unlocked"
  else
    let g:_my_lock_background = v:true
    echom "Background locked"
  endif
endfunction

function! s:gui_memo_lazy_save() abort
  if !empty(&bt)
    return
  elseif empty(expand('%:t'))
    let l:path = expand(g:_my_path_cloud . '/Notes/diary')
    if empty(glob(l:path))
      let l:path = g:_my_path_desktop
    endif
    let l:save_path = expand(l:path . strftime("/%Y-%m-%d_%H%M%S.wiki"))
    silent exe 'w' l:save_path '| e!'
  else
    exe 'w'
  endif
endfunction

function! s:gui_file_explorer() abort
  if exists(':GuiTreeviewToggle')
    GuiTreeviewToggle
  elseif exists('g:goneovim')
    GonvimFilerOpen
  endif
endfunction


if exists('g:_my_path_desktop')
  exe 'cd' g:_my_path_desktop
endif
cd %:p:h
set mouse=a


" GUI
"" neovim-qt GUI
call s:gui_set_option_table(s:nvimqt_option_table)
"" Fvim GUI
if exists('g:fvim_loaded')
  call s:gui_set_option_table(s:fvim_option_table)
endif
"" Background
if exists('g:_my_gui_theme')
  if g:_my_gui_theme == 'light'
        \ || g:_my_gui_theme == 'dark'
    let &bg = g:_my_gui_theme
  elseif g:_my_gui_theme == 'auto'
        \ && exists('g:colors_name')
        \ && g:colors_name ==# 'nanovim'
        \ || exists('g:goneovim')
    let g:_my_lock_background = v:true
    call my#misc#time_background()
  endif
endif
"" tabline
if exists('g:goneovim')
  set laststatus=0
  set showtabline=2
endif


" Font
let s:gui_font_step = 2
let g:_my_gui_font_size_origin = g:_my_gui_font_size
call s:gui_font_set(g:_my_gui_font_half,
                  \ g:_my_gui_font_full,
                  \ g:_my_gui_font_size)


" GUI key bindings
"" Font size
let s:gui_font_size_kbd = {
      \ '<C-0>' : 'origin',
      \ '<C-=>' : 'expand',
      \ '<C-->' : 'shrink',
      \ '<C-ScrollWheelUp>'   : 'expand',
      \ '<C-ScrollWheelDown>' : 'shrink',
      \ }
for [s:key, s:val] in items(s:gui_font_size_kbd)
  exe 'nn'  '<silent>' s:key '<Cmd>call'
        \ '<SID>gui_font_' . s:val . '()<CR>'
  exe 'ino' '<silent>' s:key '<C-\><C-O>:call'
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
"" Toggle GUI built-in file explorer
nn <silent> <F3> :call <SID>gui_file_explorer()<CR>
"" Lock/unlock background
if exists('g:_my_lock_background')
  nn <silent> <F4> :call <SID>gui_toggle_background_lock()<CR>
endif
