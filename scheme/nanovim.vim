" Name:    nanovim.vim
" Licence: MIT

set background=light
hi clear

if exists('syntax on')
  syntax reset
endif

let g:colors_name = 'nanovim'

let s:nano_color_background = { "gui": "#FFFFFF", "cterm": "15"  } "White
let s:nano_color_strong     = { "gui": "#000000", "cterm": "0"   } "Black
let s:nano_color_critical   = { "gui": "#FF6F00", "cterm": "1"   } "Amber
let s:nano_color_popout     = { "gui": "#FFAB91", "cterm": "1"   } "Deep Orange
let s:nano_color_salient    = { "gui": "#673AB7", "cterm": "5"   } "Deep Purple
let s:nano_color_highlight  = { "gui": "#F9F9F9", "cterm": "251" } "Very Light Grey
let s:nano_color_subtle     = { "gui": "#ECEFF1", "cterm": "243" } "Blue Grey / L50
let s:nano_color_faded      = { "gui": "#B0BEC5", "cterm": "249" } "Blue Grey / L200
let s:nano_color_foreground = { "gui": "#37474F", "cterm": "8"   } "Blue Grey / L800


function! s:h(group, style)
  execute "highlight" a:group
        \ "guifg="   (has_key(a:style, "fg")    ? a:style.fg.gui   : "NONE")
        \ "guibg="   (has_key(a:style, "bg")    ? a:style.bg.gui   : "NONE")
        \ "guisp="   (has_key(a:style, "sp")    ? a:style.sp.gui   : "NONE")
        \ "gui="     (has_key(a:style, "gui")   ? a:style.gui      : "NONE")
        \ "ctermfg=" (has_key(a:style, "fg")    ? a:style.fg.cterm : "NONE")
        \ "ctermbg=" (has_key(a:style, "bg")    ? a:style.bg.cterm : "NONE")
        \ "cterm="   (has_key(a:style, "cterm") ? a:style.cterm    : "NONE")
endfunction


" __Normal__
if has("gui")
  call s:h("Normal", {"fg": s:nano_color_foreground, "bg": s:nano_color_background})
  call s:h("Cursor", {"fg": s:nano_color_subtle,     "bg": s:nano_color_foreground})
else
  call s:h("Normal", {"fg": s:nano_color_foreground})
  hi! link Cursor    Identifier
endif
hi! link Identifier       Normal
hi! link Function         Identifier
hi! link Type             Normal
hi! link StorageClass     Type
hi! link Structure        Type
hi! link Typedef          Type
hi! link Special          Normal
hi! link SpecialChar      Special
hi! link Tag              Special
hi! link Delimiter        Special
hi! link SpecialComment   Special
hi! link Debug            Special
hi! link VertSplit        Normal
hi! link PreProc          Normal
hi! link Define           PreProc
hi! link Macro            PreProc
hi! link PreCondit        PreProc

" __Operator__
call s:h("Noise",         {"fg": s:nano_color_subtle, "gui": "NONE"})
hi! link LineNr           Noise
hi! link CursorLineNr     LineNr
hi! link FoldColumn       LineNr
hi! link SignColumn       LineNr

" __Comment__
call s:h("Comment",       {"fg": s:nano_color_faded, "gui": "NONE"})

" __Constant__
call s:h("Constant",      {"fg": s:nano_color_faded})
hi! link Character        Constant
hi! link Number           Constant
hi! link Boolean          Constant
hi! link Float            Constant
hi! link String           Constant
hi! link Directory        Constant
hi! link Title            Constant

" __Statement__
call s:h("Statement",     {"fg": s:nano_color_salient, "gui": "NONE"})
hi! link Operator         Statement
hi! link Include          Statement
hi! link Conditonal       Statement
hi! link Repeat           Statement
hi! link Label            Statement
hi! link Keyword          Statement
hi! link Exception        Statement

" __ErrorMsg__
call s:h("ErrorMsg",      {"fg": s:nano_color_popout})
hi! link Error            ErrorMsg
hi! link Question         ErrorMsg
" __WarningMsg__
call s:h("WarningMsg",    {"fg": s:nano_color_critical})
" __MoreMsg__
call s:h("MoreMsg",       {"fg": s:nano_color_faded, "cterm": "bold", "gui": "bold"})
hi! link ModeMsg          MoreMsg

" __NonText__
call s:h("NonText",       {"fg": s:nano_color_subtle})
hi! link Folded           NonText
hi! link qfLineNr         NonText

" __Search__
call s:h("Search",        {"bg": s:nano_color_subtle, "fg": s:nano_color_foreground})
call s:h("IncSearch",     {"bg": s:nano_color_subtle, "fg": s:nano_color_foreground, "gui": "bold"})

" __Visual__
call s:h("Visual",        {"bg": s:nano_color_subtle})
" __VisualNOS__
call s:h("VisualNOS",     {"bg": s:nano_color_subtle})

