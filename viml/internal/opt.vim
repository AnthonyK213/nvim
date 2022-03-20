" Source basics.vim
call my#compat#vim_source('viml/basics')

function s:get_os_name() abort
  if has("unix")
    return "LINUX"
  elseif has("win32")
    return "WINDOWS"
  elseif has("mac")
    return "MACOS"
  else
    return "UNKNOWN"
  endif
endfunction

let g:os_type = s:get_os_name()

let g:_my_dep_sh = {
    \ "LINUX" : "bash",
    \ "WINDOWS" : ['powershell.exe', '-nologo'],
    \ "MACOS" : "zsh"
    \ }[g:os_type]
let g:_my_dep_cc = 'gcc'
let g:_my_dep_py3 = '/usr/bin/python3'
let g:_my_dep_start = {
    \ "LINUX" : "xdg-open",
    \ "WINDOWS" : ['cmd', '/c', 'start', '""'],
    \ "MACOS" : "open"
    \ }[g:os_type]
let g:_my_path_home = getenv('HOME')
let g:_my_path_cloud = has_key(environ(), 'ONEDRIVE') ?
      \ getenv('ONEDRIVE') : g:_my_path_home
let g:_my_path_desktop = expand(g:_my_path_home . '/Desktop')
let g:_my_tui_scheme = 'one'
let g:_my_tui_theme = 'dark'
let g:_my_tui_style = 'none'
let g:_my_tui_transparent = v:false
let g:_my_gui_theme = 'auto'
let g:_my_gui_opacity = 0.98
let g:_my_gui_font_size = 13
let g:_my_gui_font_half = 'Monospace'
let g:_my_gui_font_full = 'Monospace'
let g:_my_use_coc = v:false
let g:_my_lsp = {
      \ 'clangd' : v:false,
      \ 'jedi_language_server' : v:false,
      \ 'powershell_es' : { 'enable' : v:false, 'path' : v:null },
      \ 'omnisharp' : { 'enable' : v:false, 'path' : v:null },
      \ 'sumneko_lua' : v:false,
      \ 'rls' : v:false,
      \ 'texlab' : v:false,
      \ 'vimls' : v:false,
      \ }

function s:json_set_var(json) abort
  let l:table = json_decode(a:json)
  for [l:key, l:val] in items(l:table)
    if l:key !=# 'lsp' && type(l:val) == v:t_dict
      for [l:k, l:v] in items(l:val)
        call nvim_set_var('_my_' . l:key . '_' . l:k, l:v)
      endfor
    else
      call nvim_set_var('_my_' . l:key, l:val)
    endif
  endfor
endfunction

let s:opt_file = stdpath('config') . '/opt.json'
if !empty(glob(s:opt_file))
  let s:opt_json = readfile(s:opt_file)
  try
    call s:json_set_var(s:opt_json)
  catch
    echomsg "Invalid `opt.json`"
  endtry
endif

" Misc
let g:mapleader = "\<Space>"
let g:python3_host_prog = g:_my_dep_py3

" Directional operation which won't mess up the history.
let g:_const_dir_l = "\<C-g>U\<Left>"
let g:_const_dir_d = "\<C-g>U\<Down>"
let g:_const_dir_u = "\<C-g>U\<Up>"
let g:_const_dir_r = "\<C-g>U\<Right>"
