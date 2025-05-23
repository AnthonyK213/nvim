" GUI Configuration.
" Supported GUIs:
"   - [Neovim Qt](https://github.com/equalsraf/neovim-qt)
"   - [Fvim](https://github.com/yatli/fvim)
"   - [Neovide](https://github.com/neovide/neovide)
"   - [VimR](https://github.com/qvacua/vimr)


" Initialize global variables.
let s:my_gui_table = {
      \ '_my_gui_theme': 'auto',
      \ '_my_gui_opacity': 1,
      \ '_my_gui_ligature': v:false,
      \ '_my_gui_popup_menu': v:false,
      \ '_my_gui_tabline': v:false,
      \ '_my_gui_scroll_bar': v:false,
      \ '_my_gui_line_space': 0,
      \ '_my_gui_font_size': 13,
      \ '_my_gui_font_half': 'Monospace',
      \ '_my_gui_font_wide': 'Monospace',
      \ }
for [s:name, s:value] in items(s:my_gui_table)
  if !exists('g:' . s:name)
    let g:{s:name} = s:value
  endif
endfor


" Functions
function! s:bool2int(b) abort
  if type(a:b) == v:t_bool
    return a:b ? 1 : 0
  else
    return 0
  endif
endfunction

function! s:gui_font_set(half=g:_my_gui_font_half,
      \ wide=g:_my_gui_font_wide,
      \ size=g:_my_gui_font_size) abort
  if exists(':GuiFont')
    exe 'GuiFont!' a:half . ':h' . a:size
  else
    if exists("g:neovide")
      let &gfn = a:half . "," . a:wide . ':h' . a:size
    else
      let &gfn = a:half . ':h' . a:size
    endif
  endif
  let &gfw = a:wide . ':h' . a:size
endfunction

function! s:gui_font_expand() abort
  let g:_my_gui_font_size += s:gui_font_step
  call s:gui_font_set()
endfunction

function! s:gui_font_shrink() abort
  let g:_my_gui_font_size = max([g:_my_gui_font_size - s:gui_font_step, 3])
  call s:gui_font_set()
endfunction

function! s:gui_font_origin() abort
  let g:_my_gui_font_size = s:gui_font_size_origin
  call s:gui_font_set()
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
  elseif exists(':VimRToggleFullscreen')
    VimRToggleFullscreen
  endif
endfunction

function! s:gui_set_option_table(option_table) abort
  for [l:opt, l:arg] in items(a:option_table)
    if l:opt =~ '\v^g:.+$'
      let g:{l:opt[2:]} = l:arg
    elseif l:opt =~ '\v^o:.+$'
      exe "set" l:opt[2:] . "=" . l:arg
    elseif exists(':' . l:opt)
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

function! s:gui_memo_lazy_save() abort
  if !empty(&bt)
    return
  elseif empty(expand('%:t'))
    let l:path = expand(g:_my_path_vimwiki . '/diary')
    if empty(glob(l:path))
      let l:path = g:_my_path_desktop
    endif
    let l:save_path = expand(l:path . strftime("/%Y-%m-%d_%H%M%S.markdown"))
    silent exe 'w' fnameescape(l:save_path) '| e!'
  else
    exe 'w'
  endif
endfunction

function! s:gui_file_explorer() abort
  if exists(':GuiTreeviewToggle')
    GuiTreeviewToggle
  elseif exists(':VimRToggleTools')
    VimRToggleTools
  endif
endfunction


" For Neovide, `init.lua` should be loaded before `ginit.vim`.
if exists("g:neovide")
  call my#compat#require("my_init")
endif


" Configuration tables
let s:nvimqt_option_table = {
      \ 'GuiTabline': s:bool2int(g:_my_gui_tabline),
      \ 'GuiPopupmenu': s:bool2int(g:_my_gui_popup_menu),
      \ 'GuiLinespace': string(g:_my_gui_line_space),
      \ 'GuiScrollBar': s:bool2int(g:_my_gui_scroll_bar),
      \ 'GuiRenderLigatures': s:bool2int(g:_my_gui_ligature),
      \ 'GuiAdaptiveColor': 1,
      \ 'GuiWindowOpacity': string(g:_my_gui_opacity),
      \ 'GuiAdaptiveStyle': 'Fusion',
      \ }
let s:fvim_option_table = {
      \ 'FVimUIPopupMenu': g:_my_gui_popup_menu,
      \ 'FVimFontAntialias': v:true,
      \ 'FVimFontLigature': g:_my_gui_ligature,
      \ 'FVimFontLineHeight': string(g:_my_gui_line_space),
      \ 'FVimFontNoBuiltInSymbols': v:true,
      \ 'FVimBackgroundOpacity': string(g:_my_gui_opacity),
      \ 'FVimCursorSmoothMove': v:true,
      \ 'FVimBackgroundComposition': '"none"',
      \ 'FVimCustomTitleBar': v:false,
      \ 'FVimKeyAutoIme': v:true,
      \ }
