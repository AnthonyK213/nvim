let g:_my_theme_switchable = 1

if has("nvim")
  augroup highlight_extend
    autocmd!
    au ColorScheme gruvbox call my#vis#hi_extd()
  augroup end
endif

colorscheme gruvbox
