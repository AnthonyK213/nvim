set vb t_vb=
set guioptions=egrLt

if has("win32")
  let s:nvim = expand("$LOCALAPPDATA/nvim")
elseif has("unix")
  let s:nvim = expand("$HOME/.config/nvim")
endif

try
  let &rtp .= ',' . s:nvim
  exe 'source' s:nvim . '/viml/basics.vim'
  exe 'source' s:nvim . '/viml/subsrc.vim'
  set background=light
  if has("termguicolors")
    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum
    set termguicolors
  endif
  colorscheme nanovim
catch
  echom "Maybe there is no neovim configuration."
  echom "Please check out https://github.com/AnthonyK213/nvim"
endtry
