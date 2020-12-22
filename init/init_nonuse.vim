Plug 'rakr/vim-one'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

exe 'so ' . stdpath('data') . '/nvim-test/vim-ipairs/after/plugin/ipairs.vim'

let s:source = [
      \ 'a_plug',
      \ 'basics',
      \ 'custom',
      \ 'deflib',
      \ 'depwin',
      \ 'fnutil',
      \ 'plugrc',
      \ 'rc_coc',
      \ 'subsrc',
      \ 'nanovi'
      \ ]
let s:flavor = {
      \ 'light' : [1, 2, 3, 4, 5, 8, 9],
      \ 'full'  : [0, 1, 2, 3, 4, 5, 6, 7]
      \ }
function! s:flavor.impl(flavor_name)
  for l:i in self[a:flavor_name]
    exe 'source \<sfile>:h/init/init_' . s:source[l:i] . '.vim'
  endfor
endfunction

call s:flavor.impl('light')

:GuiFont! Cascadia\ Code\ PL:h9
:GuiFont! 等距更纱黑体\ SC:h9

augroup gui_switch_font
  autocmd!
  au BufEnter * call s:nvimqt_set_font('Cascadia Code PL', 9)
  au BufEnter *.md,*.org,*.txt call s:nvimqt_set_font('等距更纱黑体 SC', 9)
augroup end


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


function! s:md_insert_num_bullet()
  let l:lnum = line('.')
  let l:linf_c = s:md_check_line('.')

  let l:bullet = 0
  let l:indent = 0

  if l:linf_c[0] == 2
    let l:bullet = l:linf_c[2]
    let l:indent = l:linf_c[3]
  else
    let l:lnum_b = l:lnum - 1
    while l:lnum_b > 0
      let l:linf_b = s:md_check_line(l:lnum_b)
      if l:linf_b[3] < l:linf_c[3]
        if l:linf_b[0] == 2
          let l:bullet = l:linf_b[2]
          let l:indent = l:linf_b[3]
          break
        elseif l:linf_b[0] == 1
          break
        endif
      endif
      let l:lnum_b -= 1
    endwhile
  endif

  if l:bullet == 0
    call feedkeys("\<CR>")
  else
    let l:lnum_f = l:lnum + 1
    let l:move_d = 0
    let l:move_record = []
    while l:lnum_f <= line('$')
      let l:linf_f = s:md_check_line(l:lnum_f)
      if l:linf_f[0] == 2 && l:linf_f[3] == l:indent
        call add(l:move_record, l:move_d)
        call setline(l:lnum_f, substitute(l:linf_f[1],
              \ '\v(\d+)', '\=submatch(1) + 1', ''))
      elseif l:linf_f[3] <= l:indent
        call add(l:move_record, l:move_d)
        break
      elseif l:lnum_f == line('$')
        call add(l:move_record, l:move_d + 1)
        break
      endif
      let l:lnum_f += 1
      let l:move_d += 1
    endwhile
    let l:count_d = len(l:move_record) == 0 ? 0 : l:move_record[0]
    call feedkeys(repeat("\<C-g>U\<Down>", l:count_d) . "\<C-o>o\<C-o>0" .
          \ repeat("\<space>", l:indent) . (bullet + 1) . '. ')
  endif
endfunction
