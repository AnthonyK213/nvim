let g:dashboard_default_executive = 'clap'
let g:dashboard_custom_header = [
      \ '                                                    ',
      \ ' ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
      \ ' ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
      \ ' ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
      \ ' ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      \ ' ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      \ ' ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      \ '                                                    ',
      \ ]
function! s:d(item, kbd, length) abort
  let l:spc_count = a:length - strdisplaywidth(a:item . a:kbd)
  if l:spc_count <= 0
    let l:spc_count = 1
  endif
  return a:item . repeat(" ", l:spc_count) . a:kbd
endfunction
let g:dashboard_custom_section = {
      \ 'new_file':     { 'description': [s:d('∅ Empty File',   'e', 50)], 'command': 'enew' },
      \ 'find_files':   { 'description': [s:d('⊕ Find File',    'f', 50)], 'command': 'Clap files' },
      \ 'load_session': { 'description': [s:d('↺ Load Session', 's', 50)], 'command': 'LoadSession' },
      \ 'options':      { 'description': [s:d('⚙ Options',      ',', 50)], 'command': function('my#compat#open_opt') },
      \ 'plug_update':  { 'description': [s:d('⟲ Plug Update',  'p', 50)], 'command': 'PlugUpdate' },
      \ 'quit_vim':     { 'description': [s:d('⊗ Quit Vim',     'q', 50)], 'command': 'qa' },
      \ }
