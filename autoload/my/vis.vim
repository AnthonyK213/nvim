function! my#vis#hi_extd() abort
  " Spell
  call my#lib#set_hi('SpellBad', g:terminal_color_1, '', 'underline')
  call my#lib#set_hi('SpellCap', g:terminal_color_3, '', 'underline')
  " End of buffer '~'
  call my#lib#set_hi('EndOfBuffer', g:terminal_color_8, '', '')
  " Html
  call my#lib#set_hi('htmlH1',         g:terminal_color_1,  '', 'bold')
  call my#lib#set_hi('htmlH2',         g:terminal_color_1,  '', 'bold')
  call my#lib#set_hi('htmlH3',         g:terminal_color_1,  '', '')
  call my#lib#set_hi('htmlBold',       g:terminal_color_3,  '', 'bold')
  call my#lib#set_hi('htmlItalic',     g:terminal_color_5,  '', 'italic')
  call my#lib#set_hi('htmlBoldItalic', g:terminal_color_11, '', 'bold,italic')
  " Markdown
  call my#lib#set_hi('markdownH1',  g:terminal_color_1,  '', 'bold')
  call my#lib#set_hi('markdownH2',  g:terminal_color_1,  '', 'bold')
  call my#lib#set_hi('markdownH3',  g:terminal_color_1,  '', '')
  call my#lib#set_hi('markdownUrl', g:terminal_color_4,  '', 'underline')
  call my#lib#set_hi('markdownEscape',     g:terminal_color_4,  '', '')
  call my#lib#set_hi('markdownLinkText',   g:terminal_color_6,  '', 'underline')
  call my#lib#set_hi('markdownBold',       g:terminal_color_3,  '', 'bold')
  call my#lib#set_hi('markdownItalic',     g:terminal_color_5,  '', 'italic')
  call my#lib#set_hi('markdownBoldItalic', g:terminal_color_11, '', 'bold,italic')
  " Markdown delimiters
  call my#lib#set_hi('markdownCodeDelimiter',       g:terminal_color_15, '', '')
  call my#lib#set_hi('markdownBoldDelimiter',       g:terminal_color_15, '', '')
  call my#lib#set_hi('markdownItalicDelimiter',     g:terminal_color_15, '', '')
  call my#lib#set_hi('markdownBoldItalicDelimiter', g:terminal_color_15, '', '')
  call my#lib#set_hi('markdownLinkDelimiter',       g:terminal_color_15, '', '')
  call my#lib#set_hi('markdownLinkTextDelimiter',   g:terminal_color_15, '', '')
endfunction
