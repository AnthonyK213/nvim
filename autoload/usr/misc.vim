" Background toggle.
function! usr#misc#bg_toggle()
  if exists("g:lock_background") && g:lock_background
    return
  else
    let &bg = &bg ==# 'dark' ? 'light' : 'dark'
  endif
endfunction

" Mouse toggle.
function! usr#misc#mouse_toggle()
  if &mouse ==# 'a'
    let &mouse = ''
    echom 'Mouse disabled'
  else
    let &mouse = 'a'
    echom 'Mouse enabled'
  endif
endfunction

" Run code complete option list.
function! usr#misc#run_code_option(arglead, cmdline, cursorpos) abort
  let l:option_table = {
        \ 'c'    : "build\ncheck",
        \ 'cs'   : "exe\nwinexe\nlibrary\nmodule",
        \ 'lisp' : "build",
        \ 'lua'  : "nojit",
        \ 'rust' : "build\nclean\ncheck",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return l:option_table[&filetype]
  else
    return ''
  endif
endfunction

" Show table of contents.
function! usr#misc#show_toc()
  if &ft ==? 'tex'
    if exists(':VimtexTocToggle')
      VimtexTocToggle
    endif
  elseif &ft ==? 'json'
    if exists(':JqxList')
      JqxList
    endif
  else
    echo 'No Toc support for current filetype.'
  endif
endfunction

" nvim-tree open file with os default application.
function! usr#misc#nvim_tree_sys_open()
lua << EOF
  local node = require('nvim-tree.lib').get_node_at_cursor()
  if node then
    require('utility.util').open_path_or_url(node.absolute_path)
  end
EOF
endfunction

" Set background according to time.
function! usr#misc#time_background()
lua << EOF
  local timer = vim.loop.new_timer()
  timer:start(0, 600, vim.schedule_wrap(function()
    if not vim.g.lock_background then return end
    local hour = tonumber(os.date('%H'))
    local bg = (hour > 6 and hour < 18) and 'light' or 'dark'
    if vim.o.bg ~= bg then vim.o.bg = bg end
  end))
EOF
endfunction

" Source vim file.
function! usr#misc#vim_source(file) abort
  call v:lua.require('utility.lib').vim_source(a:file)
endfunction

" Open opt.lua.
function! usr#misc#open_opt()
lua << EOF
  local myvimrc_dir = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":p:h")
  require("utility.util").edit_file(myvimrc_dir.."/lua/core/opt.lua", false)
  vim.api.nvim_set_current_dir(myvimrc_dir)
EOF
endfunction

" Neovim nightly update.
function! usr#misc#nvim_nightly_upgrade(...)
  let l:proxy_args = a:0 == 0 ? "" : a:1
  let l:script_name = "nvim_nightly_upgrade"
  if has('win32')
    let l:cmd = expand("$LOCALAPPDATA") . '/nvim/shell/' .
          \ l:script_name . '_win.ps1 -proxy ' . l:proxy_args
    lua require('utility.lib').belowright_split(30)
    exe 'term powershell' l:cmd
  elseif has('unix')
    let l:cmd = expand("$HOME/.config") . '/nvim/shell/' .
          \ l:script_name . '_linux.sh ' . l:proxy_args
    lua require('utility.lib').belowright_split(30)
    exe 'term bash' l:cmd
  endif
endfunction
