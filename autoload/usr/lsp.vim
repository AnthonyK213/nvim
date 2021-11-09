let g:coc_global_extensions = [
      \ 'coc-snippets'
      \ ]
let g:coc_config_table = {}

function s:check(key, extension, config='') abort
  if has_key(g:default_lsp_table, a:key)
    let l:val = g:default_lsp_table[a:key]
    if type(l:val) == 6
      if l:val
        call add(g:coc_global_extensions, a:extension)
      endif
    elseif type(l:val) == 4
      if l:val['enable']
        call add(g:coc_global_extensions, a:extension)
        if l:val['path'] != v:null
          let g:coc_config_table[a:config] = l:val['path']
        endif
      endif
    else
      echoerr("Please check `g:default_lsp_table` at key '" . a:key . "'.")
    endif
  endif
endfunction

function usr#lsp#setup() abort
  call s:check('clangd', 'coc-clangd')
  call s:check('jedi_language_server', 'coc-jedi')
  call s:check('powershell_es', 'coc-powershell')
  call s:check('omnisharp', 'coc-omnisharp', 'omnisharp.path')
  call s:check('rls', 'coc-rls')
  call s:check('texlab', 'coc-texlab')
  call s:check('vimls', 'coc-vimlsp')
endfunction
