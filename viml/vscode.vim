set noloadplugins
call v:lua.require("internal")

nn <silent> <leader>bd <Cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<CR>
nn <silent> <leader>bn <Cmd>call VSCodeNotify("workbench.action.nextEditor")<CR>
nn <silent> <leader>bp <Cmd>call VSCodeNotify("workbench.action.previousEditor")<CR>
nn <silent> <leader>op <Cmd>call VSCodeNotify("workbench.view.explorer")<CR>
nn <silent> <leader>ot <Cmd>call VSCodeNotify("workbench.action.terminal.new")<CR>
nn <silent> <leader>kc <Cmd>call VSCodeNotify("editor.action.addCommentLine")<CR>
nn <silent> <leader>ku <Cmd>call VSCodeNotify("editor.action.removeCommentLine")<CR>
