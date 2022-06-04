" Adjust window size.
nn <C-UP>    <C-W>-
nn <C-DOWN>  <C-W>+
nn <C-LEFT>  <C-W>>
nn <C-RIGHT> <C-W><
" Terminal.
tno <Esc> <C-\><C-N>
tno <silent> <M-d> <C-\><C-N>:bd!<CR>
" Find and replace.
nn <M-g> :%s/
vn <M-g> :s/
" Buffer.
nn <silent> <leader>bc :lcd %:p:h<CR>
nn <expr><silent> <leader>bd
      \ index(['help','terminal','nofile', 'quickfix'], &buftype) >= 0
      \ \|\| index(['git'], &filetype) >= 0
      \ \|\| len(getbufinfo({'buflisted':1})) <= 2 ?
      \ ":bd<CR>" : ":bp\|bd#<CR>"
nn <silent> <leader>bh :noh<CR>
nn <silent> <leader>bl :ls<CR>
nn <silent> <leader>bn :bn<CR>
nn <silent> <leader>bp :bp<CR>
" Toggle spell check status.
nn <silent> <Leader>cs :setlocal spell! spelllang=en_us<CR>
" Navigate windows.
for s:direct in ['h', 'j', 'k', 'l', 'w']
  exe 'nn  <M-' . s:direct . '> <C-W>'            . s:direct
  exe 'ino <M-' . s:direct . '> <ESC><C-W>'       . s:direct
  exe 'tno <M-' . s:direct . '> <C-\><C-N><C-w>'  . s:direct
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
ino <silent> <C-S> <C-\><C-O>:w<CR>
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
ino <M-x> <C-\><C-O>:
ino <M-b> <C-\><C-O>b
ino <M-f> <C-\><C-O>e<Right>
ino <C-SPACE> <C-\><C-O>v
ino <silent> <C-A> <C-\><C-o>g0
ino <silent> <C-E> <C-\><C-o>g$
ino <silent> <C-K> <C-\><C-o>D
ino <silent> <M-d> <C-\><C-O>dw
ino <silent><expr> <C-F> col('.') >= col('$') ? "\<C-\>\<C-o>+" : g:_const_dir_r
ino <silent><expr> <C-B> col('.') == 1 ? "\<C-\>\<C-o>-\<C-\>\<C-o>$" : g:_const_dir_l
" Move line.
nn <silent> <M-p> :exe "move" max([line(".") - 2, 0])<CR>
nn <silent> <M-n> :exe "move" min([line(".") + 1, line("$")])<CR>
vn <silent> <M-p> :<C-U>exe "'<,'>move" max([line("'<") - 2, 0])<CR>gv
vn <silent> <M-n> :<C-U>exe "'<,'>move" min([line("'>") + 1, line("$")])<CR>gv


" Search visual selection
vn <silent> * :<C-U>/<C-R>=my#util#search_selection('/')<CR><CR>
vn <silent> # :<C-U>?<C-R>=my#util#search_selection('?')<CR><CR>
" Mouse toggle.
nn  <silent> <F2> :call           my#compat#mouse_toggle()<CR>
vn  <silent> <F2> :<C-U>call      my#compat#mouse_toggle()<CR>
ino <silent> <F2> <C-\><C-O>:call my#compat#mouse_toggle()<CR>
tno <silent> <F2> <C-\><C-N>:call my#compat#mouse_toggle()<CR>a
" Run code.
nn <silent> <F5> :call my#comp#run_or_compile("")<CR>
" Background toggle.
nn <silent> <leader>bg :call my#compat#bg_toggle()<CR>
" Open init file.
nn <silent> <M-,> :call my#compat#open_opt()<CR>
" Explorer.
nn <silent> <leader>oe :call my#util#sys_open(expand("%:p:h"))<CR>
" Terminal.
nn <silent> <leader>ot :call my#util#terminal()<CR>
" Open with system default browser.
nn <silent> <leader>ob :call my#util#sys_open(expand("%:p"))<CR>
" Open url under the cursor or in the selection.
nn <silent> <leader>ou :call my#util#sys_open(my#util#match_path_or_url_under_cursor(), 1)<CR>
" Evaluate formula surrounded by `.
nn <silent> <leader>ev :call my#eval#vim_eval()<CR>
nn <silent> <leader>el :call my#eval#lisp_eval()<CR>
" Append day of week after the date.
nn <silent> <leader>dd :call my#note#append_day_from_date()<CR>
" Insert an timestamp after cursor.
nn <silent> <leader>ds a<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>
" Hanzi count.
nn <silent> <leader>cc :call my#note#hanzi_count("n")<CR>
vn <silent> <leader>cc :<C-U>call my#note#hanzi_count("v")<CR>
" List bullets.
ino <silent> <M-CR> <C-\><C-O>:call my#note#md_insert_bullet()<CR>
nn  <silent> <leader>ml :call my#note#md_sort_num_bullet()<CR>
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
  exe 'nn <silent> <leader>h' . s:key ':call my#util#search_web("n", "' . s:val . '")<CR>'
  exe 'vn <silent> <leader>h' . s:key ':<C-U>call my#util#search_web("v", "' . s:val . '")<CR>'
endfor
" Surround
nn <silent> <leader>sa :call my#srd#sur_add('n')<CR>
vn <silent> <leader>sa :<C-U>call my#srd#sur_add('v')<CR>
nn <silent> <leader>sd :call my#srd#sur_sub('')<CR>
nn <silent> <leader>sc :call my#srd#sur_sub()<CR>
" Comment
nn <silent> <leader>kc :call my#cmt#cmt_add_norm()<CR>
vn <silent> <leader>kc :<C-U>call my#cmt#cmt_add_vis()<CR>
nn <silent> <leader>ku :call my#cmt#cmt_del_norm()<CR>
vn <silent> <leader>ku :<C-U>call my#cmt#cmt_del_vis()<CR>
" Show highlight information.
nn <silent> <leader>vs :call my#syn#new(line('.'), col('.')).show()<CR>
