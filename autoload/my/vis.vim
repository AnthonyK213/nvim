let s:highlights = {
      \ 'EndOfBuffer': {'fg': '$bg'},
      \ 'SpellBad': {'fg': '$red', 'sp': '$red', 'fmt': 'underline'},
      \ 'SpellCap': {'fg': '$yellow', 'fmt': 'underline'},
      \ 'Underlined': {'sp': '$cyan', 'fmt': 'underline'},
      \ 'htmlUnderline': { 'sp': "$cyan", 'fmt': "underline" },
      \ 'VimwikiUnderline': { 'sp': "$cyan", 'fmt': "underline" },
      \ 'htmlH1': {'fg': '$red', 'fmt': 'bold'},
      \ 'htmlH2': {'fg': '$red', 'fmt': 'bold'},
      \ 'htmlH3': {'fg': '$red'},
      \ 'htmlBold': {'fg': '$yellow', 'fmt': 'bold'},
      \ 'htmlItalic': {'fg': '$purple', 'fmt': 'italic'},
      \ 'htmlBoldItalic': {'fg': '$bright_yellow', 'fmt': 'bold,italic'},
      \ 'markdownH1': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH2': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH3': {'fg': '$red', 'fmt': 'bold'},
      \ 'markdownH4': {'fg': '$red'},
      \ 'markdownH5': {'fg': '$red'},
      \ 'markdownH6': {'fg': '$red'},
      \ 'markdownBold': {'fg': '$yellow', 'fmt': 'bold'},
      \ 'markdownItalic': {'fg': '$purple', 'fmt': 'italic'},
      \ 'markdownBoldItalic': {'fg': '$bright_yellow', 'fmt': 'bold,italic'},
      \ 'markdownCode': {'fg': '$green'},
      \ 'markdownUrl': {'fg': '$grey'},
      \ 'markdownEscape': {'fg': '$cyan'},
      \ 'markdownLinkText': {'fg': '$cyan', 'sp': 'cyan', 'fmt': 'underline'},
      \ 'markdownHeadingDelimiter': { 'fg': '$red' },
      \ 'markdownBoldDelimiter': {'fg': '$grey'},
      \ 'markdownItalicDelimiter': {'fg': '$grey'},
      \ 'markdownBoldItalicDelimiter': {'fg': '$grey'},
      \ 'markdownCodeDelimiter': {'fg': '$grey'},
      \ 'markdownLinkDelimiter': {'fg': '$grey'},
      \ 'markdownLinkTextDelimiter': {'fg': '$grey'},
      \ }

function! s:c(color_table, name) abort
  if !empty(a:name)
    if a:name[0] ==# '#'
      return a:name
    elseif a:name[0] ==# '$'
      let l:key = a:name[1:]
      if has_key(a:color_table, l:key)
        return a:color_table[l:key]
      endif
    endif
  endif
  return ''
endfunction

function! my#vis#hi_extd() abort
  let l:palette = {
        \ 'fg': g:terminal_color_0,
        \ 'red': g:terminal_color_1,
        \ 'green': g:terminal_color_2,
        \ 'yellow': g:terminal_color_3,
        \ 'blue': g:terminal_color_4,
        \ 'purple': g:terminal_color_5,
        \ 'cyan': g:terminal_color_6,
        \ 'light_grey': g:terminal_color_7,
        \ 'bg': g:terminal_color_8,
        \ 'bright_red': g:terminal_color_9,
        \ 'bright_green': g:terminal_color_10,
        \ 'bright_yellow': g:terminal_color_11,
        \ 'bright_blue': g:terminal_color_12,
        \ 'bright_purple': g:terminal_color_13,
        \ 'bright_cyan': g:terminal_color_14,
        \ 'grey': g:terminal_color_15,
        \ }
  for [l:k, l:v] in items(s:highlights)
    let l:val = deepcopy(l:v)
    for [l:a, l:b] in items(l:val)
      if index(['fg', 'bg', 'sp'], l:a) >= 0
        let l:val[l:a] = s:c(l:palette, l:b)
      endif
    endfor
    call my#lib#set_hl(l:k, l:val)
  endfor
endfunction
