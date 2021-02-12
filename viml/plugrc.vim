" Onedark
set termguicolors
set background=dark
colorscheme onedark
let g:airline_theme = 'onedark'


" FZF
let $FZF_DEFAULT_OPTS = "--layout=reverse"
nn <silent> <leader>bx :Buffers<CR>
nn <silent> <leader>ff :Files<CR>
nn <silent> <leader>fg :Rg<CR>


" NERDTree
let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nn  <silent> <leader>op :NERDTreeToggle<CR>
tno <silent> <leader>op <C-\><C-N>:NERDTreeToggle<CR>
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
nmap <silent> <leader>vj <plug>(signify-next-hunk)
nmap <silent> <leader>vk <plug>(signify-prev-hunk)
nmap <silent> <leader>vJ 9999<plug>(signify-next-hunk)
nmap <silent> <leader>vK 9999<plug>(signify-prev-hunk)
nn   <silent> <leader>vt :SignifyToggle<CR>


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


" vim-orgmode
"let g:org_indent=2
let agenda_path = expand(g:onedrive_path . "/Documents/Agenda/Agenda.org")
let g:org_agenda_files = [agenda_path]
command! OrgAgenda :exe ":tabnew" agenda_path


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


" vim-vsnip
if has('win32')
  let g:vsnip_snippet_dir = expand('$localappdata/nvim/snippet')
elseif has('unix')
  let g:vsnip_snippet_dir = expand('$HOME/.config/nvim/snippet')
endif
imap <expr><silent> <C-C><C-N> vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Nul>"
smap <expr><silent> <C-C><C-N> vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Nul>"
imap <expr><silent> <C-C><C-P> vsnip#jumpable(1) ? "<Plug>(vsnip-jump-prev)" : "<Nul>"
smap <expr><silent> <C-C><C-P> vsnip#jumpable(1) ? "<Plug>(vsnip-jump-prev)" : "<Nul>"


" deoplete
let g:deoplete#enable_at_startup = 1
function! s:check_back_bullet()
  return Lib_Get_Char('b') =~ '\v^\s*(\+|-|*|\d+\.)\s$'
endfunction
function! s:subrc_is_surrounded(match_list)
  return index(a:match_list, Lib_Get_Char('l') . Lib_Get_Char('n')) >= 0
endfunction
ino <silent><expr> <TAB>
      \ Lib_Get_Char('l') =~ '\v[a-z_\u4e00-\u9fa5]' ? "\<C-N>" :
      \ <SID>check_back_bullet() ? "\<C-\>\<C-o>V>" . repeat(lib_const_r, &ts) :
      \ "\<Tab>"
ino <silent><expr> <S-TAB>
      \ pumvisible() ?
      \ "\<C-p>" :
      \ "\<C-h>"
ino <silent><expr> <CR>
      \ pumvisible() ? "\<C-y>" :
      \ <SID>subrc_is_surrounded(['()', '[]', '{}']) ?
      \ "\<CR>\<C-\>\<C-o>O" :
      \ "\<CR>"
