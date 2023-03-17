function! s:preview(result) abort
  let l:def = a:result.definition
  let l:def = substitute(l:def, '\v^[\n\r]?\*', '', '')
  let l:def = printf("# %s\r\n__%s__\n%s", a:result.dict, a:result.word, l:def)
  if has('nvim-0.5')
    let l:lines = split(l:def, "\n")
    call v:lua.vim.lsp.util.open_floating_preview(l:lines, "markdown", {
        \ "border": g:_my_tui_border,
        \ "pad_left": 4,
        \ "pad_right": 4,
        \ "max_height": 20,
        \ "max_width": 50,
        \ "wrap": v:true,
        \ })
  else
    echo substitute(l:def, "\r", "\n", '')
  endif
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
