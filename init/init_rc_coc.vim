" Coc.nvim
let g:coc_global_extentions = [
      \ 'coc-rls',
      \ 'coc-python',
      \ 'coc-vimtex'
      \ ]

"" Coc functions
function! s:check_back_char() abort
  return Lib_Get_Char('l') =~ '\v[a-z_\u4e00-\u9fa5]'
endfunction

function! s:check_back_bullet()
  return Lib_Get_Char('b') =~ '\v^\s*(\+|-|*)\s$'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
ino <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_char() ? coc#refresh() :
      \ <SID>check_back_bullet() ? repeat(g:custom_l, 2) . "\<Tab>" . repeat(g:custom_r, 2) :
      \ "\<TAB>"
ino <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
ino <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nn <silent> K :call <SID>show_documentation()<CR>

" Highlight symbol under cursor on CursorHold
augroup hlsymbol
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

" <leader> j*  -> for no reason?
" <leader> jl* -> l(ist)
" Remap for rename current word
nmap <leader>jr <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>jf  <Plug>(coc-format-selected)
nmap <leader>jf  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<localleader>aap` for current paragraph
xmap <leader>js  <Plug>(coc-codeaction-selected)
nmap <leader>js  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ja  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>jc  <Plug>(coc-fix-current)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` to fold current buffer
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
" use `:OR` for organize import of current buffer
command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

"" Using CocList
""" Show all diagnostics
nn <silent><nowait> <leader>jla  :<C-u>CocList diagnostics<cr>
""" Manage extensions
nn <silent><nowait> <leader>jle  :<C-u>CocList extensions<cr>
""" Show commands
nn <silent><nowait> <leader>jlc  :<C-u>CocList commands<cr>
""" Find symbol of current document
nn <silent><nowait> <leader>jlo  :<C-u>CocList outline<cr>
""" Search workspace symbols
nn <silent><nowait> <leader>jls  :<C-u>CocList -I symbols<cr>
""" Do default action for next item.
nn <silent><nowait> <leader>jlj  :<C-u>CocNext<CR>
""" Do default action for previous item.
nn <silent><nowait> <leader>jlk  :<C-u>CocPrev<CR>
""" Resume latest coc list
nn <silent><nowait> <leader>jlp  :<C-u>CocListResume<CR>

"" Float window scroll
nn <nowait><expr> <C-f>
      \ coc#float#has_scroll() ?
      \ coc#float#scroll(1) :
      \ "\<C-f>"
nn <nowait><expr> <C-b>
      \ coc#float#has_scroll() ?
      \ coc#float#scroll(0) :
      \ "\<C-b>"
ino <nowait><expr> <C-f>
      \ coc#float#has_scroll() ?
      \ "\<c-r>=coc#float#scroll(1)\<cr>" : 
      \ col('.') >= col('$') ? "\<C-o>+" : "\<Right>"
ino <nowait><expr> <C-b>
      \ coc#float#has_scroll() ?
      \ "\<c-r>=coc#float#scroll(0)\<cr>" :
      \ col('.') == 1 ? "\<C-o>-\<C-o>$" : "\<Left>"
