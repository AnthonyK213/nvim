set noloadplugins
call v:lua.require("internal")

nn <silent> <leader>bd <Cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<CR>
nn <silent> <leader>bn <Cmd>call VSCodeNotify("workbench.action.nextEditor")<CR>
nn <silent> <leader>bp <Cmd>call VSCodeNotify("workbench.action.previousEditor")<CR>
nn <silent> <leader>gj <Cmd>VSCodeNotify("workbench.action.compareEditor.nextChange")<CR>
nn <silent> <leader>gk <Cmd>VSCodeNotify("workbench.action.compareEditor.previousChange")<CR>
nn <silent> <leader>kc <Cmd>call VSCodeNotify("editor.action.addCommentLine")<CR>
nn <silent> <leader>ku <Cmd>call VSCodeNotify("editor.action.removeCommentLine")<CR>
nn <silent> <leader>op <Cmd>call VSCodeNotify("workbench.action.toggleSidebarVisibility")<CR>
nn <silent> <leader>ot <Cmd>call VSCodeNotify("workbench.action.terminal.new")<CR>
