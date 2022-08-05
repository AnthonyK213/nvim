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
let g:_my_tui_global_statusline = v:false
let g:_my_gui_theme = 'auto'
let g:_my_gui_opacity = 0.98
let g:_my_gui_ligature = v:false
let g:_my_gui_popup_menu = v:false
let g:_my_gui_tabline = v:false
let g:_my_gui_scroll_bar = v:false
let g:_my_gui_line_space = 0
let g:_my_gui_font_size = 13
let g:_my_gui_font_half = 'Monospace'
let g:_my_gui_font_full = 'Monospace'
let g:_my_use_coc = v:false
let g:_my_lsp_clangd = v:false
let g:_my_lsp_jedi_language_server = v:false
let g:_my_lsp_powershell_es = { 'enable' : v:false, 'path' : v:null }
let g:_my_lsp_omnisharp = { 'enable' : v:false, 'path' : v:null }
let g:_my_lsp_sumneko_lua = v:false
let g:_my_lsp_rls = v:false
let g:_my_lsp_texlab = v:false
let g:_my_lsp_vimls = v:false


function s:json_set_var(json) abort
  let l:table = json_decode(a:json)
  for [l:key, l:val] in items(l:table)
    if type(l:val) == v:t_dict
      for [l:k, l:v] in items(l:val)
        call my#compat#set_var('_my_' . l:key . '_' . l:k, l:v)
      endfor
    else
      call my#compat#set_var('_my_' . l:key, l:val)
    endif
  endfor
endfunction

let [s:exists, s:opt_file] = my#lib#get_nvimrc()
if s:exists
  let s:opt_json = join(readfile(s:opt_file))
  try
    call s:json_set_var(s:opt_json)
  catch
    echomsg "Invalid option file"
  endtry
endif

" Misc
let g:mapleader = "\<Space>"
let g:python3_host_prog = g:_my_dep_py3
let g:markdown_fenced_languages = [
      \ "c", "cpp", "cs", "rust", "lua", "vim", "python", "lisp", "tex",
      \ "javascript", "typescript", "json", "cmake", "sh", "ps1", "dosbatch",
      \ "ruby", "java", "go", "perl", "html", "xml", "yaml",
      \ "config", "gitconfig", "sshconfig", "dosini"
      \ ]

" Directional operation which won't mess up the history.
let g:_const_dir_l = "\<C-G>U\<Left>"
let g:_const_dir_d = "\<C-G>U\<Down>"
let g:_const_dir_u = "\<C-G>U\<Up>"
let g:_const_dir_r = "\<C-G>U\<Right>"
