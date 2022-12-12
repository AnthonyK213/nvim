let s:session_dir = my#compat#stdpath('data') . '/sessions'

function s:coc_lsp_check(server, extension, enable="enable") abort
  let l:var_name = '_my_lsp_' . a:server
  if exists('g:' . l:var_name)
    let l:val = get(g:, l:var_name)
    if type(l:val) == v:t_bool
      if l:val
        call add(g:coc_global_extensions, a:extension)
      endif
      let g:coc_config_table[a:enable] = l:val
    elseif type(l:val) == v:t_dict
      if has_key(l:val, "load") && l:val["load"]
        call add(g:coc_global_extensions, a:extension)
        for [l:k, l:v] in items(l:val)
          if l:k ==# "load"
            let g:coc_config_table[a:enable] = v:true
          elseif l:k ==# "settings"
            call extend(g:coc_config_table, l:v, "force")
          else
            let g:coc_config_table[l:k] = l:v
          endif
        endfor
      else
        let g:coc_config_table[a:enable] = v:false
      endif
    else
      call my#lib#notify_err("Please check `lsp` in nvimrc.")
    endif
  endif
endfunction

function! s:coc_show_doc() abort
  if (index(['vim', 'help'], &filetype) >= 0)
    let l:word = my#lib#get_word()[0]
    try
      exe 'h' l:word
    catch
      echo "No help for '" . l:word . "'"
    endtry
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  endif
endfunction

function! s:crates_attach() abort
  call crates#toggle()
  nn <buffer><silent> <leader>cU :call crates#up()<CR>
endfunction

function! my#config#asyncomplete() abort
  " asyncomplete.vim
  let g:asyncomplete_auto_pop = 1
  let g:asyncomplete_auto_completeopt = 0
  let g:asyncomplete_min_chars = 2
  let g:asyncomplete_buffer_clear_cache = 1
  call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
        \ 'name': 'buffer',
        \ 'allowlist': ['*'],
        \ 'blocklist': [],
        \ 'completor': function('asyncomplete#sources#buffer#completor'),
        \ 'config': {
          \   'max_buffer_size': 5000000,
          \ },
          \ }))
  im <silent><expr> <TAB>
        \ pumvisible() ?
        \ "\<C-N>" : my#lib#get_context()['b'] =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
        \ "\<C-\>\<C-O>>>" . repeat(g:_const_dir_r, &ts) : vsnip#jumpable(1) ?
        \ "\<Plug>(vsnip-jump-next)" : my#lib#get_context()['p'] =~ '\v[a-z\._\u4e00-\u9fa5]' ?
        \ "\<Plug>(asyncomplete_force_refresh)" : "\<TAB>"
  im <silent><expr> <S-TAB>
        \ pumvisible() ?
        \ "\<C-P>" : vsnip#jumpable(-1) ?
        \ "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
  im <silent><expr> <CR> pumvisible() ? "\<C-Y>" : "\<Plug>(ipairs_enter)"
  " vim-vsnip
  let g:vsnip_snippet_dir = my#compat#stdpath('config') . '/snippet'
  smap <silent><expr> <TAB>   vsnip#jumpable(1)  ? "\<Plug>(vsnip-jump-next)" : "<TAB>"
  smap <silent><expr> <S-TAB> vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "<S-TAB>"
endfunction

