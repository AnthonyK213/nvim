local M = {}
local lib = require('utility.lib')
local Process = require('utility.proc')


function M.git_push_all(arg_list)
    -- Check git status.
    if not lib.executable('git') then return end

    local git_root = lib.get_root(".git")
    local git_branch

    if git_root then
        git_branch = lib.get_git_branch(git_root)
    else
        lib.notify_err("Not a git repository.")
        return
    end

    if not git_branch then
        lib.notify_err("Not a valid git repository.")
        return
    end

    -- Get arguments.
    local m_arg, b_arg
    if #arg_list % 2 == 0 then
        local m_idx = vim.fn.index(arg_list, "-m") + 1
        local b_idx = vim.fn.index(arg_list, "-b") + 1

        if m_idx > 0 and m_idx % 2 == 1 then
            m_arg = arg_list[m_idx + 1]
        elseif m_idx == 0 then
            m_arg = os.date('%y%m%d')
        else
            lib.notify_err("Invalid commit argument.")
            return
        end

        if b_idx > 0 and b_idx % 2 == 1 then
            b_arg = arg_list[b_idx + 1]
        elseif b_idx == 0 then
            b_arg = git_branch
        else
            lib.notify_err("Invalid branch argument.")
            return
        end
    else
        lib.notify_err("Wrong number of arguments is given.")
        return
    end

    local git_add = Process.new("git", {
        args = {'add', '*'},
        cwd = git_root,
    })

    local git_commit = Process.new("git", {
        args = {'commit', '-m', m_arg},
        cwd = git_root,
    }, function (proc, code, _)
        if code == 0 then
            vim.notify("Commit message: "..m_arg)
        else
            lib.notify_err(table.concat(proc.standard_output))
        end
    end)

    local git_push = Process.new("git", {
        args = { 'push', 'origin', b_arg, '--porcelain' },
        cwd = git_root,
    }, function (proc, code, _)
        if code == 0 then
            vim.notify(table.concat(proc.standard_output):gsub("[\t\n\r]", " "))
        else
            lib.notify_err(table.concat(proc.standard_output))
        end
    end)

    git_add:continue_with(git_commit)
    git_commit:continue_with(git_push)

    git_add:start()
end


return M
