" Background toggle.
function! usr#misc#bg_toggle() abort
  if exists("g:lock_background") && g:lock_background
    return
  else
    let &bg = &bg ==# 'dark' ? 'light' : 'dark'
  endif
endfunction

" Mouse toggle.
function! usr#misc#mouse_toggle() abort
  if &mouse ==# 'a'
    let &mouse = ''
    echom 'Mouse disabled'
  else
    let &mouse = 'a'
    echom 'Mouse enabled'
  endif
endfunction

" `CodeRun` complete option list.
function! usr#misc#run_code_option(arglead, cmdline, cursorpos) abort
  let l:option_table = {
        \ 'c'    : "build\ncheck",
        \ 'cs'   : "lib\nmod\nwin",
        \ 'lisp' : "build",
        \ 'lua'  : "nojit",
        \ 'rust' : "build\ncheck\nclean\ntest",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return split(l:option_table[&filetype], "\n")
  else
    return []
  endif
endfunction

" `NvimUpgrade` complete option list.
function! usr#misc#nvim_upgrade_option(arglead, cmdline, cursorpos) abort
  return ['stable', 'nightly']
endfunction

" Source vim file.
function! usr#misc#vim_source(file) abort
  call v:lua.require('utility.lib').vim_source(a:file)
endfunction

" Open opt.lua.
function! usr#misc#open_opt() abort
  let l:cfg = stdpath("config")
  let l:opt = l:cfg . "/opt.json"
  if empty(glob(l:opt))
    exe 'e' l:opt
    call nvim_paste("{}", v:true, -1)
  else
    call v:lua.require("utility.util").edit_file(l:opt, v:false)
  endif
  call nvim_set_current_dir(l:cfg)
endfunction

" Set background according to time.
function! usr#misc#time_background() abort
lua << EOF
  local timer = vim.loop.new_timer()
  timer:start(0, 600, vim.schedule_wrap(function ()
    if not vim.g.lock_background then return end
    local hour = tonumber(os.date('%H'))
    local bg = (hour > 6 and hour < 18) and 'light' or 'dark'
    if vim.o.bg ~= bg then vim.o.bg = bg end
  end))
EOF
endfunction