function! my#config#coc() abort
  let g:loaded_netrw = 1
  let g:loaded_netrwPlugin = 1
  let g:coc_global_extensions = [
        \ 'coc-explorer',
        \ 'coc-snippets',
        \ 'coc-vimtex'
        \ ]
  let g:coc_config_table = {}
  call s:coc_lsp_check('clangd', 'coc-clangd', 'clangd.enabled')
  call s:coc_lsp_check('jedi_language_server', 'coc-jedi', 'jedi.enable')
  call s:coc_lsp_check('omnisharp', 'coc-omnisharp')
  call s:coc_lsp_check('powershell_es', 'coc-powershell')
  call s:coc_lsp_check('pyright', 'coc-pyright', 'pyright.enable')
  call s:coc_lsp_check('rust_analyzer', 'coc-rust-analyzer', 'rust-analyzer.enable')
  call s:coc_lsp_check('sumneko_lua', 'coc-sumneko-lua', 'sumneko-lua.enable')
  call s:coc_lsp_check('vimls', 'coc-vimlsp', 'vimlsp.diagnostic.enable')
  let l:snippet_dir = my#compat#stdpath('config') . '/snippet'
  let l:float_config = {
        \ 'border': index(['single', 'double', 'rounded'], g:_my_tui_border) >= 0,
        \ "rounded": g:_my_tui_border ==# 'rounded',
        \ }
  call extend(g:coc_config_table, {
        \ 'suggest.floatConfig': l:float_config,
        \ 'diagnostic.floatConfig': l:float_config,
        \ 'signature.floatConfig': l:float_config,
        \ 'hover.floatConfig': l:float_config,
        \ 'snippets.textmateSnippetsRoots' : [l:snippet_dir],
        \ 'snippets.ultisnips.enable' : v:false,
        \ 'snippets.snipmate.enable' : v:false,
        \ 'explorer.keyMappings.global' : {
          \ 's' : 'open:vsplit',
          \ 'i' : 'open:split',
          \ 'o' : 'systemExecute',
          \ 'u' : ['wait', 'gotoParent'],
          \ 'C' : ["wait", "expandable?", "cd", "open"],
          \ 'D' : ["delete"],
          \ 'H' : ["toggleHidden"],
          \ '<cr>' : [
            \    "expandable?",
            \    ["expanded?", "collapse", "expand"],
            \    "open"
            \ ],
            \ },
            \ })
  for [l:key, l:val] in items(g:coc_config_table)
    call coc#config(l:key, l:val)
  endfor
  " Input.
  let g:coc_snippet_next = "<tab>"
  let g:coc_snippet_prev = "<s-tab>"
  let g:_snippets_expand_jump = "\<C-R>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>"
  ino <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
        \: "\<C-G>u\<CR>\<C-R>=coc#on_enter()\<CR>"
  ino <silent><expr> <TAB>
        \ coc#pum#visible() ?
        \ coc#pum#next(1) : my#lib#get_context()['b'] =~ '\v^\s*(\+\|-\|*\|\d+\.)\s$' ?
        \ "\<C-\>\<C-O>>>" . repeat(g:_const_dir_r, &ts) : coc#expandableOrJumpable() ?
        \ g:_snippets_expand_jump :
        \ my#lib#get_context()['p'] =~ '\v[a-z\._\u4e00-\u9fa5]' ?
        \ coc#refresh() : "\<TAB>"
  ino <silent><expr> <S-TAB>
        \ coc#pum#visible() ?
        \ coc#pum#prev(1) : coc#jumpable() ?
        \ g:_snippets_expand_jump :
        \ "\<S-TAB>"
  smap <silent><expr> <TAB>
        \ coc#expandableOrJumpable() ?
        \ g:_snippets_expand_jump :
        \ "\<TAB>"
  smap <silent><expr> <S-TAB>
        \ coc#jumpable() ?
        \ g:_snippets_expand_jump :
        \ "\<S-TAB>"
  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> <leader>l[ <Plug>(coc-diagnostic-prev)
  nmap <silent> <leader>l] <Plug>(coc-diagnostic-next)
  " Goto code navigation.
  nmap <silent> <F12>      <Plug>(coc-definition)
  nmap <silent> <leader>lf <Plug>(coc-definition)
  nmap <silent> <leader>lt <Plug>(coc-type-definition)
  nmap <silent> <leader>li <Plug>(coc-implementation)
  nmap <silent> <leader>lr <Plug>(coc-references)
  " Use K to show documentation in preview window.
  nn <silent> K :call <SID>coc_show_doc()<CR>
  " Symbol renaming.
  nmap <leader>ln <Plug>(coc-rename)
  " Formatting selected code.
  nmap <leader>lm <Plug>(coc-format)
  xmap <leader>lm <Plug>(coc-format-selected)
  " Applying codeAction to the selected region.
  xmap <leader>la <Plug>(coc-codeaction-selected)
  nmap <leader>la <Plug>(coc-codeaction-selected)
  " Remap keys for applying codeAction to the current buffer.
  nmap <leader>lc <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>lq <Plug>(coc-fix-current)
  " Map function and class text objects
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)
  " Remap <C-F> and <C-B> for scroll float windows/popups.
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nn <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
    nn <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
    vn <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
    vn <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
    call my#util#new_keymap("i", "<C-F>", {fb -> coc#float#has_scroll() ? coc#float#scroll(1) : fb()})
    call my#util#new_keymap("i", "<C-B>", {fb -> coc#float#has_scroll() ? coc#float#scroll(0) : fb()})
  endif
  " Coc-explorer
  nn  <silent> <leader>op :CocCommand explorer<CR>
  nn  <silent> <M-e> :CocCommand explorer<CR>
  ino <silent> <M-e> <Esc>:CocCommand explorer<CR>
  tno <silent> <M-e> <C-\><C-N>:CocCommand explorer<CR>
  augroup my_coc_group
    autocmd!
    " Highlight the symbol and its references when holding the cursor.
    au CursorHold * silent call CocActionAsync('highlight')
    " Setup formatexpr specified filetype(s).
    au FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end
  " Add (Neo)Vim's native statusline support.
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
endfunction

