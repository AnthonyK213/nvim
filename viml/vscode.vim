set noloadplugins
call my#compat#vim_source("viml/internal/init")

nn <silent> <leader>bd <Cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<CR>
nn <silent> <leader>bn <Cmd>call VSCodeNotify("workbench.action.nextEditor")<CR>
nn <silent> <leader>bp <Cmd>call VSCodeNotify("workbench.action.previousEditor")<CR>
nn <silent> <leader>ff <Cmd>call VSCodeNotify("workbench.action.quickOpen")<CR>
nn <silent> <leader>fg <Cmd>call VSCodeNotify("workbench.view.search")<CR>
nn <silent> <leader>gj <Cmd>call VSCodeNotify("workbench.action.editor.nextChange")<CR>
nn <silent> <leader>gk <Cmd>call VSCodeNotify("workbench.action.editor.previousChange")<CR>
nn <silent> <leader>kc <Cmd>call VSCodeNotify("editor.action.addCommentLine")<CR>
nn <silent> <leader>ku <Cmd>call VSCodeNotify("editor.action.removeCommentLine")<CR>
nn <silent> <leader>op <Cmd>call VSCodeNotify("workbench.action.toggleSidebarVisibility")<CR>
nn <silent> <leader>ot <Cmd>call VSCodeNotify("workbench.action.terminal.new")<CR>
nn <silent> <leader>lm <Cmd>call VSCodeNotify("editor.action.formatDocument")<CR>
nn <silent> K <Cmd>call VSCodeNotify("editor.action.showHover")<CR>
