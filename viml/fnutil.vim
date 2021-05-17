" Key maps
"" Mouse toggle
nn  <silent> <F2> :call           usr#misc#mouse_toggle()<CR>
vn  <silent> <F2> :<C-u>call      usr#misc#mouse_toggle()<CR>
ino <silent> <F2> <C-\><C-o>:call usr#misc#mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-n>:call usr#misc#mouse_toggle()<CR>a
"" Background toggle
nn  <silent> <leader>bg :call usr#misc#bg_toggle()<CR>
"" Explorer
nn  <silent> <leader>oe :call usr#util#open_file(expand("%:p:h"))<CR>
"" Terminal
nn  <silent> <leader>ot :call usr#util#terminal()<CR>i
"" Open with system default browser
nn  <silent> <leader>ob :call usr#util#open_file(expand("%:p"))<CR>
"" Hanzi count
nn  <silent> <leader>cc :call usr#note#hanzi_count("n")<CR>
vn  <silent> <leader>cc :<C-u>call usr#note#hanzi_count("v")<CR>
"" Evaluate formula surrounded by `.
nn <silent> <leader>ev :call usr#eval#text_eval()<CR>
"" Surround
""" Common maps
nn <silent> <leader>sa :call usr#srd#sur_add('n')<CR>
vn <silent> <leader>sa :<C-u>call usr#srd#sur_add('v')<CR>
nn <silent> <leader>sd :call usr#srd#sur_sub('')<CR>
nn <silent> <leader>sc :call usr#srd#sur_sub()<CR>
""" Markdown
for [s:key, s:val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for s:mod_item in ['n', 'v']
    exe s:mod_item . 'n' '<silent> <M-' . s:key . '>'
          \ ':call usr#srd#sur_add("' . s:mod_item . '","' . s:val . '")<CR>'
  endfor
endfor
"" Search visual selection
vn  <silent> * y/\V<C-r>=usr#lib#get_visual_selection()<CR><CR>
"" Search cword in web browser
let s:util_web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }
for [s:key, s:val] in items(s:util_web_list)
  exe 'nn <silent> <leader>k' . s:key ':call usr#util#search_web("n", "' . s:val . '")<CR>'
  exe 'vn <silent> <leader>k' . s:key ':<C-u>call usr#util#search_web("v", "' . s:val . '")<CR>'
endfor
"" List bullets
ino <silent> <M-CR> <C-\><C-o>:call usr#note#md_insert_bullet()<CR>
nn  <silent> <leader>ml :call usr#note#md_sort_num_bullet()<CR>
"" Echo git status
nn <silent> <leader>hh :!git status<CR>
"" Append day of week after the date
nn <silent> <leader>dd :call usr#note#append_day_from_date()<CR>
"" Insert an orgmode-style timestamp at the end of the line
nn <silent> <leader>ds A<C-R>=strftime(' [[%Y-%m-%d %a %H:%M]]')<CR><Esc>
"" Comment
nn  <leader>la :call usr#cmt#cmt_add_norm()<CR>
vn  <leader>la :<C-u>call usr#cmt#cmt_add_vis()<CR>
nn  <leader>ld :call usr#cmt#cmt_del_norm()<CR>
vn  <leader>ld :<C-u>call usr#cmt#cmt_del_vis()<CR>
"" Some emacs shit.
for [s:key, s:val] in items({"n": "j", "p": "k"})
  exe 'nn  <C-' . s:key . '> g' . s:val
  exe 'vn  <C-' . s:key . '> g' . s:val
  exe 'ino <silent> <C-' . s:key . '> <C-\><C-O>g' . s:val
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
"" Git
command! -nargs=* PushAll :call usr#vcs#git_push_all(<f-args>)
"" Run code
command! -nargs=? -complete=custom,usr#misc#run_code_option CodeRun :call usr#util#run_or_compile(<q-args>)
"" Echo time(May be useful in full screen?)
command! Time :echo strftime('%Y-%m-%d %a %T')
"" View PDF
command! PDF :call usr#util#open_file(expand("%:p:r") . ".pdf")
