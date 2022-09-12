" Name:    nanovim.vim
" Licence: MIT


hi clear
set laststatus=2 signcolumn=yes noshowmode nonumber
if exists('g:syntax_on') | syntax reset | endif
let g:colors_name = 'nanovim'

" Colors {{
if &background ==# 'light'
  let s:nano_color_background = { "gui": "#FFFFFF", "cterm": "15"  }
  let s:nano_color_strong     = { "gui": "#000000", "cterm": "0"   }
  let s:nano_color_critical   = { "gui": "#FF6F00", "cterm": "207" }
  let s:nano_color_popout     = { "gui": "#FFAB91", "cterm": "216" }
  let s:nano_color_salient    = { "gui": "#673AB7", "cterm": "98"  }
  let s:nano_color_highlight  = { "gui": "#FAFAFA", "cterm": "255" }
  let s:nano_color_subtle     = { "gui": "#ECEFF1", "cterm": "254" }
  let s:nano_color_faded      = { "gui": "#B0BEC5", "cterm": "249" }
  let s:nano_color_foreground = { "gui": "#37474F", "cterm": "237" }
elseif &background ==# 'dark'
  let s:nano_color_background = { "gui": "#2E3440", "cterm": "235" }
  let s:nano_color_strong     = { "gui": "#ECEFF4", "cterm": "15"  }
  let s:nano_color_critical   = { "gui": "#EBCB8B", "cterm": "222" }
  let s:nano_color_popout     = { "gui": "#D08770", "cterm": "209" }
  let s:nano_color_salient    = { "gui": "#81A1C1", "cterm": "110" }
  let s:nano_color_highlight  = { "gui": "#3B4252", "cterm": "238" }
  let s:nano_color_subtle     = { "gui": "#434C5E", "cterm": "240" }
  let s:nano_color_faded      = { "gui": "#677691", "cterm": "244" }
  let s:nano_color_foreground = { "gui": "#ECEFF4", "cterm": "15"  }
endif
" }}

" Faces {{
" Define highlight groups
function! s:h(group, style) abort
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
" Default face for the header line.
call s:h("Nano_Face_Header_Default", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_subtle
      \ })
" Critical face for the header line.
call s:h("Nano_Face_Header_Critical", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_critical
      \ })
" Popout face for the header line.
call s:h("Nano_Face_Header_Popout", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_popout
      \ })
" Strong face for the header line.
call s:h("Nano_Face_Header_Strong", {
      \ "fg": s:nano_color_foreground,
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
      \ "gui": "underline",
      \ "sp": s:nano_color_popout
      \ })
" __Spell__
call s:h("SpellBad", {
      \ "fg": s:nano_color_popout,
      \ "gui": "underline",
      \ "sp": s:nano_color_popout
      \ })
" __EndOfBuffer__
call s:h("EndOfBuffer", {
      \ "fg": s:nano_color_background,
      \ "bg": s:nano_color_background
      \ })
" __Underlined__
call s:h("Underlined", {
      \ "gui": "underline",
      \ "sp": s:nano_color_salient
      \ })
" }}

