local cmd = vim.api.nvim_create_user_command

cmd("Time", function (_)
    print(os.date("%Y-%m-%d %a %T"))
end, { desc = "Echo time(May be useful in full screen?)" })

cmd("Pdf", function (_)
    require("utility.util").sys_open(vim.fn.expand("%:p:r")..".pdf")
end, { desc = "Open pdf file, useful when finish the compilation of tex file" })

cmd("CodeRun", function (tbl)
    require("utility.comp").run_or_compile(tbl.args)
end, { nargs = "?", complete =
function ()
    local option_table = {
        c = { "build", "check" },
        cs = { "build", "clean", "test" },
        lisp = { "build" },
        lua = { "nojit" },
        rust = { "build", "check", "clean", "test" },
        tex = { "biber", "bibtex" },
    }
    if option_table[vim.bo.filetype] then
        return option_table[vim.bo.filetype]
    else
        return {}
    end
end, desc = "Run or compile" })

cmd("PushAll", function (tbl)
    local arg_list = vim.split(vim.trim(tbl.args), "%s+")
    arg_list = vim.tbl_filter(function (s) return s ~= "" end, arg_list)
    require("utility.util").git_push_all(arg_list)
end, { nargs = "?", desc = "Git push all" })

cmd("NvimUpgrade", function (tbl)
    local arg = tbl.args
    if arg == "" then arg = nil end
    require("utility.util").nvim_upgrade(arg)
end, {
nargs = "?",
complete = function () return { "stable", "nightly" } end,
desc = "Neovim upgrade"
})

cmd("SshConfig", function (_)
    require("utility.util").edit_file("$HOME/.ssh/config", false)
end, { desc = "Open ssh configuration" })
