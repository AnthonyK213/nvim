" Variables
"" Directional operation which won't mess up the history.
let g:const_dir_l = "\<C-g>U\<Left>"
let g:const_dir_d = "\<C-g>U\<Down>"
let g:const_dir_u = "\<C-g>U\<Up>"
let g:const_dir_r = "\<C-g>U\<Right>"
"" Search web
let s:util_web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }


" Key maps
"" Mouse toggle
nn  <silent> <F2> :call           usr#util#mouse_toggle()<CR>
vn  <silent> <F2> :<C-u>call      usr#util#mouse_toggle()<CR>
ino <silent> <F2> <C-\><C-o>:call usr#util#mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-n>:call usr#util#mouse_toggle()<CR>a
"" Background toggle
nn  <silent> <leader>bg :call usr#util#bg_toggle()<CR>
""" Explorer
nn  <silent> <leader>oe :call usr#util#explorer()<CR>
"" Terminal
nn  <silent> <leader>ot :call usr#util#terminal()<CR>i
"" Open with system default browser
nn  <silent> <leader>ob :call usr#util#open()<CR>
"" Windows-like behaviors
""" Save
nn  <silent> <C-s> :w<CR>
ino <silent> <C-s> <C-\><C-o>:w<CR>
""" Undo
nn  <silent> <C-z> u
ino <silent> <C-z> <C-\><C-o>u
""" Copy/Paste
vn  <silent> <M-c> "+y
vn  <silent> <M-x> "+x
nn  <silent> <M-v> "+p
vn  <silent> <M-v> "+p
ino <silent> <M-v> <C-R>=@+<CR>
""" Select
nn  <silent> <M-a> ggVG
ino <silent> <M-a> <Esc>ggVG
"" Hanzi count
nn  <silent> <leader>cc
      \ :echo 'Chinese characters count: ' . usr#util#hanzi_count("n")<CR>
vn  <silent> <leader>cc
      \ :<C-u>echo 'Chinese characters count: ' . usr#util#hanzi_count("v")<CR>
"" Surround
""" Common maps
nn <silent> <leader>sa :call usr#srd#sur_add('n')<CR>
vn <silent> <leader>sa :<C-u>call usr#srd#sur_add('v')<CR>
nn <silent> <leader>sd :call usr#srd#sur_sub('')<CR>
nn <silent> <leader>sc :call usr#srd#sur_sub()<CR>
""" Markdown
for [key, val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for mod_item in ['n', 'v']
    exe mod_item . 'n' '<silent> <M-' . key . '>'
          \ ':call usr#srd#sur_add("' . mod_item . '","' . val . '")<CR>'
  endfor
endfor
"" Search visual selection
vn  <silent> * y/\V<C-r>=usr#lib#get_visual_selection()<CR><CR>
"" Search cword in web browser
for [key, val] in items(s:util_web_list)
  exe 'nn <silent> <leader>k' . key ':call usr#util#search_web("n", "' . val . '")<CR>'
  exe 'vn <silent> <leader>k' . key ':<C-u>call usr#util#search_web("v", "' . val . '")<CR>'
endfor
"" List bullets
ino <silent> <M-CR> <C-\><C-o>:call usr#note#md_insert_bullet()<CR>
nn  <silent> <leader>ml :call usr#note#md_sort_num_bullet()<CR>
"" Echo git status
nn <silent> <leader>hh :!git status<CR>
"" Append day of week after the date
nn <silent> <leader>dd :call usr#util#append_day_from_date()<CR>
"" Insert an orgmode-style timestamp at the end of the line
nn <silent> <leader>ds A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>
"" Some emacs shit.
for [key, val] in items({"n": "j", "p": "k"})
  exe 'nn  <C-' . key . '> g' . val
  exe 'vn  <C-' . key . '> g' . val
  exe 'ino <silent> <C-' . key . '> <C-\><C-O>g' . val
endfor
nn  <M-x> :
ino <M-x> <C-\><C-o>:
ino <M-b> <C-\><C-o>b
ino <M-f> <C-\><C-o>e<Right>
ino <C-SPACE> <C-\><C-o>v
ino <silent> <C-a> <C-\><C-o>g0
ino <silent> <C-e> <C-\><C-o>g$
ino <silent> <C-k> <C-\><C-o>D
ino <silent> <M-d> <C-\><C-o>dw
ino <silent><expr> <C-f> col('.') >= col('$') ? "\<C-\>\<C-o>+" : g:const_dir_r
ino <silent><expr> <C-b> col('.') == 1 ? "\<C-\>\<C-o>-\<C-\>\<C-o>$" : g:const_dir_l


" Commands
"" Latex
command! Xe1 call usr#util#latex_xelatex()
command! Xe2 call usr#util#latex_xelatex2()
command! Bib call usr#util#latex_biber()
"" Git
command! -nargs=* PushAll :call usr#vcs#git_push_all(<f-args>)
"" Run code
command! -nargs=? CodeRun :call usr#util#run_or_compile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
"" View PDF
command! -nargs=? -complete=file PDF :call usr#util#pdf_view(<f-args>)