call s:h("Ignore",        {"fg": s:nano_color_subtle})

" __DiffAdd__
call s:h("DiffAdd",       {"fg": s:nano_color_strong})
" __DiffDelete__
call s:h("DiffDelete",    {"fg": s:nano_color_popout})
" __DiffChange__
call s:h("DiffChange",    {"fg": s:nano_color_critical})
" __DiffText__
call s:h("DiffText",      {"fg": s:nano_color_faded})

if has("gui_running")
  call s:h("SpellBad",    {"gui": "underline", "sp": s:nano_color_popout})
  call s:h("SpellCap",    {"gui": "underline", "sp": s:nano_color_popout})
  call s:h("SpellRare",   {"gui": "underline", "sp": s:nano_color_popout})
  call s:h("SpellLocal",  {"gui": "underline", "sp": s:nano_color_popout})
else
  call s:h("SpellBad",    {"cterm": "underline", "fg": s:nano_color_popout})
  call s:h("SpellCap",    {"cterm": "underline", "fg": s:nano_color_popout})
  call s:h("SpellRare",   {"cterm": "underline", "fg": s:nano_color_popout})
  call s:h("SpellLocal",  {"cterm": "underline", "fg": s:nano_color_popout})
endif

hi! link helpHyperTextEntry Title
hi! link helpHyperTextJump  String

" __StatusLine__
call s:h("StatusLine",        {"gui": "NONE", "bg": s:nano_color_subtle, "fg": s:nano_color_foreground})
" __StatusLineNC__
call s:h("StatusLineNC",      {"gui": "NONE", "bg": s:nano_color_subtle, "fg": s:nano_color_background})
" __WildMenu__
call s:h("WildMenu",          {"gui": "underline,bold", "bg": s:nano_color_subtle, "fg": s:nano_color_foreground})

call s:h("StatusLineOk",      {"gui": "underline", "bg": s:nano_color_subtle, "fg": s:nano_color_foreground})
call s:h("StatusLineError",   {"gui": "underline", "bg": s:nano_color_subtle, "fg": s:nano_color_popout})
call s:h("StatusLineWarning", {"gui": "underline", "bg": s:nano_color_subtle, "fg": s:nano_color_critical})

" __Pmenu__
call s:h("Pmenu",         {"fg": s:nano_color_foreground, "bg": s:nano_color_highlight})
hi! link PmenuSbar        Pmenu
hi! link PmenuThumb       Pmenu
" __PmenuSel__
call s:h("PmenuSel",      {"fg": s:nano_color_foreground, "bg": s:nano_color_highlight, "gui": "bold"})

hi! link TabLine          Normal
hi! link TabLineSel       Keyword
hi! link TabLineFill      Normal

" __CursorLine__
call s:h("CursorLine",    {"bg": s:nano_color_highlight})
" __CursorColumn__
call s:h("ColorColumn",   {"bg": s:nano_color_highlight})

" __MatchParen__
call s:h("MatchParen",    {"bg": s:nano_color_subtle, "fg": s:nano_color_foreground})


hi! link htmlH1 Normal
hi! link htmlH2 Normal
hi! link htmlH3 Normal
hi! link htmlH4 Normal
hi! link htmlH5 Normal
hi! link htmlH6 Normal

hi link diffRemoved              DiffDelete
hi link diffAdded                DiffAdd

" Signify, git-gutter
hi link SignifySignAdd           LineNr
hi link SignifySignDelete        LineNr
hi link SignifySignChange        LineNr
hi link GitGutterAdd             LineNr
hi link GitGutterDelete          LineNr
hi link GitGutterChange          LineNr
hi link GitGutterChangeDelete    LineNr

hi link jsFlowTypeKeyword        Statement
hi link jsFlowImportType         Statement
hi link jsFunction               Statement
hi link jsGlobalObjects          Normal
hi link jsGlobalNodeObjects      Normal
hi link jsArrowFunction          Noise
hi link StorageClass             Statement

hi link xmlTag                   Constant
hi link xmlTagName               xmlTag
hi link xmlEndTag                xmlTag
hi link xmlAttrib                xmlTag

hi link markdownH1               Statement
hi link markdownH2               Statement
hi link markdownH3               Statement
hi link markdownH4               Statement
hi link markdownH5               Statement
hi link markdownH6               Statement
hi link markdownListMarker       Normal
hi link markdownCode             Constant
hi link markdownCodeBlock        Constant
hi link markdownCodeDelimiter    Constant
hi link markdownHeadingDelimiter Constant

hi link yamlBlockMappingKey      Statement
hi link pythonOperator           Statement

hi link ALEWarning               WarningMsg
hi link ALEWarningSign           WarningMsg
hi link ALEError                 ErrorMsg
hi link ALEErrorSign             ErrorMsg
hi link ALEInfo                  InfoMsg
hi link ALEInfoSign              InfoMsg

hi link sqlStatement             Statement
hi link sqlKeyword               Keyword
