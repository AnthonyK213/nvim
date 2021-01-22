" NERDTree
augroup nerdtree_behave
  autocmd!
  " Open NERDTree automatically when vim starts up on opening a directory
  autocmd StdinReadPre * let s:std_in = 1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
augroup end


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


" markdown preview
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
augroup vimtable
  autocmd!
  au BufEnter *    let g:table_mode_corner = '+'
  au BufEnter *.md let g:table_mode_corner = '|'
augroup end


" vim-orgmode
let agenda_path = expand(g:onedrive_path . "/Documents/Agenda/Agenda.org")
let g:org_agenda_files = [agenda_path]
command! OrgAgenda :exe ":tabnew" agenda_path


" IndentLine
augroup indentline
  autocmd!
  au BufEnter,BufRead * let g:indentLine_enabled = 1
  au BufEnter,BufRead *.md,*.org,*.json,*.txt,*.tex let g:indentLine_enabled = 0
augroup end


" vim-ipairs
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


" Coc.nvim
let g:coc_global_extensions = [
      \ 'coc-rls',
      \ 'coc-python',
      \ 'coc-vimtex'
      \ ]

"" Coc functions
function! s:check_back_char() abort
  return Lib_Get_Char('l') =~ '\v[a-z_\u4e00-\u9fa5]'
endfunction

function! s:check_back_bullet()
  return Lib_Get_Char('b') =~ '\v^\s*(\+|-|*|\d+\.)\s$'
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

"" Use tab for trigger completion with characters ahead and navigate.
"" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
ino <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_char() ? coc#refresh() :
      \ <SID>check_back_bullet() ? "\<C-o>V>" . repeat(lib_const_r, &ts) :
      \ "\<TAB>"
ino <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"" Make <CR> auto-select the first completion item and notify coc.nvim to
"" format on enter, <cr> could be remapped by other vim plugin
ino <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>U\<CR>\<c-r>=coc#on_enter()\<CR>"

"" Use `[g` and `]g` to navigate diagnostics
"" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

"" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"" Use K to show documentation in preview window
nn <silent> K :call <SID>show_documentation()<CR>

"" Highlight symbol under cursor on CursorHold
augroup hlsymbol
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

"" Remap for rename current word
nmap <leader>Cr <Plug>(coc-rename)

"" Remap for format selected region
xmap <leader>Cf  <Plug>(coc-format-selected)
nmap <leader>Cf  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

"" Remap for do codeAction of selected region, ex: `<localleader>aap` for current paragraph
xmap <leader>Cs  <Plug>(coc-codeaction-selected)
nmap <leader>Cs  <Plug>(coc-codeaction-selected)

"" Remap for do codeAction of current line
nmap <leader>Ca  <Plug>(coc-codeaction)
"" Fix autofix problem of current line
nmap <leader>Cc  <Plug>(coc-fix-current)

"" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
"" Use `:Fold` to fold current buffer
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
"" use `:OR` for organize import of current buffer
command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport')

"" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

"" Using CocList
""" Show all diagnostics
nn <silent><nowait> <leader>Cla  :<C-u>CocList diagnostics<cr>
""" Manage extensions
nn <silent><nowait> <leader>Cle  :<C-u>CocList extensions<cr>
""" Show commands
nn <silent><nowait> <leader>Clc  :<C-u>CocList commands<cr>
""" Find symbol of current document
nn <silent><nowait> <leader>Clo  :<C-u>CocList outline<cr>
""" Search workspace symbols
nn <silent><nowait> <leader>Cls  :<C-u>CocList -I symbols<cr>
""" Do default action for next item.
nn <silent><nowait> <leader>Clj  :<C-u>CocNext<CR>
""" Do default action for previous item.
nn <silent><nowait> <leader>Clk  :<C-u>CocPrev<CR>
""" Resume latest coc list
nn <silent><nowait> <leader>Clp  :<C-u>CocListResume<CR>

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
