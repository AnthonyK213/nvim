""" Colorscheme
" Colorscheme Onedark
colorscheme onedark
" Colorscheme One
"colorscheme one
"let g:airline_theme='one'


""" NERDTree
augroup nerdtreebehave
    autocmd!
    " Open NERDTree automatically when vim starts up on opening a directory
    autocmd StdinReadPre * let s:std_in = 1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
    " Close vim if the only window left open is a NERDTree
    "autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup end
let g:NERDTreeDirArrowExpandable  = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nnoremap <silent> <F3> :NERDTreeToggle<CR>
inoremap <silent> <F3> <Esc>:NERDTreeToggle<CR>
tnoremap <silent> <F3> <C-\><C-N>:NERDTreeToggle<CR>
nnoremap <silent> <M-n> :NERDTreeFocus<CR>
inoremap <silent> <M-n> <Esc>:NERDTreeFocus<CR>
tnoremap <silent> <M-n> <C-\><C-N>:NERDTreeFocus<CR>


""" signify
" Signs
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '~'
" Disable the numbers disctracting
let g:signify_sign_show_count = 0
let g:signify_sign_show_text  = 1
" <leader> h* -> h(unk)
nnoremap <silent> <leader>ht :SignifyToggle<CR>
nmap <leader>hj <plug>(signify-next-hunk)
nmap <leader>hk <plug>(signify-prev-hunk)
nmap <leader>hJ 9999<plug>(signify-next-hunk)
nmap <leader>hK 9999<plug>(signify-prev-hunk)


""" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled  = 1
" Symbols
let g:airline_symbols = {}
let g:airline_symbols.branch = ''
" Separators
"     ;     ;    
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
"let g:airline#extensions#tabline#left_sep = ''
"let g:airline#extensions#tabline#left_alt_sep = ''
"let g:airline#extensions#tabline#right_sep = ''
"let g:airline#extensions#tabline#right_alt_sep = ''
" Tab
let g:airline#extensions#tabline#formatter = 'unique_tail'
" Color
let g:airline_theme = 'onedark'


""" vim-markdown
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_math = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_folding_disabled = 1
"let g:vim_markdown_override_foldtext = 0
"let g:vim_markdown_folding_level = 6
"let g:vim_markdown_no_default_key_mappings = 1
"let g:vim_markdown_auto_insert_bullets = 0
" <leader> m* -> m(arkdown)
nnoremap <silent> <leader>mh :Toch<CR>:resize 15<CR>
nnoremap <silent> <leader>mv :Tocv<CR>:vertical resize 50<CR>


""" markdown preview
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


""" vim-table-mode
augroup vimtable
    autocmd!
    au BufEnter *    let g:table_mode_corner = '+'
    au BufEnter *.md let g:table_mode_corner = '|'
augroup end
" <leader> t* -> t(able-mode)
nnoremap <silent> <leader>tf :TableModeRealign<CR>
nnoremap <silent> <leader>ta :TableAddFormula<CR>
nnoremap <silent> <leader>tc :TableEvalFormulaLine<CR>


""" vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_general_viewer = 'SumatraPDF'
let g:vimtex_view_general_options
    \ = '-reuse-instance -forward-search @tex @line @pdf'
let g:vimtex_view_general_options_latexmk = '-reuse-instance'
let g:vimtex_compiler_progname = 'nvr'


""" vim-orgmode
"let g:org_indent=2
let agenda_path = expand(g:onedrive_path . "/Documents/Agenda/Agenda.org")
let g:org_agenda_files = [agenda_path]
command! Agenda :exe ":tabnew " . agenda_path


""" IndentLine
let g:indentLine_char = '¦'
let g:indentLine_setConceal = 1
augroup indentline
    autocmd!
    au BufEnter,BufRead * let g:indentLine_enabled = 1
    au BufEnter,BufRead *.md,*.org,*.json,*.txt,*.tex let g:indentLine_enabled = 0
augroup end


""" Coc.nvim
let g:coc_global_extentions = [
    "\ 'coc-pairs',
    \ 'coc-python',
    \ 'coc-rls',
    \ 'coc-vimtex'
  \ ]

" Coc functions
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
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
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
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
nnoremap <silent> K :call <SID>show_documentation()<CR>

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

" Using CocList
" Show all diagnostics
nnoremap <silent><nowait> <leader>jla  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <leader>jle  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <leader>jlc  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <leader>jlo  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <leader>jls  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <leader>jlj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <leader>jlk  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <leader>jlp  :<C-u>CocListResume<CR>

" Float window scroll
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
