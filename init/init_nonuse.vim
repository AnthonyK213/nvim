Plug 'rakr/vim-one'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'


" One
colorscheme one
let g:airline_theme='one'


" vim-airline
""     ;     ;    
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''


" vim-markdown
let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_folding_level = 6
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_auto_insert_bullets = 0


" deoplete
let g:deoplete#enable_at_startup=1
set completeopt-=preview


set relativenumber
set foldenable
set foldmethod=syntax
set foldlevelstart=99
set foldmethod=manual
set clipboard=unnamed

set whichwrap=b,s,<,>,[,]
set backspace=indent,eol,start whichwrap+=<,>,[,]
set textwidth=0
set wrapmargin=0
set formatoptions-=tc
set formatoptions+=l
set signcolumn=number

highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE

augroup remember_folds
    autocmd!
    au BufWinLeave ?* mkview 1
    au BufWinEnter ?* silent! loadview 1
augroup end

" signify
augroup signify
    autocmd!
    au BufEnter * let g:signify_disable_by_default = 0
    au BufEnter *.md,*.org let g:signify_disable_by_default = 1
augroup end

" Git util
function! GetGitBranch()
    let git_root_path = Lib_Get_Git_Root()
    if git_root_path[0] == 1
        let git_head_path = git_root_path[1]. "/.git/HEAD"
        return split(readfile(git_head_path)[0], '/')[-1]
    elseif
        echo 'Not a git repository.'
    endif
endfunction

" Determines whether a character is a letter or a symbol.
function! Lib_Is_Letter(char)
    let code = char2nr(a:char)
    if code > 128
        return 0
    elseif code >= 48 && code <= 57
        return 1
    elseif code >= 65 && code <= 90
        return 1
    elseif code >= 97 && code <= 122
        return 1
    else
        return 0
    endif
endfunction

set ruler

augroup TreeSitterSetting
    autocmd!
    au BufEnter *.c call TreeSitterSetting()
augroup end

function! TreeSitterSetting()
lua << EOF
vim.treesitter.require_language("c", "D:/App/Neovim/lib/nvim/parser/c.dll")
parser = vim.treesitter.get_parser(0, "c")
tstree = parser:parse()
EOF
endfunction