" Links {{
hi! link Boolean Nano_Face_Faded
hi! link Character Nano_Face_Faded
hi! link Comment Nano_Face_Faded
hi! link Conditonal Nano_Face_Salient
hi! link Constant Nano_Face_Salient
hi! link CursorLineNr Nano_Face_Faded
hi! link Debug Nano_Face_Default
hi! link Define Nano_Face_Default
hi! link Delimiter Nano_Face_Default
hi! link Directory Nano_Face_Faded
hi! link Error Nano_Face_Popout
hi! link ErrorMsg Nano_Face_Popout
hi! link Exception Nano_Face_Salient
hi! link Float Nano_Face_Faded
hi! link FoldColumn Nano_Face_Faded
hi! link Folded Nano_Face_Subtle
hi! link Function Nano_Face_Strong
hi! link Identifier Nano_Face_Default
hi! link Include Nano_Face_Salient
hi! link Keyword Nano_Face_Salient
hi! link Label Nano_Face_Salient
hi! link LineNr Nano_Face_Subtle
hi! link Macro Nano_Face_Default
hi! link ModeMsg Nano_Face_Faded
hi! link MoreMsg Nano_Face_Faded
hi! link NonText Nano_Face_Subtle
hi! link Number Nano_Face_Faded
hi! link Operator Nano_Face_Salient
hi! link PreCondit Nano_Face_Default
hi! link PreProc Nano_Face_Default
hi! link Question Nano_Face_Popout
hi! link Repeat Nano_Face_Salient
hi! link Search Nano_Face_Header_Default
hi! link SignColumn Nano_Face_Faded
hi! link Special Nano_Face_Default
hi! link SpecialChar Nano_Face_Default
hi! link SpecialComment Nano_Face_Default
hi! link SpecialKey Nano_Face_Faded
hi! link Statement Nano_Face_Salient
hi! link StorageClass Nano_Face_Default
hi! link String Nano_Face_Popout
hi! link Structure Nano_Face_Default
hi! link TabLine Nano_Face_Faded
hi! link TabLineFill Nano_Face_Default
hi! link TabLineSel Nano_Face_Strong
hi! link Tag Nano_Face_Default
hi! link Title Nano_Face_Faded
hi! link Todo Nano_Face_Header_Popout
hi! link Type Nano_Face_Salient
hi! link Typedef Nano_Face_Salient
hi! link VertSplit Nano_Face_Subtle
hi! link WarningMsg Nano_Face_Popout
hi! link healthSuccess Nano_Face_Header_Faded
hi! link healthWarning Nano_Face_Header_Popout
hi! link healthError Nano_Face_Header_Critical
hi! link helpHyperTextEntry Nano_Face_Salient
hi! link helpHyperTextJump Nano_Face_Popout
hi! link qfLineNr Nano_Face_Subtle
hi! link PmenuSbar Pmenu
hi! link PmenuThumb Pmenu
hi! link SpellCap SpellBad
hi! link SpellRare SpellBad
hi! link SpellLocal SpellBad
" Diff
hi! link DiffAdd Nano_Face_Strong
hi! link DiffChange Nano_Face_Critical
hi! link DiffDelete Nano_Face_Popout
hi! link DiffText Nano_Face_Faded
hi! link diffAdded Nano_Face_Popout
hi! link diffRemoved Nano_Face_Popout
" XML
hi! link xmlTag Nano_Face_Salient
hi! link xmlTagName Nano_Face_Salient
hi! link xmlEndTag Nano_Face_Salient
hi! link xmlAttrib Nano_Face_Salient
" HTML
hi! link htmlH1 Nano_Face_Salient
hi! link htmlH2 Nano_Face_Salient
hi! link htmlH3 Nano_Face_Salient
hi! link htmlH4 Nano_Face_Strong
hi! link htmlH5 Nano_Face_Strong
hi! link htmlH6 Nano_Face_Strong
hi! link htmlUnderline Underlined
" Markdown
hi! link markdownH1 Nano_Face_Salient
hi! link markdownH2 Nano_Face_Salient
hi! link markdownH3 Nano_Face_Salient
hi! link markdownH4 Nano_Face_Salient
hi! link markdownH5 Nano_Face_Salient
hi! link markdownH6 Nano_Face_Salient
hi! link markdownBold Nano_Face_Strong
hi! link markdownItalic Nano_Face_Salient
hi! link markdownBoldItalic Nano_Face_Strong
hi! link markdownCode Nano_Face_Popout
hi! link markdownUrl Nano_Face_Subtle
hi! link markdownLinkText Nano_Face_Popout
hi! link markdownHeadingDelimiter Nano_Face_Salient
hi! link markdownBoldDelimiter Nano_Face_Subtle
hi! link markdownItalicDelimiter Nano_Face_Subtle
hi! link markdownBoldItalicDelimiter Nano_Face_Subtle
hi! link markdownCodeDelimiter Nano_Face_Subtle
hi! link markdownLinkDelimiter Nano_Face_Subtle
hi! link markdownLinkTextDelimiter Nano_Face_Subtle
hi! link markdownTSEmphasis Nano_Face_Salient
hi! link markdownTSLiteral Nano_Face_Popout
hi! link markdownTSNone Nano_Face_Faded
hi! link markdownTSPunctSpecial Nano_Face_Salient
hi! link markdownTSPunctDelimiter Nano_Face_Subtle
hi! link markdownTSStringEscape Nano_Face_Salient
hi! link markdownTSStrong Nano_Face_Strong
hi! link markdownTSTextReference Nano_Face_Popout
hi! link markdownTSTitle Nano_Face_Salient
hi! link markdownTSURI Nano_Face_Subtle
" Misc
hi! link yamlBlockMappingKey Nano_Face_Salient
hi! link pythonOperator Nano_Face_Salient
hi! link sqlStatement Nano_Face_Salient
hi! link sqlKeyword Nano_Face_Salient

