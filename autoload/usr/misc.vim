" Background toggle.
function! usr#misc#bg_toggle()
  let &bg = &bg ==# 'dark' ? 'light' : 'dark'
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
        \ 'rust' : "build\nclean\ncheck\nrustc",
        \ 'tex'  : "biber\nbibtex",
        \ }
  if has_key(l:option_table, &filetype)
    return l:option_table[&filetype]
  else
    return ''
  endif
endfunction

" vim-markdown toggle math display.
function! usr#misc#vim_markdown_math_toggle()
  let g:vim_markdown_math = 1 - g:vim_markdown_math
  syntax off | syntax on
endfunction

" Show table of contents.
function! usr#misc#show_toc()
  if &ft ==? 'markdown'
    if exists(':Tocv')
      Tocv
      vertical resize 50
    endif
  elseif &ft ==? 'tex'
    if exists(':VimtexTocToggle')
      VimtexTocToggle
    endif
  else
    echo 'Filetype' &ft 'does not support Toc.'
  endif
endfunction

" nvim-tree open file with os default application.
function! usr#misc#nvim_tree_os_open()
lua <<EOF
  local node = require('nvim-tree.lib').get_node_at_cursor()
  if node then
    require('utility/util').open_file_or_url(node.absolute_path)
  end
EOF
endfunction

" Neovim nightly update.
function! usr#misc#nvim_nightly_upgrade(...)
  let l:proxy_args = a:0 == 0 ? "" : a:1
  let l:script_name = "nvim_nightly_upgrade"
  if has('win32')
    let l:cmd = expand("$LOCALAPPDATA") . '/nvim/shell/' .
          \ l:script_name . '_win.ps1 -proxy ' . l:proxy_args
    lua require('utility/lib').belowright_split(30)
    exe 'term powershell' l:cmd
  elseif has('unix')
    let l:cmd = expand("$HOME/.config") . '/nvim/shell/' .
          \ l:script_name . '_linux.sh ' . l:proxy_args
    lua require('utility/lib').belowright_split(30)
    exe 'term bash' l:cmd
  endif
endfunction
