setlocal textwidth=0 nowrap nolinebreak
let b:table_mode_corner = '|'

for [s:key, s:val] in items({'P':'`', 'I':'*', 'B':'**', 'M':'***', 'U':'<u>'})
  for s:mod_item in ['n', 'v']
    exe s:mod_item . 'n' '<buffer><silent> <M-' . s:key . '>'
          \ ':call my#srd#sur_add("' . s:mod_item . '","' . s:val . '")<CR>'
  endfor
endfor

function! s:markdownPreviewToggle() abort
  if exists("g:vscode") > 0
    call VSCodeNotify("markdown.showPreviewToSide")
  elseif exists(":MarkdownPreviewToggle")
    MarkdownPreviewToggle
  endif
endfunction

nnoremap <buffer><silent> <F5> <Cmd>PresentingStart<CR>
call my#util#set_keymap("n", "<leader>mt",
      \ function("s:markdownPreviewToggle"), {
        \ "noremap": 1,
        \ "silent": 1,
        \ })