" Terminal
if has("nvim")
  "" Base
  let g:terminal_color_0  = s:nano_color_foreground.gui
  let g:terminal_color_8  = s:nano_color_background.gui
  "" Red
  let g:terminal_color_1  = s:nano_color_popout.gui
  let g:terminal_color_9  = s:nano_color_critical.gui
  "" Green
  let g:terminal_color_2  = s:nano_color_foreground.gui
  let g:terminal_color_10 = s:nano_color_faded.gui
  "" Yellow
  let g:terminal_color_3  = s:nano_color_strong.gui
  let g:terminal_color_11 = s:nano_color_foreground.gui
  "" Blue
  let g:terminal_color_4  = s:nano_color_salient.gui
  let g:terminal_color_12 = s:nano_color_foreground.gui
  "" Magenta
  let g:terminal_color_5  = s:nano_color_foreground.gui
  let g:terminal_color_13 = s:nano_color_faded.gui
  "" Cyan
  let g:terminal_color_6  = s:nano_color_foreground.gui
  let g:terminal_color_14 = s:nano_color_faded.gui
  "" Gray
  let g:terminal_color_7  = s:nano_color_faded.gui
  let g:terminal_color_15 = s:nano_color_subtle.gui
elseif exists('*term_setansicolors')
  let g:terminal_ansi_colors = [
        \ s:nano_color_foreground.gui,
        \ s:nano_color_popout.gui,
        \ s:nano_color_foreground.gui,
        \ s:nano_color_strong.gui,
        \ s:nano_color_salient.gui,
        \ s:nano_color_foreground.gui,
        \ s:nano_color_foreground.gui,
        \ s:nano_color_faded.gui,
        \ s:nano_color_background.gui,
        \ s:nano_color_critical.gui,
        \ s:nano_color_faded.gui,
        \ s:nano_color_foreground.gui,
        \ s:nano_color_foreground.gui,
        \ s:nano_color_faded.gui,
        \ s:nano_color_faded.gui,
        \ s:nano_color_subtle.gui
        \ ]
endif
" }}