function! my#config#crates() abort
  augroup CratesAttach
    autocmd!
    au BufRead Cargo.toml call <SID>crates_attach()
  augroup END
endfunction

function! my#config#gruvbox() abort
  let g:_my_theme_switchable = 1
  if has("nvim")
    call my#util#auto_hl('gruvbox', g:_my_hl, {-> {
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
          \ }})
  endif
  colorscheme gruvbox
endfunction

function! my#config#indentLine() abort
  let g:indentLine_char = '▏'
  let g:vim_json_conceal = 0
  let g:indentLine_fileTypeExclude = [
        \ 'coc-explorer',
        \ 'markdown',
        \ 'startify',
        \ 'vimwiki',
        \ 'vimwiki.markdown',
        \ 'vista',
        \ 'vista_markdown',
        \ ]
  let g:indentLine_bufTypeExclude = ['help', 'terminal']
endfunction

function! my#config#markdown_preview() abort
  let g:mkdp_auto_start = 0
  let g:mkdp_auto_close = 1
  let g:mkdp_preview_options = {
        \ 'mkit': {},
        \ 'katex': {},
        \ 'uml': {},
        \ 'maid': {},
        \ 'disable_sync_scroll': 0,
        \ 'sync_scroll_type': 'relative',
        \ 'hide_yaml_meta': 1,
        \ 'sequence_diagrams': {},
        \ 'flowchart_diagrams': {},
        \ 'content_editable': v:false,
        \ 'disable_filename': 0
        \ }
  let g:mkdp_filetypes = [
        \ 'markdown',
        \ 'vimwiki',
        \ 'vimwiki.markdown'
        \ ]
endfunction

function! my#config#nerdtree() abort
  let g:NERDTreeDirArrowExpandable  = '+'
  let g:NERDTreeDirArrowCollapsible = '-'
  let NERDTreeMinimalUI = 1
  let NERDTreeDirArrows = 1
  nn  <silent> <leader>op :NERDTreeToggle<CR>
  nn  <silent> <M-e> :NERDTreeFocus<CR>
  ino <silent> <M-e> <Esc>:NERDTreeFocus<CR>
  tno <silent> <M-e> <C-\><C-N>:NERDTreeFocus<CR>
endfunction

function! my#config#one() abort
  let g:one_allow_italics = 1
  let g:airline_theme = 'one'
  let g:_my_theme_switchable = 1
  function! s:set_one_term_color() abort
    if &bg ==# 'dark'
      let g:terminal_color_0  = "#abb2bf"
      let g:terminal_color_1  = "#e06c75"
      let g:terminal_color_2  = "#98c379"
      let g:terminal_color_3  = "#d19a66"
      let g:terminal_color_4  = "#61afef"
      let g:terminal_color_5  = "#c678dd"
      let g:terminal_color_6  = "#56b6c2"
      let g:terminal_color_7  = "#828997"
      let g:terminal_color_8  = "#282c34"
      let g:terminal_color_9  = "#e06c75"
      let g:terminal_color_10 = "#98c379"
      let g:terminal_color_11 = "#e5c07b"
      let g:terminal_color_12 = "#61afef"
      let g:terminal_color_13 = "#c678dd"
      let g:terminal_color_14 = "#56b6c2"
      let g:terminal_color_15 = "#3e4452"
    else
      let g:terminal_color_0  = "#494b53"
      let g:terminal_color_1  = "#e45649"
      let g:terminal_color_2  = "#50a14f"
      let g:terminal_color_3  = "#986801"
      let g:terminal_color_4  = "#4078f2"
      let g:terminal_color_5  = "#a626a4"
      let g:terminal_color_6  = "#0184bc"
      let g:terminal_color_7  = "#696c77"
      let g:terminal_color_8  = "#fafafa"
      let g:terminal_color_9  = "#e45649"
      let g:terminal_color_10 = "#50a14f"
      let g:terminal_color_11 = "#c18401"
      let g:terminal_color_12 = "#4078f2"
      let g:terminal_color_13 = "#a626a4"
      let g:terminal_color_14 = "#0184bc"
      let g:terminal_color_15 = "#d0d0d0"
    endif
    return {
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
  endfunction
  call my#util#auto_hl('one', g:_my_hl, function("s:set_one_term_color"))
  colorscheme one
endfunction

function! my#config#vim_airline() abort
  set showtabline=2
  if has("nvim-0.7") && g:_my_tui_global_statusline
    set laststatus=3
  endif
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#branch#enabled  = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline_symbols = {}
  let g:airline_symbols.branch = "\uE0A0"
  let g:airline_mode_map = {
        \ '__'    : '-',
        \ 'c'     : 'C',
        \ 'i'     : 'I',
        \ 'ic'    : 'I',
        \ 'ix'    : 'I',
        \ 'n'     : 'N',
        \ 'multi' : 'M',
        \ 'niI'   : 'Ĩ',
        \ 'no'    : 'N',
        \ 'R'     : 'R',
        \ 'Rv'    : 'R',
        \ 's'     : 's',
        \ 'S'     : 'S',
        \ ''    : 'S',
        \ 't'     : 'T',
        \ 'v'     : 'v',
        \ 'V'     : 'V',
        \ ''    : 'B',
        \ }
endfunction

function! my#config#vim_clap() abort
  let g:clap_popup_border = index(['single', 'double', 'rounded'],
        \ g:_my_tui_border) >= 0 ?
        \ g:_my_tui_border :
        \ 'nil'
  nn <silent> <leader>fb :Clap buffers<CR>
  nn <silent> <leader>ff :Clap files<CR>
  nn <silent> <leader>fg :Clap grep<CR>
endfunction

function! my#config#vim_floatterm() abort
  let l:floaterm_borderstyles = {
      \ 'none': '        ',
      \ 'single': '─│─│┌┐┘└',
      \ 'double': '═║═║╔╗╝╚',
      \ 'rounded': '─│─│╭╮╯╰',
      \ }
  let g:floaterm_borderchars = has_key(l:floaterm_borderstyles, g:_my_tui_border) ?
        \ l:floaterm_borderstyles[g:_my_tui_border] :
        \ l:floaterm_borderstyles.none
  nn <silent> <leader>gn <Cmd>FloatermNew lazygit<CR>
endfunction

function! my#config#vim_fugitive() abort
  nn <silent> <leader>gb :Git blame<CR>
  nn <silent> <leader>gd :Git diff<CR>
  nn <silent> <leader>gh :Git log<CR>
endfunction

function! my#config#vim_ipairs() abort
  let g:pairs_map_ret = 0
  let g:pairs_map_bak = 1
  let g:pairs_map_spc = 1
  let g:pairs_usr_extd = {
        \ "$"  : "$",
        \ "`"  : "`",
        \ "*"  : "*",
        \ "**" : "**",
        \ "***": "***",
        \ "<u>": "</u>"
        \ }
  let g:pairs_usr_extd_map = {
        \ "<M-P>" : "`",
        \ "<M-I>" : "*",
        \ "<M-B>" : "**",
        \ "<M-M>" : "***",
        \ "<M-U>" : "<u>"
        \ }
endfunction

function! my#config#vim_signify() abort
  let g:signify_sign_add = '+'
  let g:signify_sign_delete = '_'
  let g:signify_sign_delete_first_line = '‾'
  let g:signify_sign_change = '~'
  let g:signify_sign_show_count = 0
  let g:signify_sign_show_text  = 1
  nmap <silent> <leader>gj <plug>(signify-next-hunk)
  nmap <silent> <leader>gk <plug>(signify-prev-hunk)
  nmap <silent> <leader>gJ 9999<plug>(signify-next-hunk)
  nmap <silent> <leader>gK 9999<plug>(signify-prev-hunk)
endfunction

function! my#config#vim_table_mode() abort
  nn <silent> <leader>ta :TableAddFormula<CR>
  nn <silent> <leader>tf :TableModeRealign<CR>
  nn <silent> <leader>tc :TableEvalFormulaLine<CR>
endfunction

function! my#config#vimtex() abort
  let g:tex_flavor = 'latex'
  if has("win32")
    let g:vimtex_view_general_viewer = 'SumatraPDF'
    let g:vimtex_view_general_options
          \ = '-reuse-instance -forward-search @tex @line @pdf'
  elseif has("unix")
    let g:vimtex_view_general_viewer = 'zathura'
  endif
endfunction

function! my#config#vimwiki() abort
  let g:vimwiki_list = [{
        \ 'path' : expand(g:_my_path_cloud . '/Notes/'),
        \ 'path_html' : expand(g:_my_path_cloud . '/Notes/html/'),
        \ 'syntax' : 'markdown',
        \ 'ext' : '.markdown'
        \ }]
  let g:vimwiki_folding = 'syntax'
  let g:vimwiki_ext2syntax = { '.markdown' : 'markdown' }
endfunction

function! my#config#vista() abort
  let g:vista_default_executive = g:_my_use_coc ? "coc" : "vim_lsp"
  let g:vista_executive_for = {
        \ 'markdown': 'toc',
        \ 'vimwiki': 'markdown'
        \ }
  nn <silent> <leader>fa :Clap tags<CR>
  nn <silent> <leader>mv :Vista!!<CR>
endfunction

function! my#config#vim_startify() abort
  let g:startify_session_dir = s:session_dir
endfunction

function! my#config#vsession() abort
  let g:vsession_path = s:session_dir
  let g:vsession_save_last_on_leave = 0
  let g:vsession_ui = 'quickpick'
  function! s:save_session() closure
    if &filetype ==# 'startify' | return | end
    let l:file = getcwd()
    let l:file = substitute(l:file, '\v[\/]', '__', 'g')
    let l:file = substitute(l:file, ':', '++', 'g')
    let l:path = s:session_dir . '/' . l:file
    execute 'silent mksession!' l:path
  endfunction
  augroup vsession_config
    autocmd!
    autocmd VimLeave * call s:save_session()
  augroup END
endfunction
