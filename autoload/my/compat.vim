" Background toggle.
function! my#compat#bg_toggle() abort
  if exists("g:lock_background") && g:lock_background
    return
  else
    let &bg = &bg ==# 'dark' ? 'light' : 'dark'
  endif
endfunction

" Mouse toggle.
function! my#compat#mouse_toggle() abort
  if &mouse ==# 'a'
    let &mouse = ''
    echom "Mouse disabled"
  else
    let &mouse = 'a'
    echom "Mouse enabled"
  endif
endfunction

" `CodeRun` complete option list.
function! my#compat#run_code_option(arglead, cmdline, cursorpos) abort
  let l:option_table = {
        \ 'c'    : "build\ncheck",
        \ 'cs'   : "lib\nmod\nwin",
        \ 'lisp' : "build",
        \ 'lua'  : "nojit",
        \ 'rust' : "build\ncheck\nclean\ntest",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return l:option_table[&filetype]
  else
    return ''
  endif
endfunction

" vim-markdown toggle math display.
function! my#compat#vim_markdown_math_toggle() abort
  let g:vim_markdown_math = 1 - g:vim_markdown_math
  syntax off | syntax on
endfunction

" Show table of contents.
function! my#compat#show_toc() abort
  if &ft ==? 'markdown'
    if exists(':Tocv')
      Tocv
      vertical resize 30
    endif
  elseif &ft ==? 'tex'
    if exists(':VimtexTocToggle')
      VimtexTocToggle
    endif
  else
    try
      Vista!!
    catch
      echo 'No Toc support for current filetype.'
    endtry
  endif
endfunction

" Source vim file.
function! my#compat#vim_source(file) abort
  exe 'source' my#compat#stdpath('config') . '/' . a:file . '.vim'
endfunction

" Source vim files.
function! my#compat#vim_source_list(file_list) abort
  for l:file in a:file_list
    call my#compat#vim_source('viml/' . l:file)
  endfor
endfunction

" Open opt.json.
function! my#compat#open_opt() abort
  let l:cfg = my#compat#stdpath("config")
  let l:opt = l:cfg . "/opt.json"
  if empty(glob(l:opt))
    exe 'e' l:opt
    call feedkeys("i{}\<Left>")
  else
    call my#util#edit_file(l:opt, v:false)
  endif
  exe 'cd' fnameescape(l:cfg)
endfunction

"" Set background according to time.
function! s:background_checker(bg_timer) abort
  if !g:lock_background | return | end
  let l:hour = str2nr(strftime('%H'))
  let l:bg = l:hour >= 6 && l:hour < 18 ? 'light' : 'dark'
  if &bg != l:bg | let &bg = l:bg | endif
endfunction

function! my#compat#time_background() abort
  let bg_timer = timer_start(
        \ 600,
        \ function('<SID>background_checker'),
        \ { 'repeat': -1 })
  call s:background_checker(bg_timer)
endfunction

" Set markdown surrounding keymaps.
function! my#compat#md_kbd() abort
  for [s:key, s:val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
    for s:mod_item in ['n', 'v']
      exe s:mod_item . 'n' '<buffer><silent> <M-' . s:key . '>'
            \ ':call my#srd#sur_add("' . s:mod_item . '","' . s:val . '")<CR>'
    endfor
  endfor
  nnoremap <buffer><silent> <F5> <Cmd>PresentingStart<CR>
  nnoremap <buffer><silent> <leader>mt <Cmd>MarkdownPreviewToggle<CR>
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

" Set global variable.
function! my#compat#set_var(name, value) abort
  if has("nvim")
    call nvim_set_var(a:name, a:value)
  else
    exe "let g:" . a:name "= a:value"
  endif
endfunction

function! my#compat#hasIncompat() abort
  if has("nvim")
    return 0
  endif
  echohl WarningMsg
  echomsg "This function is incompatible with vim. Aborted."
  echohl None
  return 1
endfunction
