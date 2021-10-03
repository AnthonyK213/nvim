" colorscheme
set termguicolors
set background=dark
let g:airline_theme = 'gruvbox'
augroup highlight_extend
  autocmd!
  au ColorScheme * call usr#vis#hi_extd()
augroup end
colorscheme gruvbox


" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled  = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_symbols = {}
let g:airline_symbols.branch = "\uE0A0"
let g:airline_mode_map = {
      \ '__'    : '-',
      \ 'c'     : 'C',
      \ 'i'     : 'I',
      \ 'ic'    : 'I',
      \ 'ix'    : 'I',
      \ 'n'     : 'N',
      \ 'multi' : 'M',
      \ 'ni'    : 'Ĩ',
      \ 'no'    : 'N',
      \ 'R'     : 'R',
      \ 'Rv'    : 'R',
      \ 's'     : 's',
      \ 'S'     : 'S',
      \ ''    : 'S',
      \ 't'     : 'T',
      \ 'v'     : 'v',
      \ 'V'     : 'V',
      \ ''    : 'B',
      \ }


" NERDTree
let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nn  <silent> <leader>op :NERDTreeToggle<CR>
nn  <silent> <M-e> :NERDTreeFocus<CR>
ino <silent> <M-e> <Esc>:NERDTreeFocus<CR>
tno <silent> <M-e> <C-\><C-N>:NERDTreeFocus<CR>


" FZF
nn <silent> <leader>fb :Buffers<CR>
nn <silent> <leader>ff :Files<CR>
nn <silent> <leader>fg :Rg<CR>


" signify
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '~'
let g:signify_sign_show_count = 0
let g:signify_sign_show_text  = 1
nmap <silent> <leader>hj <plug>(signify-next-hunk)
nmap <silent> <leader>hk <plug>(signify-prev-hunk)
nmap <silent> <leader>hJ 9999<plug>(signify-next-hunk)
nmap <silent> <leader>hK 9999<plug>(signify-prev-hunk)


" IndentLine
let g:indentLine_char = '¦'
augroup indentLine_set_conceal
  autocmd!
  au FileType markdown,vimwiki let b:indentLine_enabled=0
augroup end


" vim-table-mode
nn <silent> <leader>ta :TableAddFormula<CR>
nn <silent> <leader>tf :TableModeRealign<CR>
nn <silent> <leader>tc :TableEvalFormulaLine<CR>


" vim-ipairs
let g:pairs_map_ret = 0
let g:pairs_map_bak = 1
let g:pairs_map_spc = 1
let g:pairs_usr_extd = {
      \ "$"  : "$",
      \ "`"  : "`",
      \ "*"  : "*",
      \ "**" : "**",
      \ "***": "***",
      \ "<u>": "</u>"
      \ }
let g:pairs_usr_extd_map = {
      \ "<M-P>" : "`",
      \ "<M-I>" : "*",
      \ "<M-B>" : "**",
      \ "<M-M>" : "***",
      \ "<M-U>" : "<u>"
      \ }


" vimtex
let g:tex_flavor = 'latex'
if has("win32")
  let g:vimtex_view_general_viewer = 'SumatraPDF'
  let g:vimtex_view_general_options
        \ = '-reuse-instance -forward-search @tex @line @pdf'
elseif has("unix")
  let g:vimtex_view_general_viewer = 'zathura'
endif
let g:vimtex_view_general_options_latexmk = '-reuse-instance'
let g:vimtex_compiler_progname = 'nvr'


" vimwiki
let g:vimwiki_list = [{
      \ 'path' : expand(g:path_cloud . '/Documents/Agenda/'),
      \ 'path_html' : expand(g:path_cloud . '/Documents/Agenda/html/'),
      \ 'syntax' : 'default',
      \ 'ext' : '.wiki'
      \ }]
let g:vimwiki_folding = 'syntax'
let g:vimwiki_ext2syntax = { '.wikimd' : 'markdown' }


" vim-markdown
let g:vim_markdown_math = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_autowrite = 1
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 2
nn <silent> <leader>mh :Toch<CR>:resize 15<CR>
nn <silent> <leader>mv :call usr#misc#show_toc()<CR>
nn <silent> <leader>mm :call usr#misc#vim_markdown_math_toggle()<CR>


