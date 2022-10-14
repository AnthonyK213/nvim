"" Calculate the day of week from a date(yyyy-mm-dd).
function! s:zeller(str) abort
  let l:matches = matchlist(a:str, '\v^.*(\d{4}-\d{2}-\d{2}).*$')
  if !empty(l:matches)
    let l:str_date = l:matches[1]
    let l:str_to_list = split(l:str_date, '-')
    let l:a = l:str_to_list[0]
    let l:m = l:str_to_list[1]
    let l:d = l:str_to_list[2]
  else
    echom 'Not a valid date expression.'
    return ['']
  endif
  if l:m < 1 || l:m > 12
    echom 'Not a valid month.'
    return ['']
  endif
  if l:m == 2
    let l:month_days_count = 28
    if (l:a % 100 != 0 && l:a % 4 == 0)
          \ || (l:a % 100 == 0 && l:a % 400 == 0)
      let l:month_days_count += 1
    endif
  else
    let l:month_days_count = 30
    if (l:m <= 7 && l:m % 2 == 1)
          \ || (l:m >= 8 && l:m % 2 == 0)
      let l:month_days_count += 1
    endif
  endif
  if l:d < 1 || l:d > l:month_days_count
    echom 'Not a valid date.'
    return ['']
  endif
  if m == 1 || m == 2
    let l:a -= 1
    let l:m += 12
  endif
  let l:c = l:a / 100
  let l:y = l:a - l:c * 100
  let l:x = (c / 4) + y + (y / 4) + 26 * (m + 1) / 10 + d - 2 * c - 1
  let l:z = l:x % 7
  if l:z < 0 | let l:z += 7 | end
  let l:days_list = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  return [l:days_list[l:z], l:str_date]
endfunction

function! my#note#append_day_from_date() abort
  let l:line = getline('.')
  let l:str = expand("<cWORD>")
  if l:str =~ '^$' | return | endif
  let l:cursor_pos = col('.')
  let l:match_start = 0
  while 1
    let l:match_cword = matchstrpos(l:line, l:str, l:match_start)[1:]
    if l:match_cword[0] <= l:cursor_pos
          \ && l:match_cword[1] >= l:cursor_pos
      break
    endif
    let l:match_start = l:match_cword[1]
  endwhile
  let l:stt = l:match_cword[0]
  let l:day = s:zeller(l:str)
  if l:day[0] !=? ''
    let l:end = matchstrpos(l:line, l:day[1], l:stt)[2]
    call setpos('.', [0, line('.'), l:end])
    silent exe "normal! a " . l:day[0]
  endif
endfunction

"" Hanzi count.
function! my#note#hanzi_count(mode) abort
  if a:mode ==# 'n'
    let l:content = getline(1, '$')
  elseif a:mode ==# 'v'
    let l:content = split(my#lib#get_gv(), "\n")
  else
    return
  endif
  let l:h_count = 0
  for l:line in l:content
    for l:char in split(l:line, '.\zs')
      if my#lib#is_hanzi(l:char) | let l:h_count += 1 | endif
    endfor
  endfor
  if l:h_count == 0
    echo 'No Chinese character was found.'
  else
    echo 'The number of Chinese characters is' l:h_count . '.'
  endif
endfunction

"" Markdown number bullet
function! s:md_check_line(lnum) abort
  let l:lstr = getline(a:lnum)
  let l:detect = 0
  let l:bullet = 0
  let l:indent = strlen(matchstr(l:lstr, '\v^(\s*)')) 
  let l:matches1 = matchlist(l:lstr, '\v^\s*(\+|-|*)\s+.*$')
  let l:matches2 = matchlist(l:lstr, '\v^\s*(\d+)\.\s+.*$')
  if l:lstr =~ '\v^\s*$'
        \ && my#syn#new(a:lnum, 1).match('\v(markdownHighlight|markdownCode|textSnip)')
    let l:indent = 1000
  endif
  if !empty(l:matches1)
    let l:detect = 1
    let l:bullet = l:matches1[1]
  elseif !empty(l:matches2)
    let l:detect = 2
    let l:bullet = l:matches2[1]
  endif
  return [l:detect, l:lstr, l:bullet, l:indent]
endfunction

function! my#note#md_insert_bullet() abort
  let l:lnum = line('.')
  let l:linf_c = s:md_check_line('.')
  let l:detect = 0
  let l:bullet = 0
  let l:indent = 0
  if l:linf_c[0] == 0
    let l:lnum_b = l:lnum - 1
    while l:lnum_b > 0
      let l:linf_b = s:md_check_line(l:lnum_b)
      if l:linf_b[3] < l:linf_c[3] && l:linf_b[0] != 0
        let l:detect = l:linf_b[0]
        let l:bullet = l:linf_b[2]
        let l:indent = l:linf_b[3]
        break
      endif
      let l:lnum_b -= 1
    endwhile
  else
    let l:detect = l:linf_c[0]
    let l:bullet = l:linf_c[2]
    let l:indent = l:linf_c[3]
  endif
  if l:detect == 0
    call feedkeys("\<C-\>\<C-O>o")
  else
    let l:lnum_f = l:lnum + 1
    let l:move_d = 0
    let l:move_record = []
    while l:lnum_f <= line('$')
      let l:linf_f = s:md_check_line(l:lnum_f)
      if l:linf_f[0] == l:detect && l:linf_f[3] == l:indent
        call add(l:move_record, l:move_d)
        if l:detect == 1
          break
        elseif l:detect == 2 && l:linf_f[0] == 2
          call setline(l:lnum_f, substitute(l:linf_f[1],
                \ '\v(\d+)', '\=submatch(1) + 1', ''))
        endif
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
    let l:nbullet = l:detect == 2 ? (l:bullet + 1) . '. ' : l:bullet . ' '
    call feedkeys(repeat("\<C-G>U\<Down>", l:count_d) .
          \ "\<C-O>o\<C-O>i" . repeat("\<SPACE>", l:indent) . l:nbullet)
  endif
endfunction

function my#note#md_sort_num_bullet()
  let l:lnum = line('.')
  let l:linf_c = s:md_check_line('.')
  if l:linf_c[0] == 2
    let l:num_lb = [l:lnum]
    let l:num_lf = []
    let l:lnum_b = l:lnum - 1
    while l:lnum_b > 0
      let l:linf_b = s:md_check_line(l:lnum_b)
      if l:linf_b[0] == 2
        if l:linf_b[3] == l:linf_c[3]
          call add(l:num_lb, l:lnum_b)
        elseif l:linf_b[3] < l:linf_c[3]
          break
        endif
      elseif l:linf_b[0] != 2 && l:linf_b[3] <= l:linf_c[3]
        break
      endif
      let l:lnum_b -= 1
    endwhile
    let l:lnum_f = l:lnum + 1
    while l:lnum_f <= line('$')
      let l:linf_f = s:md_check_line(l:lnum_f)
      if l:linf_f[0] == 2
        if l:linf_f[3] == l:linf_c[3]
          call add(l:num_lf, l:lnum_f)
        elseif l:linf_f[3] < l:linf_c[3]
          break
        endif
      elseif l:linf_f[0] != 2 && l:linf_f[3] <= l:linf_c[3]
        break
      endif
      let l:lnum_f += 1
    endwhile
    let l:num_la = reverse(l:num_lb) + l:num_lf
    let l:i = 1
    for l:item in l:num_la
      call setline(l:item, substitute(getline(l:item),
            \ '\v(\d+)', '\=' . l:i, ''))
      let l:i += 1
    endfor
  else
    echo "Not in a line of any numbered lists."
    return
  endif
endfunction
