" Name:    nanovim.vim
" Licence: MIT

let s:nanovim_mode={
      \ 'c'     : ' C ',
      \ 'i'     : ' I ',
      \ 'ic'    : ' I ',
      \ 'ix'    : ' I ',
      \ 'n'     : ' N ',
      \ 'multi' : ' M ',
      \ 'niI'   : ' Ĩ ',
      \ 'no'    : ' N ',
      \ 'R'     : ' R ',
      \ 'Rv'    : ' R ',
      \ 's'     : ' S ',
      \ 'S'     : ' S ',
      \ 't'     : ' T ',
      \ 'v'     : ' v ',
      \ 'V'     : ' V ',
      \ ''    : ' B ',
      \ }

hi clear
set laststatus=2
set noshowmode
if exists('syntax on') | syntax reset | endif
let g:colors_name = 'nanovim'

" Colors {{
if &background ==# 'light'
  let s:nano_color_background = { "gui": "#FFFFFF", "cterm": "15"  } "White
  let s:nano_color_strong     = { "gui": "#000000", "cterm": "0"   } "Black
  let s:nano_color_critical   = { "gui": "#FF6F00", "cterm": "207" } "Amber
  let s:nano_color_popout     = { "gui": "#FFAB91", "cterm": "216" } "Deep Orange
  let s:nano_color_salient    = { "gui": "#673AB7", "cterm": "98"  } "Deep Purple
  let s:nano_color_highlight  = { "gui": "#F9F9F9", "cterm": "255" } "Very Light Grey
  let s:nano_color_subtle     = { "gui": "#ECEFF1", "cterm": "254" } "Blue Grey / L50
  let s:nano_color_faded      = { "gui": "#B0BEC5", "cterm": "249" } "Blue Grey / L200
  let s:nano_color_foreground = { "gui": "#37474F", "cterm": "237" } "Blue Grey / L800
elseif &background ==# 'dark'
  let s:nano_color_background = { "gui": "#2E3440", "cterm": "235" } "Polar Night 0 / nord 0
  let s:nano_color_strong     = { "gui": "#ECEFF4", "cterm": "15"  } "Snow Storm 3  / nord 6
  let s:nano_color_critical   = { "gui": "#EBCB8B", "cterm": "222" } "Aurora        / nord 11
  let s:nano_color_popout     = { "gui": "#D08770", "cterm": "209" } "Aurora        / nord 12
  let s:nano_color_salient    = { "gui": "#81A1C1", "cterm": "110" } "Frost         / nord 9
  let s:nano_color_highlight  = { "gui": "#3B4252", "cterm": "238" } "Polar Night 1 / nord 1
  let s:nano_color_subtle     = { "gui": "#434C5E", "cterm": "240" } "Polar Night 2 / nord 2
  let s:nano_color_faded      = { "gui": "#616E87", "cterm": "244" }
  let s:nano_color_foreground = { "gui": "#ECEFF4", "cterm": "15"  } "Snow Storm 3  / nord 6
endif
" }}

" Faces {{
" Define highlight groups
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


" Default face is used for regular information.
call s:h("Nano_Face_Default", {
      \ "fg": s:nano_color_foreground
      \ })
" Critical face is for information that requires immediate action.
" It should be of high contrast when compared to other faces. This
" can be realized (for example) by setting an intense background
" color, typically a shade of red. It must be used scarcely.
call s:h("Nano_Face_Critical", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_critical
      \ })
" Popout face is used for information that needs attention.
" To achieve such effect, the hue of the face has to be
" sufficiently different from other faces such that it attracts
" attention through the popout effect.
call s:h("Nano_Face_Popout", {
      \ "fg": s:nano_color_popout
      \ })
" Strong face is used for information of a structural nature.
" It has to be the same color as the default color and only the
" weight differs by one level (e.g., light/regular or
" regular/bold). IT is generally used for titles, keywords,
" directory, etc.
call s:h("Nano_Face_Strong", {
      \ "fg": s:nano_color_strong
      \ })
" Salient face is used for information that are important.
" To suggest the information is of the same nature but important,
" the face uses a different hue with approximately the same
" intensity as the default face. This is typically used for links.
call s:h("Nano_Face_Salient", {
      \ "fg": s:nano_color_salient
      \ })
" Faded face is for information that are less important.
" It is made by using the same hue as the default but with a lesser
" intensity than the default. It can be used for comments,
" secondary information and also replace italic (which is generally
" abused anyway).
call s:h("Nano_Face_Faded", {
      \ "fg": s:nano_color_faded
      \ })
" Subtle face is used to suggest a physical area on the screen.
" It is important to not disturb too strongly the reading of
" information and this can be made by setting a very light
" background color that is barely perceptible.
call s:h("Nano_Face_Subtle", {
      \ "fg": s:nano_color_subtle
      \ })
" Subtle face for the statusline.
call s:h("Nano_Face_Status_Subtle", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle
      \ })
" Default face for the header line.
call s:h("Nano_Face_Header_Default", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle
      \ })
" Critical face for the header line.
call s:h("Nano_Face_Header_Critical", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_critical
      \ })
" Popout face for the header line.
call s:h("Nano_Face_Header_Popout", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_popout
      \ })