" markdown preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_preview_options = {
      \ 'mkit': {},
      \ 'katex': {},
      \ 'uml': {},
      \ 'maid': {},
      \ 'disable_sync_scroll': 0,
      \ 'sync_scroll_type': 'middle',
      \ 'hide_yaml_meta': 1,
      \ 'sequence_diagrams': {},
      \ 'flowchart_diagrams': {},
      \ 'content_editable': v:false
      \ }


" Snippet; Completion
if has('win32')
  let s:snippet_dir = expand('$localappdata/nvim/snippet')
elseif has('unix')
  let s:snippet_dir = expand('$HOME/.config/nvim/snippet')
endif

if g:plug_def_comp ==# 'asyncomplete'
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
        \ "\<C-N>" : usr#lib#get_char('b') =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
        \ "\<C-\>\<C-o>>>" . repeat(g:const_dir_r, &ts) : vsnip#jumpable(1) ?
        \ "\<Plug>(vsnip-jump-next)" : usr#lib#get_char('p') =~ '\v[a-z\._\u4e00-\u9fa5]' ?
        \ "\<Plug>(asyncomplete_force_refresh)" : "\<TAB>"
  im  <silent><expr> <S-TAB>
        \ pumvisible() ?
        \ "\<C-P>" : vsnip#jumpable(1) ?
        \ "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
  im  <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<Plug>(ipairs_enter)"

  " vim-vsnip
  let g:vsnip_snippet_dir = s:snippet_dir

  smap <silent><expr> <TAB>   vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)" : "<TAB>"
  smap <silent><expr> <S-TAB> vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-prev)" : "<S-TAB>"

elseif g:plug_def_comp ==# 'coc'
  call coc#config('snippets', {
        \ 'textmateSnippetsRoots': [
        \   s:snippet_dir
        \ ]
        \ })

  " Use tab for trigger completion with characters ahead and navigate.
  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
  " other plugin before putting this into your config.
  im <silent><expr> <TAB>
        \ pumvisible() ?
        \ "\<C-N>" : usr#lib#get_char('b') =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
        \ "\<C-\>\<C-o>>>" . repeat(g:const_dir_r, &ts) : coc#expandableOrJumpable() ?
        \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ usr#lib#get_char('p') =~ '\v[a-z\._\u4e00-\u9fa5]' ?
        \ coc#refresh() : "\<TAB>"
  im  <silent><expr> <S-TAB>
        \ pumvisible() ?
        \ "\<C-P>" : coc#expandableOrJumpable() ?
        \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ "\<S-TAB>"

  " Make <CR> auto-select the first completion item and notify coc.nvim to
  " format on enter, <cr> could be remapped by other vim plugin
  ino <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> <leader>g[ <Plug>(coc-diagnostic-prev)
  nmap <silent> <leader>g] <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> <leader>gf <Plug>(coc-definition)
  nmap <silent> <leader>gt <Plug>(coc-type-definition)
  nmap <silent> <leader>gi <Plug>(coc-implementation)
  nmap <silent> <leader>gr <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nn <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
      call CocActionAsync('doHover')
    else
      execute '!' . &keywordprg . " " . expand('<cword>')
    endif
  endfunction

  " Symbol renaming.
  nmap <leader>gn <Plug>(coc-rename)

  " Formatting selected code.
  xmap <leader>gm  <Plug>(coc-format-selected)
  nmap <leader>gm  <Plug>(coc-format-selected)

  augroup usr_coc_group
    autocmd!
    " Highlight the symbol and its references when holding the cursor.
    "au CursorHold * silent call CocActionAsync('highlight')
    " Setup formatexpr specified filetype(s).
    au FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Applying codeAction to the selected region.
  " Example: `<leader>aap` for current paragraph
  xmap <leader>ga  <Plug>(coc-codeaction-selected)
  nmap <leader>ga  <Plug>(coc-codeaction-selected)

  " Remap keys for applying codeAction to the current buffer.
  nmap <leader>gc  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>gq  <Plug>(coc-fix-current)

  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  " Remap <C-f> and <C-b> for scroll float windows/popups.
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nn <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nn <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    vn <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vn <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  endif

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  " Add `:Fold` command to fold current buffer.
  command! -nargs=? Fold :call CocAction('fold', <f-args>)

  " Add `:OR` command for organize imports of the current buffer.
  command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins that
  " provide custom statusline: lightline.vim, vim-airline.
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

endif
