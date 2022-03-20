set termguicolors
let g:one_allow_italics = 1
let g:airline_theme = 'one'

function s:one_color_extd() abort
  if &bg ==# 'dark'
    let g:terminal_color_0  = "#abb2bf"
    let g:terminal_color_1  = "#e06c75"
    let g:terminal_color_2  = "#98c379"
    let g:terminal_color_3  = "#d19a66"
    let g:terminal_color_4  = "#61afef"
    let g:terminal_color_5  = "#c678dd"
    let g:terminal_color_6  = "#56b6c2"
    let g:terminal_color_7  = "#828997"
    let g:terminal_color_8  = "#282c34"
    let g:terminal_color_9  = "#e06c75"
    let g:terminal_color_10 = "#98c379"
    let g:terminal_color_11 = "#e5c07b"
    let g:terminal_color_12 = "#61afef"
    let g:terminal_color_13 = "#c678dd"
    let g:terminal_color_14 = "#56b6c2"
    let g:terminal_color_15 = "#3e4452"
  else
    let g:terminal_color_0  = "#494b53"
    let g:terminal_color_1  = "#e45649"
    let g:terminal_color_2  = "#50a14f"
    let g:terminal_color_3  = "#986801"
    let g:terminal_color_4  = "#4078f2"
    let g:terminal_color_5  = "#a626a4"
    let g:terminal_color_6  = "#0184bc"
    let g:terminal_color_7  = "#696c77"
    let g:terminal_color_8  = "#fafafa"
    let g:terminal_color_9  = "#e45649"
    let g:terminal_color_10 = "#50a14f"
    let g:terminal_color_11 = "#c18401"
    let g:terminal_color_12 = "#4078f2"
    let g:terminal_color_13 = "#a626a4"
    let g:terminal_color_14 = "#0184bc"
    let g:terminal_color_15 = "#d0d0d0"
  endif
  call my#vis#hi_extd()
endfunction

augroup highlight_extend
  autocmd!
  au ColorScheme one call <SID>one_color_extd()
augroup end

colorscheme one
