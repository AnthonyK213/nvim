" asyncomplete.vim
let g:asyncomplete_auto_pop = 1
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_min_chars = 2
let g:asyncomplete_buffer_clear_cache = 1

call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
      \ 'name': 'buffer',
      \ 'allowlist': ['*'],
      \ 'blocklist': [],
      \ 'completor': function('asyncomplete#sources#buffer#completor'),
      \ 'config': {
        \   'max_buffer_size': 5000000,
        \ },
        \ }))

im  <silent><expr> <TAB>
      \ pumvisible() ?
      \ "\<C-N>" : my#lib#get_char()['b'] =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
      \ "\<C-\>\<C-o>>>" . repeat(g:_const_dir_r, &ts) : vsnip#jumpable(1) ?
      \ "\<Plug>(vsnip-jump-next)" : my#lib#get_char()['p'] =~ '\v[a-z\._\u4e00-\u9fa5]' ?
      \ "\<Plug>(asyncomplete_force_refresh)" : "\<TAB>"
im  <silent><expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-P>" : vsnip#jumpable(-1) ?
      \ "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
im  <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<Plug>(ipairs_enter)"

" vim-vsnip
let g:vsnip_snippet_dir = my#compat#stdpath('config') . '/snippet'

smap <silent><expr> <TAB>   vsnip#jumpable(1)  ? "\<Plug>(vsnip-jump-next)" : "<TAB>"
smap <silent><expr> <S-TAB> vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "<S-TAB>"
