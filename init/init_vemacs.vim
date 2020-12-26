" Some emacs shit.
for [key, val] in items({"n":"j", "p":"k"})
  exe 'nnoremap <C-' . key . '> g' . val
  exe 'vnoremap <C-' . key . '> g' . val
  exe 'inoremap <silent> <C-' . key . '> <C-o>g' . val
endfor
nn  <M-x> :
ino <M-x> <C-o>:
ino <M-b> <C-o>b
ino <M-f> <C-o>e<Right>
ino <C-SPACE> <C-o>v
ino <silent> <C-a> <C-o>g0
ino <silent> <C-e> <C-o>g$
ino <silent><expr> <C-k> col('.') >= col('$') ? "" : "\<C-o>D"
ino <silent><expr> <M-d> col('.') >= col('$') ? "" : "\<C-o>dw"
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-o>+" : g:custom_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-o>-\<C-o>$" : g:custom_l
