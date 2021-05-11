" Onedark
set termguicolors
set background=dark
colorscheme onedark
let g:airline_theme = 'onedark'


" FZF
"let $FZF_DEFAULT_OPTS = "--layout=reverse"
nn <silent> <leader>fb :Buffers<CR>
nn <silent> <leader>ff :Files<CR>
nn <silent> <leader>fg :Rg<CR>


" NERDTree
let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nn  <silent> <leader>op :NERDTreeToggle<CR>
nn  <silent> <M-e> :NERDTreeFocus<CR>
ino <silent> <M-e> <Esc>:NERDTreeFocus<CR>
tno <silent> <M-e> <C-\><C-N>:NERDTreeFocus<CR>


" signify
"" Signs
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '~'
"" Disable the numbers disctracting
let g:signify_sign_show_count = 0
let g:signify_sign_show_text  = 1
nmap <silent> <leader>hj <plug>(signify-next-hunk)
nmap <silent> <leader>hk <plug>(signify-prev-hunk)
nmap <silent> <leader>hJ 9999<plug>(signify-next-hunk)
nmap <silent> <leader>hK 9999<plug>(signify-prev-hunk)


" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled  = 1
"" Symbols
let g:airline_symbols = {}
let g:airline_symbols.branch = ''
"" Mode abbr.
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
      \ 's'     : 'S',
      \ 'S'     : 'S',
      \ ''    : 'S',
      \ 't'     : 'T',
      \ 'v'     : 'V',
      \ 'V'     : 'Ṿ',
      \ ''    : 'Ṽ',
      \ }
"" Tab
let g:airline#extensions#tabline#formatter = 'unique_tail'


" vim-markdown
function! s:vim_markdown_math_toggle()
  let g:vim_markdown_math = 1 - g:vim_markdown_math
  syn off | syn on
endfunction
let g:vim_markdown_math = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_autowrite = 1
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 2
nn <silent> <leader>mh :Toch<CR>:resize 15<CR>
nn <silent> <leader>mv :Tocv<CR>:vertical resize 50<CR>
nn <silent> <leader>mm :call <SID>vim_markdown_math_toggle()<CR>


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


" vim-table-mode
nn <silent> <leader>ta :TableAddFormula<CR>
nn <silent> <leader>tf :TableModeRealign<CR>
nn <silent> <leader>tc :TableEvalFormulaLine<CR>


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
      \ 'path' : expand(g:onedrive_path . '/Documents/Agenda/'),
      \ 'path_html' : expand(g:onedrive_path . '/Documents/Agenda/html/'),
      \ 'syntax' : 'default',
      \ 'ext' : '.wiki'
      \ }]
let g:vimwiki_folding = 'syntax'
let g:vimwiki_ext2syntax = { '.wikimd' : 'markdown' }


" IndentLine
let g:indentLine_char = '¦'
let g:indentLine_setConceal = 1


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


" vim-vsnip & asyncomplete.vim
if has('win32')
  let g:vsnip_snippet_dir = expand('$localappdata/nvim/snippet')
elseif has('unix')
  let g:vsnip_snippet_dir = expand('$HOME/.config/nvim/snippet')
endif

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
      \ "\<Plug>(vsnip-jump-next)" : usr#lib#get_char('l') =~ '\v[a-z\._\u4e00-\u9fa5]' ?
      \ "\<Plug>(asyncomplete_force_refresh)" : "\<TAB>"
im  <silent><expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-P>" : vsnip#jumpable(1) ?
      \ "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
im  <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<Plug>(ipairs_enter)"
smap <silent><expr> <TAB>   vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)" : "<TAB>"
smap <silent><expr> <S-TAB> vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-prev)" : "<S-TAB>"
