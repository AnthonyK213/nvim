function! s:preview(result) abort
  let l:def = a:result.definition
  let l:def = substitute(l:def, '\v^[\n\r]?\*', '', '')
  let l:def = printf("# %s\r\n%s\r\n%s", a:result.dict, a:result.word, l:def)
  echo substitute(l:def, "\r", "\n", 'g')
endfunction

function! s:on_exit(proc, job_id, data, event) abort
  try
    let l:results = json_decode(a:proc.standard_output[0])
    if empty(l:results)
      echo "No information available"
    else
      call s:preview(results[0])
    endif
  catch
    call my#lib#notify_err("Failed to parse the result")
  endtry
endfunction

function! my#stardict#stardict_sdcv(word) abort
  if !my#lib#executable("sdcv")
    return
  endif
  let l:p = my#proc#new("sdcv", { "args": ["-n", "-j", a:word] }, funcref("s:on_exit"))
  call l:p.start()
endfunction