" Plugins {{
" Signify, git-gutter
hi! link SignifySignAdd Nano_Face_Faded
hi! link SignifySignDelete Nano_Face_Faded
hi! link SignifySignChange Nano_Face_Faded
hi! link GitGutterAdd Nano_Face_Faded
hi! link GitGutterDelete Nano_Face_Faded
hi! link GitGutterChange Nano_Face_Faded
hi! link GitGutterChangeDelete Nano_Face_Faded
" nvim-tree
hi! link NvimTreeSymlink Nano_Face_Subtle
hi! link NvimTreeFolderName Nano_Face_Faded
hi! link NvimTreeRootFolder Nano_Face_Salient
hi! link NvimTreeFolderIcon Nano_Face_Faded
hi! link NvimTreeEmptyFolderName Nano_Face_Subtle
hi! link NvimTreeOpenedFolderName Nano_Face_Strong
hi! link NvimTreeExecFile Nano_Face_Salient
hi! link NvimTreeMarkdownFile StatusLineWarning
hi! link NvimTreeIndentMarker Nano_Face_Faded
hi! link NvimTreeGitDirty Nano_Face_Popout
hi! link NvimTreeGitStaged Nano_Face_Salient
hi! link NvimTreeGitNew Nano_Face_Popout
" nvim-cmp
call s:h("CmpItemAbbr", { "fg": s:nano_color_faded })
call s:h("CmpItemAbbrDeprecated", { "fg": s:nano_color_subtle })
call s:h("CmpItemAbbrMatch", { "fg": s:nano_color_salient })
call s:h("CmpItemAbbrMatchFuzzy", { "fg": s:nano_color_salient })
call s:h("CmpItemKind", { "fg": s:nano_color_popout })
call s:h("CmpItemMenu", { "fg": s:nano_color_popout })
" Vimwiki
hi! link VimwikiHeaderChar Nano_Face_Salient
hi! link VimwikiHeader1 markdownH1
hi! link VimwikiHeader2 markdownH2
hi! link VimwikiHeader3 markdownH3
hi! link VimwikiHeader4 markdownH4
hi! link VimwikiHeader5 markdownH5
hi! link VimwikiHeader6 markdownH6
hi! link VimwikiUnderline Underlined
hi! link VimwikiCode Nano_Face_Popout
hi! link VimwikiPre Nano_Face_Faded
hi! link VimwikiPreDelim Nano_Face_Subtle
" Neogit
call s:h("NeogitNotificationInfo", { "fg": s:nano_color_salient })
call s:h("NeogitNotificationInfo", { "fg": s:nano_color_popout })
call s:h("NeogitNotificationInfo", { "fg": s:nano_color_critical })
call s:h("NeogitDiffAddHighlight", {
      \ "fg": s:nano_color_salient,
      \ "bg": s:nano_color_subtle
      \ })
call s:h("NeogitDiffDeleteHighlight", {
      \ "fg": s:nano_color_popout,
      \ "bg": s:nano_color_subtle
      \ })
call s:h("NeogitDiffContextHighlight", {
      \ "fg": s:nano_color_strong,
      \ "bg": s:nano_color_highlight
      \ })
call s:h("NeogitHunkHeader", {
      \ "fg": s:nano_color_foreground,
      \ "bg": s:nano_color_highlight
      \ })
call s:h("NeogitHunkHeaderHighlight", {
      \ "fg": s:nano_color_faded,
      \ "bg": s:nano_color_highlight
      \ })
" }}

" StatusLine {{
set showtabline=0
if has("nvim-0.7") | set laststatus=3 | endif

let s:nanovim_mode = {
      \ 'c'     : ' CO ',
      \ 'i'     : ' IN ',
      \ 'ic'    : ' IC ',
      \ 'ix'    : ' IX ',
      \ 'n'     : ' NM ',
      \ 'nt'    : ' TN ',
      \ 'multi' : ' MU ',
      \ 'niI'   : ' ĨN ',
      \ 'no'    : ' OP ',
      \ 'R'     : ' RP ',
      \ 'Rv'    : ' RP ',
      \ 's'     : ' SC ',
      \ 'S'     : ' SL ',
      \ 't'     : ' TM ',
      \ 'v'     : ' VC ',
      \ 'V'     : ' VL ',
      \ ''    : ' VB ',
      \ }

let s:nanovim_short_ft = [
      \ 'NvimTree', 'help', 'netrw',
      \ 'nerdtree', 'qf', 'aerial',
      \ '__GonvimMarkdownPreview__',
      \ ]

" Get the branch
function! s:get_git_branch() abort
  let l:current_dir = expand('%:p:h')
  let l:is_git_repo = 0
  while 1
    if !empty(globpath(l:current_dir, ".git", 1))
      let l:is_git_repo = 1
      break
    endif
    let l:temp_dir = l:current_dir
    let l:current_dir = fnamemodify(l:current_dir, ':h')
    if l:temp_dir ==# l:current_dir
      break
    endif
  endwhile
  if l:is_git_repo
    let l:git_root = substitute(l:current_dir, '\v[\\/]$', '', '')
    let l:dot_git = l:git_root . '/.git'
    if isdirectory(l:dot_git)
      let l:head_file = l:git_root . '/.git/HEAD'
    else
      try
        let l:gitdir_line = readfile(l:dot_git)[0]
        let l:gitdir_matches = matchlist(l:gitdir_line, '\v^gitdir:\s(.+)$')
        if len(l:gitdir_matches) > 0
          let l:gitdir = l:gitdir_matches[1]
          let l:head_file = l:git_root . '/' . l:gitdir . '/HEAD'
        endif
      catch
        return ''
      endtry
    endif
    try
      let l:ref_line = readfile(l:head_file)[0]
      let l:ref_matches = matchlist(l:ref_line, '\vref:\s.+/(.{-})$')
      if len(l:ref_matches) > 0
        let l:branch = l:ref_matches[1]
        if !empty(l:branch)
          return l:branch
        endif
      endif
    catch
      return ''
    endtry
  endif
  return ''