" Strong face for the header line.
call s:h("Nano_Face_Header_Strong", {
      \ "fg": s:nano_color_strong,
      \ "bg": s:nano_color_subtle
      \ })
" Salient face for the header line.
call s:h("Nano_Face_Header_Salient", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_salient
      \ })
" Faded face for the header line.
call s:h("Nano_Face_Header_Faded", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_faded
      \ })
" Subtle face for the header line.
call s:h("Nano_Face_Header_Subtle", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_subtle
      \ })


" __Normal__
call s:h("Normal", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_background
      \ })
" __Cursor__
call s:h("Cursor", {
      \ "fg": s:nano_color_subtle,
      \ "bg": s:nano_color_foreground
      \ })
" __Search__
call s:h("IncSearch", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "bold"
      \ })
" __Visual__
call s:h("Visual", {
      \ "bg": s:nano_color_subtle
      \ })
" __VisualNOS__
call s:h("VisualNOS", {
      \ "bg": s:nano_color_subtle
      \ })
" __Ignore__
call s:h("Ignore", {
      \ "fg": s:nano_color_subtle
      \ })
" __StatusLine__
call s:h("StatusLine", {
      \ "fg": s:nano_color_foreground,
      \ })
call s:h("StatusLineNC", {
      \ "fg": s:nano_color_background,
      \ })
call s:h("StatusLineOk", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
call s:h("StatusLineError", {
      \ "fg": s:nano_color_popout,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
call s:h("StatusLineWarning", {
      \ "fg": s:nano_color_critical,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline"
      \ })
" __WildMenu__
call s:h("WildMenu", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "underline,bold"
      \ })
" __Pmenu__
call s:h("Pmenu", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_highlight
      \ })
" __PmenuSel__
call s:h("PmenuSel", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle,
      \ "gui": "bold"
      \ })
" __CursorLine__
call s:h("CursorLine", {
      \ "bg": s:nano_color_highlight
      \ })
" __CursorColumn__
call s:h("ColorColumn", {
      \ "bg": s:nano_color_highlight
      \ })
" __MatchParen__
call s:h("MatchParen", {
      \ "fg": s:nano_color_popout,
      \ "gui": "underline"
      \ })
" __Spell__
call s:h("SpellBad", {
      \ "fg": s:nano_color_popout,
      \ "gui": "underline"
      \ })
" }}

" Links {{
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
hi! link VertSplit               Nano_Face_Subtle
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
hi! link TabLine                 Nano_Face_Faded
hi! link TabLineSel              Nano_Face_Strong
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
" }}

" StatusLine {{
" Get mode
function! Nanovim_Get_Mode()
  return has_key(s:nanovim_mode, mode(1)) ? s:nanovim_mode[mode(1)] : '_'
endfunction

" Get file name
function! Nanovim_Get_File_Name()
  let l:file_path = expand('%:p')
  let l:file_dir  = expand('%:p:h')
  let l:file_name = expand('%:t')
  
  if empty(l:file_name)
    return "[No Name]"
  endif

  let l:path_sepr = "/"
  if has('win32')
    let l:path_sepr = "\\"
  endif

  if strlen(l:file_path) > 40
    let l:path_list = split(l:file_dir, l:path_sepr)
    let l:path_head = "/"
    if has('win32')
      let l:path_head = remove(l:path_list, 0) . "\\"
    endif
    for l:dir in l:path_list
      let l:path_head .= l:dir[0] . l:path_sepr
    endfor
    return l:path_head . l:file_name
  endif

  return l:file_path
endfunction

" Get the branch
function! Nanovim_Get_Git_Branch()
  let l:current_dir = expand('%:p:h')
  let l:is_git_repo = 0
  while 1
    if !empty(globpath(l:current_dir, ".git", 1)) | let l:is_git_repo = 1 | break | endif
    let [l:temp_dir, l:current_dir] = [l:current_dir, fnamemodify(l:current_dir, ':h')]
    if l:temp_dir == l:current_dir | break | endif
  endwhile
  if !l:is_git_repo | return '' | end
  try
    let l:content = readfile(l:current_dir . '/.git/HEAD')
    return '#' . split(l:content[0], '/')[-1]
  catch
    return ''
  endtry
endfunction

" | MODE || short_file_name git_branch        file_type file_encoding line:col |
function! s:nanovim_set_buf()
  set statusline=
  set statusline+=%#Nano_Face_Default#\ 
  set statusline+=%#Nano_Face_Header_Faded#%{&modified?'':Nanovim_Get_Mode()}
  set statusline+=%#Nano_Face_Header_Popout#%{&modified?Nanovim_Get_Mode():''}
  set statusline+=%#Nano_Face_Status_Subtle#\ %{Nanovim_Get_File_Name()}\ %{Nanovim_Get_Git_Branch()}
  set statusline+=%=
  set statusline+=%y\ %{strlen(&fenc)?&fenc:'none'}\ %l:%c\ 
  set statusline+=%#Nano_Face_Default#\ 
endfunction

augroup nanovim_set_buffer
  autocmd!
  autocmd BufEnter,FileChangedShellPost * call <SID>nanovim_set_buf()
augroup end
" }}

" vim:     set sw=2 ts=2 sts=2 foldmarker={{,}} foldmethod=marker foldlevel=0:
