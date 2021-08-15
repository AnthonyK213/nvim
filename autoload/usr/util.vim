"" Escape string for URL.
let s:esc_url = {
      \ " " : "\\\%20", "!" : "\\\%21", '"' : "\\\%22",
      \ "#" : "\\\%23", "$" : "\\\%24", "%" : "\\\%25",
      \ "&" : "\\\%26", "'" : "\\\%27", "(" : "\\\%28",
      \ ")" : "\\\%29", "*" : "\\\%2A", "+" : "\\\%2B",
      \ "," : "\\\%2C", "/" : "\\\%2F", ":" : "\\\%3A",
      \ ";" : "\\\%3B", "<" : "\\\%3C", "=" : "\\\%3D",
      \ ">" : "\\\%3E", "?" : "\\\%3F", "@" : "\\\%40",
      \ "\\": "\\\%5C", "|" : "\\\%7C", "\n": "\\\%20",
      \ "\r": "\\\%20", "\t": "\\\%20"
      \ }


" Functions
"" Open terminal and launch shell
function! usr#util#terminal()
  call usr#lib#belowright_split(15)
  silent exe 'terminal' usr#pub#var().shell
  setl nonu
endfunction

"" Open and edit test file in vim.
function! usr#util#edit_file(file_path, chdir)
  let l:path = expand(a:file_path)
  if empty(expand("%:t"))
    silent exe 'e' l:path
  else
    silent exe 'tabnew' l:path
  endif
  if a:chdir
    silent exe 'cd %:p:h'
  endif
endfunction

"" Open file with system default browser.
function! usr#util#open_file(file_path)
  if empty(glob(a:file_path))
    return
  end
  let l:file_path_esc = '"' . escape(expand(a:file_path), '%#') . '"'
  let l:cmd = has("win32") ? usr#pub#var().start . ' ""' : usr#pub#var().start
  silent exe '!' . l:cmd l:file_path_esc
endfunction

"" Search web
function! usr#util#search_web(mode, site)
  let l:del_list = [
        \ ".", ",", "'", "\"",
        \ ";", "*", "~", "`", 
        \ "(", ")", "[", "]", "{", "}"
        \ ]
  if a:mode ==? "n"
    let l:search_obj = usr#lib#str_escape(usr#lib#get_clean_cWORD(l:del_list), s:esc_url)
  elseif a:mode ==? "v"
    let l:search_obj = usr#lib#str_escape(usr#lib#get_visual_selection(), s:esc_url)
  endif
  let l:url_raw = a:site . l:search_obj
  let l:url_arg = has("win32") ? l:url_raw : '"' . l:url_raw . '"'
  silent exe '!' . usr#pub#var().start l:url_arg
  redraw
endfunction
