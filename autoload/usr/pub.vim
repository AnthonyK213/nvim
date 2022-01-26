let s:var = {}
if has("win32")
  let s:var["start"] = ['cmd', '/c', 'start', '""']
  let s:var["shell"] = get(g:, 'default_shell', ['powershell.exe', '-nologo'])
  let s:var["ccomp"] = get(g:, 'default_c_compiler', 'gcc')
elseif has("unix")
  let s:var["start"] = 'xdg-open'
  let s:var["shell"] = get(g:, 'default_shell', 'bash')
  let s:var["ccomp"] = get(g:, 'default_c_compiler', 'gcc')
elseif has("mac")
  let s:var["start"] = 'open'
  let s:var["shell"] = get(g:, 'default_shell', 'zsh')
  let s:var["ccomp"] = get(g:, 'default_c_compiler', 'clang')
endif

function! usr#pub#var(arg) abort
  return s:var[a:arg]
endfunction
