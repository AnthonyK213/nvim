set noloadplugins
call my#compat#require("internal")
set colorcolumn=
" Buffer
call my#compat#vsc_kbd("n", "<leader>bd", "workbench.action.closeActiveEditor")
call my#compat#vsc_kbd("n", "<leader>bn", "workbench.action.nextEditor")
call my#compat#vsc_kbd("n", "<leader>bp", "workbench.action.previousEditor")
" Find
call my#compat#vsc_kbd("n", "<leader>fa", "workbench.action.gotoSymbol")
call my#compat#vsc_kbd("n", "<leader>ff", "workbench.action.quickOpen")
call my#compat#vsc_kbd("n", "<leader>fg", "workbench.view.search")
" Fold
call my#compat#vsc_kbd("n", "za", "editor.toggleFold")
call my#compat#vsc_kbd("n", "zc", "editor.fold")
call my#compat#vsc_kbd("n", "zo", "editor.unfold")
call my#compat#vsc_kbd("n", "zC", "editor.foldRecursively")
call my#compat#vsc_kbd("n", "zM", "editor.foldAll")
call my#compat#vsc_kbd("n", "zO", "editor.unfoldRecursively")
call my#compat#vsc_kbd("n", "zR", "editor.unfoldAll")
" Git
call my#compat#vsc_kbd("n", "<leader>gj", "workbench.action.editor.nextChange")
call my#compat#vsc_kbd("n", "<leader>gk", "workbench.action.editor.previousChange")
call my#compat#vsc_kbd("n", "<leader>gn", "workbench.view.scm")
" Comment
call my#compat#vsc_kbd("n", "<leader>kc", "editor.action.addCommentLine")
call my#compat#vsc_kbd("n", "<leader>ku", "editor.action.removeCommentLine")
call my#compat#vsc_kbd("v", "<leader>kc", "editor.action.addCommentLine")
call my#compat#vsc_kbd("v", "<leader>ku", "editor.action.removeCommentLine")
" Open
call my#compat#vsc_kbd("n", "<leader>op", "workbench.action.toggleSidebarVisibility")
call my#compat#vsc_kbd("n", "<leader>ot", "workbench.action.terminal.new")
call my#compat#vsc_kbd("n", "<leader>ou", "editor.action.openLink")
" LSP
call my#compat#vsc_kbd("n", "K", "editor.action.showHover")
call my#compat#vsc_kbd("n", "<leader>la", "editor.action.quickFix")
call my#compat#vsc_kbd("n", "<leader>ld", "editor.action.goToDeclaration")
call my#compat#vsc_kbd("n", "<leader>lf", "editor.action.revealDefinition")
call my#compat#vsc_kbd("n", "<leader>li", "editor.action.goToImplementation")
call my#compat#vsc_kbd("n", "<leader>lm", "editor.action.formatDocument")
call my#compat#vsc_kbd("n", "<leader>ln", "editor.action.rename")
call my#compat#vsc_kbd("n", "<leader>lr", "editor.action.goToReferences")
