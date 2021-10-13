" Adjust window size.
nn <C-UP>    <C-W>-
nn <C-DOWN>  <C-W>+
nn <C-LEFT>  <C-W>>
nn <C-RIGHT> <C-w><
" Terminal.
tno <Esc> <C-\><C-n>
tno <silent> <M-d> <C-\><C-N>:bd!<CR>
" Find and replace.
nn <M-g> :%s/
vn <M-g> :s/
" Normal command.
nn <M-n> :%normal 
vn <M-n> :normal 
" Buffer.
nn <silent> <leader>bc :lcd %:p:h<CR>
nn <expr><silent> <leader>bd
      \ index(['help','terminal','nofile', 'quickfix'], &buftype) >= 0 \|\|
      \ len(getbufinfo({'buflisted':1})) <= 2 ?
      \ ":bd<CR>" : ":bp\|bd#<CR>"
nn <silent> <leader>bh :noh<CR>
nn <silent> <leader>bl :ls<CR>
nn <silent> <leader>bn :bn<CR>
nn <silent> <leader>bp :bp<CR>
" Toggle spell check status.
nn <silent> <Leader>cs :setlocal spell! spelllang=en_us<CR>
" Navigate windows.
for s:direct in ['h', 'j', 'k', 'l', 'w']
  exe 'nn  <M-' . s:direct . '> <C-w>'            . s:direct
  exe 'ino <M-' . s:direct . '> <ESC><C-w>'       . s:direct
  exe 'tno <M-' . s:direct . '> <C-\><C-n><C-w>'  . s:direct
endfor
" Switch tab.
for s:tab_num in range(1, 10)
  let s:tab_key = s:tab_num == 10 ? 0 : s:tab_num
  exe 'nn  <silent> <M-' . s:tab_key . '>           :tabn' s:tab_num . '<CR>'
  exe 'ino <silent> <M-' . s:tab_key . '> <C-\><C-O>:tabn' s:tab_num . '<CR>'
endfor
" Command mode
cm <C-A>  <C-B>
cm <C-B>  <LEFT>
cm <C-F>  <RIGHT>
cm <C-H>  <C-F>
cm <M-b>  <C-LEFT>
cm <M-f>  <C-RIGHT>
cm <M-BS> <C-W>


" Windows shit.
nn  <silent> <C-S> :w<CR>
ino <silent> <C-S> <C-\><C-o>:w<CR>
vn  <silent> <M-c> "+y
vn  <silent> <M-x> "+x
nn  <silent> <M-v> "+p
vn  <silent> <M-v> "+p
ino <silent> <M-v> <C-R>=@+<CR>
nn  <silent> <M-a> ggVG
" Emacs shit.
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


" Search visual selection
vn  <silent> * y/\V<C-r>=usr#lib#get_visual_selection()<CR><CR>
" Mouse toggle.
nn  <silent> <F2> :call           usr#misc#mouse_toggle()<CR>
vn  <silent> <F2> :<C-u>call      usr#misc#mouse_toggle()<CR>
ino <silent> <F2> <C-\><C-o>:call usr#misc#mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-n>:call usr#misc#mouse_toggle()<CR>a
" Background toggle.
nn <silent> <leader>bg :call usr#misc#bg_toggle()<CR>
" Open init file.
nn <silent> <M-,> :call usr#util#edit_file("$MYVIMRC", 1)<CR>
" Explorer.
nn <silent> <leader>oe :call usr#util#open_file(expand("%:p:h"))<CR>
" Terminal.
nn <silent> <leader>ot :call usr#util#terminal()<CR>i
" Open with system default browser.
nn <silent> <leader>ob :call usr#util#open_file(expand("%:p"))<CR>
" Evaluate formula surrounded by `.
nn <silent> <leader>ev :call usr#eval#text_eval()<CR>
" Append day of week after the date.
nn <silent> <leader>dd :call usr#note#append_day_from_date()<CR>
" Insert an timestamp after cursor.
nn <silent> <leader>ds a<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>
" Hanzi count.
nn <silent> <leader>cc :call usr#note#hanzi_count("n")<CR>
vn <silent> <leader>cc :<C-u>call usr#note#hanzi_count("v")<CR>
" List bullets.
ino <silent> <M-CR> <C-\><C-o>:call usr#note#md_insert_bullet()<CR>
nn  <silent> <leader>ml :call usr#note#md_sort_num_bullet()<CR>
" Echo git status.
nn <silent> <leader>gs :!git status<CR>
" Search cword in web browser.
let s:web_list = {
      \ "b" : "https://www.baidu.com/s?wd=",
      \ "g" : "https://www.google.com/search?q=",
      \ "h" : "https://github.com/search?q=",
      \ "y" : "https://dict.youdao.com/w/eng/"
      \ }
for [s:key, s:val] in items(s:web_list)
  exe 'nn <silent> <leader>h' . s:key ':call usr#util#search_web("n", "' . s:val . '")<CR>'
  exe 'vn <silent> <leader>h' . s:key ':<C-u>call usr#util#search_web("v", "' . s:val . '")<CR>'
endfor
" Surround
nn <silent> <leader>sa :call usr#srd#sur_add('n')<CR>
vn <silent> <leader>sa :<C-u>call usr#srd#sur_add('v')<CR>
nn <silent> <leader>sd :call usr#srd#sur_sub('')<CR>
nn <silent> <leader>sc :call usr#srd#sur_sub()<CR>
for [s:key, s:val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for s:mod_item in ['n', 'v']
    exe s:mod_item . 'n' '<silent> <M-' . s:key . '>'
          \ ':call usr#srd#sur_add("' . s:mod_item . '","' . s:val . '")<CR>'
  endfor
endfor
" Comment
nn  <leader>kc :call usr#cmt#cmt_add_norm()<CR>
vn  <leader>kc :<C-u>call usr#cmt#cmt_add_vis()<CR>
nn  <leader>ku :call usr#cmt#cmt_del_norm()<CR>
vn  <leader>ku :<C-u>call usr#cmt#cmt_del_vis()<CR>
