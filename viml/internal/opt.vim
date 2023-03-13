" Source basics.vim
call my#compat#require('basics')

function s:get_os_name() abort
  if has("unix")
    return "Linux"
  elseif has("win32")
    return "Windows"
  elseif has("mac")
    return "Macos"
  else
    return "Unknown"
  endif
endfunction

let s:os_type = s:get_os_name()

let g:_my_dep_sh = {
      \ "Linux": "bash",
      \ "Windows": ['powershell.exe', '-nologo'],
      \ "Macos": "zsh"
      \ }[s:os_type]
let g:_my_dep_cc = 'gcc'
let g:_my_dep_py3 = '/usr/bin/python3'
let g:_my_dep_start = {
      \ "Linux": "xdg-open",
      \ "Windows": ['cmd', '/c', 'start', '""'],
      \ "Macos": "open"
      \ }[s:os_type]
let g:_my_path_home = getenv('HOME')
let g:_my_path_cloud = has_key(environ(), 'ONEDRIVE') ?
      \ getenv('ONEDRIVE') : g:_my_path_home
let g:_my_path_desktop = expand(g:_my_path_home . '/Desktop')
let g:_my_tui_scheme = 'one'
let g:_my_tui_theme = 'dark'
let g:_my_tui_style = 'none'
let g:_my_tui_transparent = v:false
let g:_my_tui_global_statusline = v:false
let g:_my_tui_border = 'none'
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
let g:_my_gui_cursor_blink = v:false
let g:_my_use_coc = v:false
let g:_my_lsp_clangd = v:false
let g:_my_lsp_jedi_language_server = v:false
let g:_my_lsp_powershell_es = { 'enable' : v:false, 'path' : v:null }
let g:_my_lsp_omnisharp = { 'enable' : v:false, 'path' : v:null }
let g:_my_lsp_sumneko_lua = v:false
let g:_my_lsp_rls = v:false
let g:_my_lsp_texlab = v:false
let g:_my_lsp_vimls = v:false

" Merge custom options.
function s:json_set_var(opt_file) abort
  let [l:code, l:table] = my#lib#json_decode(a:opt_file)
  if l:code != 0
    call my#lib#notify_err("Invalid option file")
  endif
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
  try
    call s:json_set_var(s:opt_file)
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

" Highlights
let g:_my_hl = {
      \ 'EndOfBuffer': {'fg': '$bg'},
      \ 'SpellBad': {'fg': '$red', 'sp': '$red', 'fmt': 'underline'},
      \ 'SpellCap': {'fg': '$yellow', 'fmt': 'underline'},
      \ 'Underlined': {'sp': '$cyan', 'fmt': 'underline'},
      \ 'htmlUnderline': { 'sp': "$cyan", 'fmt': "underline" },
      \ 'htmlH1': {'fg': '$red', 'fmt': 'bold'},
      \ 'htmlH2': {'fg': '$red', 'fmt': 'bold'},
      \ 'htmlH3': {'fg': '$red'},
      \ 'htmlBold': {'fg': '$yellow', 'fmt': 'bold'},
      \ 'htmlItalic': {'fg': '$purple', 'fmt': 'italic'},
      \ 'htmlBoldItalic': {'fg': '$bright_yellow', 'fmt': 'bold,italic'},
      \ 'markdownH1': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH2': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH3': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH4': {'fg': '$red'},
      \ 'markdownH5': {'fg': '$red'},
      \ 'markdownH6': {'fg': '$red'},
      \ 'markdownBold': {'fg': '$yellow', 'fmt': 'bold'},
      \ 'markdownItalic': {'fg': '$purple', 'fmt': 'italic'},
      \ 'markdownBoldItalic': {'fg': '$bright_yellow', 'fmt': 'bold,italic'},
      \ 'markdownCode': {'fg': '$green'},
      \ 'markdownUrl': {'fg': '$grey'},
      \ 'markdownEscape': {'fg': '$cyan'},
      \ 'markdownLinkText': {'fg': '$cyan', 'sp': 'cyan', 'fmt': 'underline'},
      \ 'markdownHeadingDelimiter': { 'fg': '$red' },
      \ 'markdownBoldDelimiter': {'fg': '$grey'},
      \ 'markdownItalicDelimiter': {'fg': '$grey'},
      \ 'markdownBoldItalicDelimiter': {'fg': '$grey'},
      \ 'markdownCodeDelimiter': {'fg': '$grey'},
      \ 'markdownLinkDelimiter': {'fg': '$grey'},
      \ 'markdownLinkTextDelimiter': {'fg': '$grey'},
      \ 'VimwikiHeader1': { 'fg': "$red", 'fmt': "bold" },
      \ 'VimwikiHeader2': { 'fg': "$red", 'fmt': "bold" },
      \ 'VimwikiHeader3': { 'fg': "$red", 'fmt': "bold" },
      \ 'VimwikiHeader4': { 'fg': "$red" },
      \ 'VimwikiHeader5': { 'fg': "$red" },
      \ 'VimwikiHeader6': { 'fg': "$red" },
      \ 'VimwikiHeaderChar': { 'fg': "$red" },
      \ 'VimwikiBold': { 'fg': "$yellow", 'fmt': "bold" },
      \ 'VimwikiItalic': { 'fg': "$purple", 'fmt': "italic" },
      \ 'VimwikiBoldItalic': { 'fg': "$yellow", 'fmt': "bold,italic" },
      \ 'VimwikiUnderline': { 'sp': "$cyan", 'fmt': "underline" },
      \ 'VimwikiCode': { 'fg': "$green" },
      \ 'VimwikiPre': { 'fg': "$green" },
      \ 'VimwikiDelimiter': { 'fg': "$bg3" },
      \ 'VimwikiListTodo': { 'fg': "$purple" },
      \ 'VimwikiWeblink1': { 'fg': "$cyan", 'sp': "$cyan", 'fmt': "underline" },
      \ }

" Directional operation which won't mess up the history.
let g:_const_dir_l = "\<C-G>U\<Left>"
let g:_const_dir_d = "\<C-G>U\<Down>"
let g:_const_dir_u = "\<C-G>U\<Up>"
let g:_const_dir_r = "\<C-G>U\<Right>"
