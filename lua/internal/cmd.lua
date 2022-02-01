local has_nightly = vim.fn.has('nvim-0.7') == 1

if has_nightly then
    local cmd = vim.api.nvim_add_user_command

    -- Echo time(May be useful in full screen?)
    cmd('Time', function (_) print(os.date("%Y-%m-%d %a %T")) end, {})
    -- Open pdf file, useful when finish the compilation of tex file.
    cmd('PDF', function (_)
        require("utility.util").sys_open(vim.fn.expand("%:p:r")..".pdf")
    end, {})
    -- Run or compile
    cmd('CodeRun', function (tbl)
        require("utility.comp").run_or_compile(tbl.args)
    end, { nargs = '?', complete = vim.fn['usr#misc#run_code_option'] })
    -- Git push all
    cmd('PushAll', function (tbl)
        local arg_list = vim.split(vim.trim(tbl.args), '%s+')
        arg_list = vim.tbl_filter(function (s) return s ~= '' end, arg_list)
        require("utility.vcs").git_push_all(arg_list)
    end, { nargs = '?' })
    -- Neovim upgrade.
    cmd('NvimUpgrade', function (tbl)
        local arg = tbl.args
        if arg == '' then arg = nil end
        require("utility.util").nvim_upgrade(tbl.args)
    end, { nargs = '?', complete = vim.fn['usr#misc#nvim_upgrade_option'] })
    -- Open ssh configuration.
    cmd('SshConfig', function (_)
        require("utility.util").edit_file("$HOME/.ssh/config", false)
    end, {})
else
    -- Echo time(May be useful in full screen?)
    vim.cmd('command! Time echo strftime("%Y-%m-%d %a %T")')
    -- Open pdf file, useful when finish the compilation of tex file.
    vim.cmd('command! PDF lua require("utility.util").sys_open(vim.fn.expand("%:p:r")..".pdf")')
    -- Run or compile
    vim.cmd('command! -nargs=* -complete=customlist,usr#misc#run_code_option CodeRun lua require("utility.comp").run_or_compile({<q-args>})')
    -- Git push all
    vim.cmd('command! -nargs=? PushAll lua require("utility.vcs").git_push_all(<q-args>)')
    -- Neovim upgrade.
    vim.cmd('command! -nargs=? -complete=customlist,usr#misc#nvim_upgrade_option NvimUpgrade lua require("utility.util").nvim_upgrade(<q-args>)')
    -- Open ssh configuration.
    vim.cmd('command! SshConfig lua require("utility.util").edit_file("$HOME/.ssh/config", false)')
end
