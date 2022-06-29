set noloadplugins
call v:lua.require("internal")

nn <silent> <leader>bd <Cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<CR>
nn <silent> <leader>bn <Cmd>call VSCodeNotify("workbench.action.nextEditor")<CR>
nn <silent> <leader>bp <Cmd>call VSCodeNotify("workbench.action.previousEditor")<CR>
