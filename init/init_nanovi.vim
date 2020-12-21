" Name:    nanovim.vim
" Licence: MIT


let g:nanovi_mode={
      \ 'n'     : ' N ',
      \ 'v'     : ' V ',
      \ 'V'     : ' Ṿ ',
      \ ''    : ' Ṽ ',
      \ 'i'     : ' I ',
      \ 'R'     : ' R ',
      \ 'Rv'    : ' R ',
      \ 'c'     : ' C ',
      \ 't'     : ' T '
      \ }

hi clear
set statusline=
set fillchars=vert:\ 
set noshowmode
set background=light
if exists('syntax on') | syntax reset | endif
let g:colors_name = 'nanovim'


" Colors
let s:nano_color_background = { "gui": "#FFFFFF", "cterm": "255" } "White
let s:nano_color_strong     = { "gui": "#000000", "cterm": "0"   } "Black
let s:nano_color_critical   = { "gui": "#FF6F00", "cterm": "1"   } "Amber
let s:nano_color_popout     = { "gui": "#FFAB91", "cterm": "1"   } "Deep Orange
let s:nano_color_salient    = { "gui": "#673AB7", "cterm": "5"   } "Deep Purple
let s:nano_color_highlight  = { "gui": "#F9F9F9", "cterm": "251" } "Very Light Grey
let s:nano_color_subtle     = { "gui": "#ECEFF1", "cterm": "243" } "Blue Grey / L50
let s:nano_color_faded      = { "gui": "#B0BEC5", "cterm": "249" } "Blue Grey / L200
let s:nano_color_foreground = { "gui": "#37474F", "cterm": "8"   } "Blue Grey / L800


" Define highlight groups
function! s:def_face(group, style)
  execute "highlight" a:group
        \ "guifg="   (has_key(a:style, "fg")    ? a:style.fg.gui   : "NONE")
        \ "guibg="   (has_key(a:style, "bg")    ? a:style.bg.gui   : "NONE")
        \ "guisp="   (has_key(a:style, "sp")    ? a:style.sp.gui   : "NONE")
        \ "gui="     (has_key(a:style, "gui")   ? a:style.gui      : "NONE")
        \ "ctermfg=" (has_key(a:style, "fg")    ? a:style.fg.cterm : "NONE")
        \ "ctermbg=" (has_key(a:style, "bg")    ? a:style.bg.cterm : "NONE")
        \ "cterm="   (has_key(a:style, "cterm") ? a:style.cterm    : "NONE")
endfunction

" Get the branck name without git
function! s:nanovi_get_branch()
  let l:git_root = Lib_Get_Git_Root()
  if l:git_root[0] == 0
    let b:nanovi_branch = ''
  else
    try
      let l:content = readfile(l:git_root[1] . '/.git/HEAD')
      let b:nanovi_branch = '#' . split(l:content[0], '/')[-1]
    catch
      let b:nanovi_branch = ''
    endtry
  endif
endfunction

augroup nanovi_get_git_branch
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call <SID>nanovi_get_branch()
augroup END


" Default face is used for regular information.
call s:def_face("Nano_Face_Default", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_background
      \ })
" Critical face is for information that requires immediate action.
" It should be of high contrast when compared to other faces. This
" can be realized (for example) by setting an intense background
" color, typically a shade of red. It must be used scarcely.
call s:def_face("Nano_Face_Critical", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_critical
      \ })
" Popout face is used for information that needs attention.
" To achieve such effect, the hue of the face has to be
" sufficiently different from other faces such that it attracts
" attention through the popout effect.
call s:def_face("Nano_Face_Popout", {
      \ "fg": s:nano_color_popout
      \ })
" Strong face is used for information of a structural nature.
" It has to be the same color as the default color and only the
" weight differs by one level (e.g., light/regular or
" regular/bold). IT is generally used for titles, keywords,
" directory, etc.
call s:def_face("Nano_Face_Strong", {
      \ "fg": s:nano_color_strong
      \ })
" Salient face is used for information that are important.
" To suggest the information is of the same nature but important,
" the face uses a different hue with approximately the same
" intensity as the default face. This is typically used for links.
call s:def_face("Nano_Face_Salient", {
      \ "fg": s:nano_color_salient
      \ })
" Faded face is for information that are less important.
" It is made by using the same hue as the default but with a lesser
" intensity than the default. It can be used for comments,
" secondary information and also replace italic (which is generally
" abused anyway).
call s:def_face("Nano_Face_Faded", {
      \ "fg": s:nano_color_faded
      \ })
" Subtle face is used to suggest a physical area on the screen.
" It is important to not disturb too strongly the reading of
" information and this can be made by setting a very light
" background color that is barely perceptible.
call s:def_face("Nano_Face_Subtle", {
      \ "fg": s:nano_color_subtle
      \ })