endfunction

function! s:cap_str_init(str) abort
  if !empty(a:str)
    return toupper(a:str[0]) . a:str[1:]
  endif
  return a:str
endfunction

" Get mode.
" It is better to use just one character to show the mode.
function! NanoGetMode() abort
  return has_key(s:nanovim_mode, mode(1)) ? s:nanovim_mode[mode(1)] : ' _ '
endfunction

" Get file name.
" Shorten then file name when the window is too narrow.
function! NanoGetFname() abort
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
  let width = &laststatus == 3 ? &co : winwidth(0)
  let l:file_path_str_width = strdisplaywidth(l:file_path)
  if l:file_path_str_width > width * 0.7
    return l:file_name
  endif
  if l:file_path_str_width > width * 0.4
    let l:path_list = split(l:file_dir, l:path_sepr)
    let l:path_head = "/"
    if has('win32')
      let l:path_head = remove(l:path_list, 0) . "\\"
    endif
    for l:d in l:path_list
      let l:dir = split(l:d, '\zs')
      if empty(l:dir) | return "" | endif
      if l:dir[0] !=# '.'
        let l:dir_short = l:dir[0]
      elseif len(l:dir) > 1
        let l:dir_short = l:dir[0] . l:dir[1]
      else
        let l:dir_short = '.'
      endif
      let l:path_head .= l:dir_short . l:path_sepr
    endfor
    return l:path_head . l:file_name
  endif
  return l:file_path
endfunction

" (filetype, branch)
function! NanoMiscInfo() abort
  let l:ft = split(&ft, '\.')
  call map(l:ft, {_, val -> s:cap_str_init(val)})
  let l:ls = filter([join(l:ft, '|'), s:get_git_branch()], '!empty(v:val)')
  if len(l:ls) | return '(' . join(l:ls, ', ') .')' | else | return '' | endif
endfunction

" When enter/leave the buffer/window, set the status line.
" Long:
" | MODE | file_name (file_type, git_branch)                      line:column |
" Short:
" | file_name                                                                 |
function! s:on_enter() abort
  if index(s:nanovim_short_ft, &ft) >= 0
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Default# %= %y %#Nano_Face_Default# "
  else
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Faded#%{&modified?'':NanoGetMode()}" .
          \ "%#Nano_Face_Header_Popout#%{&modified?NanoGetMode():''}" .
          \ "%#Nano_Face_Header_Strong# %{NanoGetFname()}%<" .
          \ "%#Nano_Face_Header_Default#  %{&bt=='terminal'?'':NanoMiscInfo()}" .
          \ "%= %l:%c %#Nano_Face_Default# "
  endif
endfunction

function! s:on_leave() abort
  if index(s:nanovim_short_ft, &ft) < 0
    let &l:stl = "%#Nano_Face_Default# " .
          \ "%#Nano_Face_Header_Subtle# %{NanoGetFname()}" .
          \ "%= %#Nano_Face_Default# "
  endif
endfunction

augroup nanovim_redrawstatus
  autocmd!
  autocmd FileChangedShellPost * redrawstatus
  autocmd BufEnter,WinEnter,VimEnter * call <SID>on_enter()
  autocmd BufLeave,WinLeave * call <SID>on_leave()
augroup end
" }}

" vim: set sw=2 ts=2 sts=2 foldmarker={{,}} foldmethod=marker foldlevel=0:
