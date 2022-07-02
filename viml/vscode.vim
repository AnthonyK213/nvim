set noloadplugins
call my#compat#vim_source("viml/internal/init")

function! s:n(lhs, rhs, args = "") abort
  let l:tbl = empty(a:args) ? ""
        \ : "," . (type(a:args) == v:t_string ? a:args : string(a:args))
  exe "nn <silent>" a:lhs '<Cmd>call VSCodeNotify("' . a:rhs . '"' . l:tbl . ')<CR>'
endfunction

" Buffer
call s:n("<leader>bd", "workbench.action.closeActiveEditor")
call s:n("<leader>bn", "workbench.action.nextEditor")
call s:n("<leader>bp", "workbench.action.previousEditor")
" Find
call s:n("<leader>ff", "workbench.action.quickOpen")
call s:n("<leader>fg", "workbench.view.search")
" Fold
call s:n("za", "editor.toggleFold")
call s:n("zc", "editor.fold")
call s:n("zo", "editor.unfold")
call s:n("zC", "editor.foldRecursively")
call s:n("zM", "editor.foldAll")
call s:n("zO", "editor.unfoldRecursively")
call s:n("zR", "editor.unfoldAll")
" Git
call s:n("<leader>gj", "workbench.action.editor.nextChange")
call s:n("<leader>gk", "workbench.action.editor.previousChange")
" Comment
call s:n("<leader>kc", "editor.action.addCommentLine")
call s:n("<leader>ku", "editor.action.removeCommentLine")
" Open
call s:n("<leader>op", "workbench.action.toggleSidebarVisibility")
call s:n("<leader>ot", "workbench.action.terminal.new")
" LSP
call s:n("K", "editor.action.showHover")
call s:n("<leader>lm", "editor.action.formatDocument")
