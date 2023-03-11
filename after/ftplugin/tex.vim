function! s:tex_preview() abort
  if exists("b:vimtex") && has_key(b:vimtex, "base")
    let l:pdf_path = fnamemodify(b:vimtex["tex"], ":r")
  else
    let l:pdf_path = expand("%:p:r")
  endif
  let l:pdf_path .= ".pdf"
  if empty(glob(l:pdf_path))
    call my#lib#notify_err("Pdf file is not found, please compile the project")
    return
  endif
  call my#util#sys_open(l:pdf_path)
endfunction

nn <buffer><silent> <leader>mv <Cmd>VimtexTocToggle<CR>
nn <buffer><silent> <leader>mt <Cmd>call <SID>tex_preview()<CR>
