function! s:text_eval(f) abort
  let l:origin_pos = getpos('.')
  exe 'normal! F`'
  let l:back = usr#lib#get_char('b')
  let l:fore = usr#lib#get_char('f')
  try
    let l:expr = matchlist(l:fore, '\v^`(.{-})`.*$')[1]
    let l:result = a:f(l:expr)
    let l:fore_new = substitute(l:fore, '\v^`(.{-}`)', string(l:result), '')
    call setline('.', l:back . l:fore_new)
  catch
    call setpos('.', l:origin_pos)
    echo 'No valid expression was found.'
  endtry
endfunction

function! s:add(args) abort
  let l:result = 0
  for l:arg in a:args
    let l:result += l:arg
  endfor
  return l:result
endfunction

function! s:subtract(args) abort
  let l:result = a:args[0]
  if empty(a:args)
    echoerr "Wrong number of arguments."
  elseif len(a:args) == 1
    return -result
  else
    for l:i in range(1, len(a:args) - 1, 1)
      let l:result -= a:args[l:i]
    endfor
    return l:result
  endif
endfunction

function! s:multiply(args) abort
  let l:result = 1
  for l:arg in a:args
    let l:result *= l:arg
  endfor
  return l:result
endfunction

function! s:divide(args) abort
  let l:result = a:args[0]
  if empty(a:args)
    echoerr "Wrong number of arguments."
  elseif len(a:args) == 1
    return 1.0 / result
  else
    for l:i in range(1, len(a:args) - 1, 1)
      let l:result /= a:args[l:i]
    endfor
    return l:result
  endif
endfunction

function! s:power(args) abort
  let l:pow_res = 1
  for l:i in range(1, len(a:args) - 1, 1)
    let l:pow_res *= a:args[l:i]
  endfor
  return pow(a:args[0], l:pow_res)
endfunction

function! s:expow(args) abort
  if empty(a:args)
    return exp(1)
  elseif len(a:args) == 1
    return exp(a:args[0])
  else
    echoerr "Wrong number of arguments."
  endif
endfunction

let s:pi = 3.1415926535897932
let s:func_map = {
      \ '+'     : {args -> s:add(args)},
      \ '-'     : {args -> s:subtract(args)},
      \ '*'     : {args -> s:multiply(args)},
      \ '/'     : {args -> s:divide(args)},
      \ 'abs'   : {args -> abs(args[0])},
      \ 'acos'  : {args -> acos(args[0])},
      \ 'asin'  : {args -> asin(args[0])},
      \ 'atan'  : {args -> atan(args[0])},
      \ 'atan2' : {args -> atan2(args[0], args[1])},
      \ 'ceil'  : {args -> ceil(args[0])},
      \ 'cos'   : {args -> cos(args[0])},
      \ 'deg'   : {args -> args[0] * 180.0 / s:pi},
      \ 'exp'   : {args -> s:expow(args)},
      \ 'floor' : {args -> floor(args[0])},
      \ 'log'   : {args -> log(args[0])},
      \ 'log10' : {args -> log10(args[0])},
      \ 'pow'   : {args -> s:power(args)},
      \ 'pi'    : {args -> s:pi * s:multiply(args)},
      \ 'rad'   : {args -> args[0] * s:pi / 180.0},
      \ 'sin'   : {args -> sin(args[0])},
      \ 'sqrt'  : {args -> sqrt(args[0])},
      \ 'tan'   : {args -> tan(args[0])},
      \ }

function! s:tree_insert(tree, var, level) abort
  let l:temp_node = a:tree
  for l:i in range(a:level)
    let l:temp_node = l:temp_node[-1]
  endfor
  call add(l:temp_node, a:var)
endfunction

function! s:lisp_tree(str) abort
  let l:tree_level = 0
  let l:pre_parse = substitute(a:str, '\v([\(\)])', '\=" ".submatch(1)." "', 'g')
  let l:elem_table = split(l:pre_parse, '\s')
  let l:tree_table = []

  for l:elem in l:elem_table
    if l:elem ==# '('
      call s:tree_insert(l:tree_table, [], l:tree_level)
      let l:tree_level += 1
    elseif l:elem ==# ')'
      let l:tree_level -= 1
      if l:tree_level == 0
        break
      endif
    elseif has_key(s:func_map, l:elem)
      call s:tree_insert(l:tree_table, l:elem, l:tree_level)
    elseif !empty(l:elem)
      call s:tree_insert(l:tree_table, str2float(l:elem), l:tree_level)
    endif
  endfor
  if l:tree_level != 0
    return
  endif
  return l:tree_table[0]
endfunction

function! s:lisp_tree_eval(arg) abort
  if type(a:arg) == 5
    return a:arg
  endif
  let l:func = a:arg[0]
  call remove(a:arg, 0)
  return s:func_map[l:func](map(a:arg, {_, val -> s:lisp_tree_eval(val)}))
endfunction

function! s:lisp_str_eval(str) abort
  return s:lisp_tree_eval(s:lisp_tree(a:str))
endfunction

function! usr#eval#vim_eval() abort
  call s:text_eval({s -> eval(s)})
endfunction

function! usr#eval#lisp_eval() abort
  call s:text_eval({s -> s:lisp_str_eval(s)})
endfunction
