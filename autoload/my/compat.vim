let s:_bg_timer = v:null
let s:_bg_locked = 0

" Check background according to time.
function! s:bg_checker(bg_timer) abort
  let l:hour = str2nr(strftime('%H'))
  let l:bg = l:hour >= 6 && l:hour < 18 ? 'light' : 'dark'
  if &bg != l:bg | let &bg = l:bg | endif
endfunction

" MarkdownPreviewToggle
function! s:markdown_preview_toggle() abort
  if exists("g:vscode") > 0
    call VSCodeNotify("markdown.showPreviewToSide")
  elseif exists(":MarkdownPreviewToggle")
    MarkdownPreviewToggle
  endif
endfunction

" Determine if the Background lock is active.
function! my#compat#bg_lock_is_active() abort
  return s:_bg_locked
endfunction

" Set background according to time.
function! my#compat#bg_lock_toggle() abort
  if !g:_my_theme_switchable
    let s:_bg_locked = 0
  elseif s:_bg_timer == v:null
    let s:_bg_timer = timer_start(
          \ 600,
          \ function('s:bg_checker'),
          \ { 'repeat': -1 })
    call s:bg_checker(s:_bg_timer)
    let s:_bg_locked = 1
  else
    if s:_bg_locked
      call timer_pause(s:_bg_timer, 1)
      let s:_bg_locked = 0
      echom "Background is unlocked."
    else
      call timer_pause(s:_bg_timer, 0)
      let s:_bg_locked = 1
      echom "Background is locked."
    end
  endif
endfunction

" Background toggle.
function! my#compat#bg_toggle() abort
  if !g:_my_theme_switchable || s:_bg_locked
    return
  else
    let &bg = &bg ==# 'dark' ? 'light' : 'dark'
  endif
endfunction

" Warn when has incompatible code.
function! my#compat#has_incompat() abort
  if has("nvim") | return 0 | endif
  echohl WarningMsg
  echomsg "This function is incompatible with vim. Aborted."
  echohl None
  return 1
endfunction

" Key bindings for markdown.
function my#compat#md_kbd() abort
  for [s:key, s:val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
    for s:mod_item in ['n', 'v']
      exe s:mod_item . 'n' '<buffer><silent> <M-' . s:key . '>'
            \ ':call my#srd#srd_add("' . s:mod_item . '","' . s:val . '")<CR>'
    endfor
  endfor
  nnoremap <buffer><silent> <F5> <Cmd>PresentingStart<CR>
  call my#util#set_keymap("n", "<leader>mt",
        \ function("s:markdown_preview_toggle"), {
          \ "noremap": 1,
          \ "silent": 1,
          \ })
endfunction

" Mouse toggle.
function! my#compat#mouse_toggle() abort
  if empty(&mouse)
    let &mouse = 'a'
    echom "Mouse enabled"
  else
    let &mouse = ''
    echom "Mouse disabled"
  endif
endfunction

" Open nvimrc.
function! my#compat#open_opt() abort
  let [l:exists, l:opt_file] = my#lib#get_nvimrc()
  if l:exists
    call my#util#edit_file(l:opt_file)
    exe 'cd' fnameescape(my#compat#stdpath("config"))
  elseif l:opt_file != v:null
    exe 'e' fnameescape(l:opt_file)
    call feedkeys("i{}\<Left>")
  else
    echomsg "No available configuration directory"
  endif
endfunction

" Replaces terminal codes and *keycodes* (<CR>, <Esc>, ...) in a
" string with the internal representation.
function! my#compat#replace_termcodes(str, from_part, do_lt, special) abort
  if has("nvim-0.5")
    return nvim_replace_termcodes(a:str, v:true, a:do_lt, a:special)
  endif
  return substitute(a:str, "<Plug>", "\<Plug>", "g")
endfunction

" Similar to lua's `require`
function! my#compat#require(modname) abort
  let l:config_dir = my#compat#stdpath('config') . '/'
  let l:name = 'viml/' . a:modname
  if !empty(glob(l:config_dir . l:name . '.vim'))
    call my#compat#vim_source(l:name)
  elseif isdirectory(l:config_dir . l:name)
    call my#compat#vim_source(l:name . '/init')
  endif
endfunction

" `CodeRun` complete option list.
function! my#compat#code_run_option(arglead, cmdline, cursorpos) abort
  let l:option_table = {
        \ 'c'    : "build\ncheck",
        \ 'cs'   : "build\nclean\ntest",
        \ 'lisp' : "build",
        \ 'lua'  : "lua\njit",
        \ 'rust' : "build\ncheck\nclean\ntest",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return l:option_table[&filetype]
  else
    return ''
  endif
endfunction

" Set global variable.
function! my#compat#set_var(name, value) abort
  if has("nvim")
    call nvim_set_var(a:name, a:value)
  else
    let g:{a:name} = a:value
  endif
endfunction

" Standard path
function! my#compat#stdpath(what, nvim = 1) abort
  if has("nvim")
    return stdpath(a:what)
  endif
  if has("unix")
    let l:stdpath = {
          \ "config" : a:nvim ? expand("$HOME/.config/nvim") : expand("$HOME"),
          \ "data" : a:nvim ? expand("$HOME/.local/share/nvim") : expand("$HOME/.vim")
          \ }
  elseif has("win32")
    let l:stdpath = {
          \ "config" : a:nvim ? expand("$LOCALAPPDATA\\nvim") : expand("$HOME"),
          \ "data" : a:nvim ? expand("$LOCALAPPDATA\\nvim-data") : expand("$HOME\\vimfiles")
          \ }
  else
    echoerr "OS is not supported"
    return
  endif
  if has_key(l:stdpath, a:what)
    return l:stdpath[a:what]
  else
    echoerr 'E6100: "' . a:what . '" is not a valid stdpath'
    return
  endif
endfunction

" Source vim file.
function! my#compat#vim_source(file) abort
  let l:full_path = my#compat#stdpath('config') . '/' . a:file . '.vim'
  if !empty(glob(l:full_path))
    exe 'source' fnameescape(l:full_path)
  else
    echo 'File `' . a:file . '.vim` is not found'
  endif
endfunction

" VSCode Key binding.
function! my#compat#vsc_kbd(mode, lhs, cmd, range = [], args = v:null, block = 0) abort
  if !(a:mode ==# "n" || a:mode ==# "v") | return | endif
  let l:opts = { "noremap": v:true, "silent": v:true }
  let l:arg = a:args == v:null ? "" : "," . (type(a:args) == v:t_string ? a:args : string(a:args))
  let l:func = "VSCode"
  let l:func .= a:block ? "Call" : "Notify"
  let l:cnt = len(a:range)
  if a:mode ==# "v"
    if l:cnt == 1
      let l:func .= "Visual"
    else
      return
    endif
  elseif a:mode ==# "n"
    if l:cnt == 0
    elseif l:cnt == 3
      let l:func .= "Range"
    elseif l:cnt == 5
      let l:func .= "RangePos"
    else
      return
    endif
  endif
  let l:pos = l:cnt == 0 ? "" : "," . join(a:range, ",")
  let l:rhs = '<Cmd>call ' . l:func . '(' . string(a:cmd) . l:pos . l:arg . ")<CR>"
  call nvim_set_keymap(a:mode, a:lhs, l:rhs, l:opts)
endfunction