" Default face for the header line.
call s:def_face("Nano_Face_Header_Default", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle
      \ })
" Critical face for the header line.
call s:def_face("Nano_Face_Header_Critical", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_critical
      \ })
" Popout face for the header line.
call s:def_face("Nano_Face_Header_Popout", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_popout
      \ })
" Strong face for the header line.
call s:def_face("Nano_Face_Header_Strong", {
      \ "fg": s:nano_color_strong,
      \ "bg": s:nano_color_subtle
      \ })
" Salient face for the header line.
call s:def_face("Nano_Face_Header_Salient", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_salient
      \ })
" Faded face for the header line.
call s:def_face("Nano_Face_Header_Faded", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_faded
      \ })
" Subtle face for the header line.
call s:def_face("Nano_Face_Header_Subtle", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_subtle
      \ })


" __Normal__
call s:def_face("Normal", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_background
      \ })
" __Cursor__
call s:def_face("Cursor", {
      \ "fg": s:nano_color_subtle,
      \ "bg": s:nano_color_foreground
      \ })
" __Search__
call s:def_face("IncSearch", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "bold"
      \ })
" __Visual__
call s:def_face("Visual", {
      \ "bg": s:nano_color_subtle
      \ })
" __VisualNOS__
call s:def_face("VisualNOS", {
      \ "bg": s:nano_color_subtle
      \ })
" __Ignore__
call s:def_face("Ignore", {
      \ "fg": s:nano_color_subtle
      \ })
" __StatusLine__
call s:def_face("StatusLine", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle
      \ })
" __StatusLineNC__
call s:def_face("StatusLineNC", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_subtle
      \ })
" __WildMenu__
call s:def_face("WildMenu", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline,bold"
      \ })