let s:neovide_option_table = {
      \ 'o:linespace': g:_my_gui_line_space,
      \ 'g:neovide_padding_top': 13,
      \ 'g:neovide_padding_bottom': 13,
      \ 'g:neovide_padding_right': 13,
      \ 'g:neovide_padding_left': 13,
      \ 'g:neovide_theme': g:_my_gui_theme,
      \ 'g:neovide_opacity': g:_my_gui_opacity,
      \ 'g:neovide_floating_blur_amount_x': 2.0,
      \ 'g:neovide_floating_blur_amount_y': 2.0,
      \ }
let s:vimr_option_table = {
      \ 'VimRSetLinespacing': printf("%.1f", g:_my_gui_line_space),
      \ }


" GUI
"" Set CWD
if exists('g:_my_path_desktop')
  exe 'cd' fnameescape(g:_my_path_desktop)
endif
cd %:p:h
"" Enable mouse
set mouse=a
"" Cursor blink
if exists("g:_my_gui_cursor_blink") && g:_my_gui_cursor_blink
  :set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,
        \a:blinkwait800-blinkoff500-blinkon500-Cursor/lCursor,
        \sm:block-blinkwait240-blinkoff150-blinkon150
endif
"" Neovim Qt
call s:gui_set_option_table(s:nvimqt_option_table)
"" Fvim
if exists("g:fvim_loaded")
  call s:gui_set_option_table(s:fvim_option_table)
endif
"" Neovide
if exists("g:neovide")
  call my#compat#require("my_init")
  call s:gui_set_option_table(s:neovide_option_table)
  augroup my_neovide
    au!
    " Disable IME automatically.
    au InsertLeave * exe "let g:neovide_input_ime=v:false"
    au InsertEnter * exe "let g:neovide_input_ime=v:true"
    " Command mode needs `INSERT`.
    au CmdlineEnter * exe "let g:neovide_input_ime=v:true"
    au CmdlineLeave * exe "let g:neovide_input_ime=v:false"
  augroup END
endif
"" VimR
if exists("g:gui_vimr")
  call s:gui_set_option_table(s:vimr_option_table)
endif
"" GUI theme
if exists("g:_my_theme_switchable") && !empty(g:_my_theme_switchable)
  if g:_my_gui_theme == 'light' || g:_my_gui_theme == 'dark'
    if type(g:_my_theme_switchable) == v:t_func
      call g:_my_theme_switchable(g:_my_gui_theme)
    else
      let &bg = g:_my_gui_theme
    endif
  elseif g:_my_gui_theme == 'auto' && !exists("g:neovide") " 'auto' means to
                                                           " follow the system
                                                           " theme in neovide.
    call my#compat#bg_lock_toggle()
  endif
endif


" Font
let s:gui_font_step = 2
let s:gui_font_size_origin = g:_my_gui_font_size
call s:gui_font_set()


" GUI key bindings
"" Font size
let s:gui_font_size_kbd = {
      \ '<C-0>' : 'origin',
      \ '<C-=>' : 'expand',
      \ '<C-->' : 'shrink',
      \ '<C-ScrollWheelUp>'   : 'expand',
      \ '<C-ScrollWheelDown>' : 'shrink',
      \ }
for [s:k, s:v] in items(s:gui_font_size_kbd)
  exe 'nn'  '<silent>' s:k '<Cmd>call' '<SID>gui_font_' . s:v . '()<CR>'
  exe 'ino' '<silent>' s:k '<C-\><C-O>:call' '<SID>gui_font_' . s:v . '()<CR>'
endfor
"" Lazy save the memo.
nn <silent> <C-S> :call <SID>gui_memo_lazy_save()<CR>
"" Toggle GUI built-in file explorer
nn <silent> <F3> :call <SID>gui_file_explorer()<CR>
"" Lock/unlock background
nn <silent> <F4> :call my#compat#bg_lock_toggle()<CR>
"" Toggle line number display
nn  <silent> <F9> :call <SID>gui_number_toggle()<CR>
ino <silent> <F9> <C-\><C-o>:call <SID>gui_number_toggle()<CR>
"" Toggle relative line number display
nn  <silent> <S-F9> :call <SID>gui_relative_number_toggle()<CR>
ino <silent> <S-F9> <C-\><C-o>:call <SID>gui_relative_number_toggle()<CR>
"" Toggle full screen
nn  <silent> <F11> :call <SID>gui_fullscreen_toggle()<CR>
ino <silent> <F11> <C-\><C-o>:call <SID>gui_fullscreen_toggle()<CR>
