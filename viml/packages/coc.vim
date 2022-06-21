let g:coc_global_extensions = [
      \ 'coc-explorer',
      \ 'coc-snippets',
      \ 'coc-vimtex'
      \ ]
let g:coc_config_table = {}

function s:coc_lsp_check(server, extension, enable="enable") abort
  let l:var_name = '_my_lsp_' . a:server
  if exists('g:' . l:var_name)
    let l:val = get(g:, l:var_name)
    if type(l:val) == v:t_bool
      if l:val
        call add(g:coc_global_extensions, a:extension)
      endif
      let g:coc_config_table[a:enable] = l:val
    elseif type(l:val) == v:t_dict
      if has_key(l:val, "enable") && l:val["enable"]
        call add(g:coc_global_extensions, a:extension)
        for [l:k, l:v] in items(l:val)
          if l:k ==# "enable"
            let g:coc_config_table[a:enable] = v:true
          else
            let g:coc_config_table[l:k] = l:v
          endif
        endfor
      else
        let g:coc_config_table[a:enable] = v:false
      endif
    else
      call my#lib#notify_err("Please check `lsp` in nvimrc.")
    endif
  endif
endfunction

function! s:coc_show_doc() abort
  if (index(['vim', 'help'], &filetype) >= 0)
    let l:word = my#lib#get_word()[0]
    try
      exe 'h' l:word
    catch
      echo "No help for '" . l:word . "'"
    endtry
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  endif
endfunction

call s:coc_lsp_check('clangd', 'coc-clangd', 'clangd.enabled')
call s:coc_lsp_check('jedi_language_server', 'coc-jedi', 'jedi.enable')
call s:coc_lsp_check('omnisharp', 'coc-omnisharp')
call s:coc_lsp_check('powershell_es', 'coc-powershell')
call s:coc_lsp_check('rust_analyzer', 'coc-rust-analyzer', 'rust-analyzer.enable')
call s:coc_lsp_check('sumneko_lua', 'coc-sumneko-lua', 'sumneko-lua.enable')
call s:coc_lsp_check('vimls', 'coc-vimlsp', 'vimlsp.diagnostic.enable')
let s:snippet_dir = my#compat#stdpath('config') . '/snippet'
call extend(g:coc_config_table, {
      \ 'snippets.textmateSnippetsRoots' : [s:snippet_dir],
      \ 'snippets.ultisnips.enable' : v:false,
      \ 'snippets.snipmate.enable' : v:false,
      \ 'explorer.keyMappings.global' : {
        \ 's' : 'open:vsplit',
        \ 'i' : 'open:split',
        \ 'o' : 'systemExecute',
        \ 'u' : ['wait', 'gotoParent'],
        \ 'C' : ["wait", "expandable?", "cd", "open"],
        \ 'D' : ["delete"],
        \ 'H' : ["toggleHidden"],
        \ '<cr>' : [
          \    "expandable?",
          \    ["expanded?", "collapse", "expand"],
          \    "open"
          \ ],
          \ },
          \ })
for [s:key, s:val] in items(g:coc_config_table)
  call coc#config(s:key, s:val)
endfor

" Input.
ino <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-G>u\<CR>\<C-R>=coc#on_enter()\<CR>"
im <silent><expr> <TAB>
      \ pumvisible() ?
      \ "\<C-N>" : my#lib#get_context()['b'] =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
      \ "\<C-\>\<C-o>>>" . repeat(g:_const_dir_r, &ts) : coc#expandableOrJumpable() ?
      \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ my#lib#get_context()['p'] =~ '\v[a-z\._\u4e00-\u9fa5]' ?
      \ coc#refresh() : "\<TAB>"
im  <silent><expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-P>" : coc#expandableOrJumpable() ?
      \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ "\<S-TAB>"
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <leader>l[ <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>l] <Plug>(coc-diagnostic-next)
" Goto code navigation.
nmap <silent> <F12>      <Plug>(coc-definition)
nmap <silent> <leader>lf <Plug>(coc-definition)
nmap <silent> <leader>lt <Plug>(coc-type-definition)
nmap <silent> <leader>li <Plug>(coc-implementation)
nmap <silent> <leader>lr <Plug>(coc-references)
" Use K to show documentation in preview window.
nn <silent> K :call <SID>coc_show_doc()<CR>
" Symbol renaming.
nmap <leader>ln <Plug>(coc-rename)
" Formatting selected code.
nmap <leader>lm <Plug>(coc-format)
xmap <leader>lm <Plug>(coc-format-selected)
" Applying codeAction to the selected region.
xmap <leader>la <Plug>(coc-codeaction-selected)
nmap <leader>la <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>lc <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>lq <Plug>(coc-fix-current)
" Map function and class text objects
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Remap <C-F> and <C-B> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nn <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
  nn <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
  vn <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
  vn <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
endif
" Coc-explorer
nn  <silent> <leader>op :CocCommand explorer<CR>
nn  <silent> <M-e> :CocCommand explorer<CR>
ino <silent> <M-e> <Esc>:CocCommand explorer<CR>
tno <silent> <M-e> <C-\><C-N>:CocCommand explorer<CR>

augroup my_coc_group
  autocmd!
  " Highlight the symbol and its references when holding the cursor.
  au CursorHold * silent call CocActionAsync('highlight')
  " Setup formatexpr specified filetype(s).
  au FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add (Neo)Vim's native statusline support.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