call s:def_face("StatusLineOk", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
call s:def_face("StatusLineError", {
      \ "fg": s:nano_color_popout,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
call s:def_face("StatusLineWarning", {
      \ "fg": s:nano_color_critical,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
" __Pmenu__
call s:def_face("Pmenu", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_highlight
      \ })
" __PmenuSel__
call s:def_face("PmenuSel", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "bold"
      \ })
" __CursorLine__
call s:def_face("CursorLine", {
      \ "bg": s:nano_color_highlight
      \ })
" __CursorColumn__
call s:def_face("ColorColumn", {
      \ "bg": s:nano_color_highlight
      \ })
" __MatchParen__
call s:def_face("MatchParen", {
      \ "fg": s:nano_color_popout,
      \ "bg": s:nano_color_background,
      \ "gui": "underline"
      \ })
" __Spell__
call s:def_face("SpellBad", {
      \ "fg": s:nano_color_popout,
      \ "gui": "underline"
      \ })


hi! link Identifier              Nano_Face_Default
hi! link Function                Nano_Face_Strong
hi! link Type                    Nano_Face_Salient
hi! link Comment                 Nano_Face_Faded
hi! link String                  Nano_Face_Popout
hi! link Constant                Nano_Face_Salient
hi! link WarningMsg              Nano_Face_Popout
hi! link Typedef                 Nano_Face_Salient
hi! link Keyword                 Nano_Face_Salient
hi! link ErrorMsg                Nano_Face_Popout
hi! link NonText                 Nano_Face_Subtle
hi! link MoreMsg                 Nano_Face_Faded
hi! link Statement               Nano_Face_Salient
hi! link Search                  Nano_Face_Header_Default
hi! link Todo                    Nano_Face_Header_Popout
hi! link Special                 Nano_Face_Default
hi! link VertSplit               Nano_Face_Header_Subtle
hi! link PreProc                 Nano_Face_Default
hi! link StorageClass            Nano_Face_Default
hi! link Structure               Nano_Face_Default
hi! link SpecialChar             Nano_Face_Default
hi! link SpecialKey              Nano_Face_Faded
hi! link Tag                     Nano_Face_Default
hi! link Delimiter               Nano_Face_Default
hi! link SpecialComment          Nano_Face_Default
hi! link Debug                   Nano_Face_Default
hi! link Define                  Nano_Face_Default
hi! link Macro                   Nano_Face_Default
hi! link PreCondit               Nano_Face_Default
hi! link LineNr                  Nano_Face_Faded
hi! link CursorLineNr            Nano_Face_Faded
hi! link FoldColumn              Nano_Face_Faded
hi! link SignColumn              Nano_Face_Faded
hi! link Character               Nano_Face_Faded
hi! link Number                  Nano_Face_Faded
hi! link Boolean                 Nano_Face_Faded
hi! link Float                   Nano_Face_Faded
hi! link Directory               Nano_Face_Faded
hi! link Title                   Nano_Face_Faded
hi! link Operator                Nano_Face_Salient
hi! link Include                 Nano_Face_Salient
hi! link Conditonal              Nano_Face_Salient
hi! link Repeat                  Nano_Face_Salient
hi! link Label                   Nano_Face_Salient
hi! link Exception               Nano_Face_Salient
hi! link Error                   Nano_Face_Popout
hi! link Question                Nano_Face_Popout
hi! link Folded                  Nano_Face_Subtle
hi! link qfLineNr                Nano_Face_Subtle
hi! link ModeMsg                 Nano_Face_Faded
hi! link helpHyperTextEntry      Nano_Face_Salient
hi! link helpHyperTextJump       Nano_Face_Popout
hi! link TabLine                 Nano_Face_Default
hi! link TabLineSel              Nano_Face_Salient
hi! link TabLineFill             Nano_Face_Default
hi! link htmlH1                  Nano_Face_Strong
hi! link htmlH2                  Nano_Face_Strong
hi! link htmlH3                  Nano_Face_Strong
hi! link htmlH4                  Nano_Face_Strong
hi! link htmlH5                  Nano_Face_Strong
hi! link htmlH6                  Nano_Face_Strong

hi! link PmenuSbar               Pmenu
hi! link PmenuThumb              Pmenu
hi! link SpellCap                SpellBad
hi! link SpellRare               SpellBad
hi! link SpellLocal              SpellBad

hi link DiffAdd                  Nano_Face_Strong
hi link DiffDelete               Nano_Face_Popout
hi link DiffChange               Nano_Face_Critical
hi link DiffText                 Nano_Face_Faded
hi link diffRemoved              Nano_Face_Popout
hi link diffAdded                Nano_Face_Popout

" Signify, git-gutter
hi link SignifySignAdd           Nano_Face_Faded
hi link SignifySignDelete        Nano_Face_Faded
hi link SignifySignChange        Nano_Face_Faded
hi link GitGutterAdd             Nano_Face_Faded
hi link GitGutterDelete          Nano_Face_Faded
hi link GitGutterChange          Nano_Face_Faded
hi link GitGutterChangeDelete    Nano_Face_Faded

hi link jsFlowTypeKeyword        Nano_Face_Salient
hi link jsFlowImportType         Nano_Face_Salient
hi link jsFunction               Nano_Face_Salient
hi link jsGlobalObjects          Nano_Face_Default
hi link jsGlobalNodeObjects      Nano_Face_Default
hi link jsArrowFunction          Nano_Face_Faded
hi link StorageClass             Nano_Face_Salient

hi link xmlTag                   Nano_Face_Salient
hi link xmlTagName               Nano_Face_Salient
hi link xmlEndTag                Nano_Face_Salient
hi link xmlAttrib                Nano_Face_Salient

hi link markdownH1               Nano_Face_Salient
hi link markdownH2               Nano_Face_Salient
hi link markdownH3               Nano_Face_Salient
hi link markdownH4               Nano_Face_Default
hi link markdownH5               Nano_Face_Default
hi link markdownH6               Nano_Face_Default
hi link markdownBold             Nano_Face_Strong
hi link markdownRule             Nano_Face_Faded
hi link markdownCode             Nano_Face_Popout
hi link markdownCodeBlock        Nano_Face_Faded
hi link markdownBlockquote       Nano_Face_Faded
hi link markdownHeadingRule      Nano_Face_Faded
hi link markdownListMarker       Nano_Face_Salient
hi link markdownCodeDelimiter    Nano_Face_Salient
hi link markdownHeadingDelimiter Nano_Face_Salient

hi link yamlBlockMappingKey      Nano_Face_Salient
hi link pythonOperator           Nano_Face_Salient

hi link ALEWarning               Nano_Face_Critical
hi link ALEWarningSign           Nano_Face_Critical
hi link ALEError                 Nano_Face_Critical
hi link ALEErrorSign             Nano_Face_Critical
hi link ALEInfo                  Nano_Face_Subtle
hi link ALEInfoSign              Nano_Face_Subtle

hi link sqlStatement             Nano_Face_Salient
hi link sqlKeyword               Nano_Face_Salient


" StatusLine
set laststatus=2
set statusline+=%#Normal#\ 
set statusline+=%#Nano_Face_Header_Faded#%{&modified?'':toupper(g:nanovi_mode[mode()])}
set statusline+=%#Nano_Face_Header_Popout#%{&modified?toupper(g:nanovi_mode[mode()]):''}
set statusline+=%#Nano_Face_Header_Subtle#▎
set statusline+=%#Statusline#%f\ %{b:nanovi_branch}%=%y\ %{strlen(&fenc)?&fenc:'none'}\ %l:%c\ 
set statusline+=%#Normal#\ 
