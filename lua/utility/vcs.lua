local M = {}
local lib = require('utility.lib')
local uv = vim.loop


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

    -- Spawn jobs.
    local outputs = {}

    local function on_read(err, data)
        if err then
            vim.notify("Error: "..err)
        elseif data then
            local vals = vim.split(data, "\n")
            for _, val in ipairs(vals) do
                if val ~= "" then
                    table.insert(outputs, val)
                end
            end
        end
    end

    local function git_push()
        local stdout = uv.new_pipe(false)
        local stderr = uv.new_pipe(false)
        local git_push_handle
        git_push_handle = uv.spawn('git', {
            args = { 'push', 'origin', b_arg, '--porcelain' },
            cwd = git_root,
            stdio = { nil, stdout, stderr },
        },
        vim.schedule_wrap(function ()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            print(table.concat(outputs, ' '):gsub('\t', ' '))
            git_push_handle:close()
        end))
        outputs = {}
        stdout:read_start(vim.schedule_wrap(on_read))
        stderr:read_start(vim.schedule_wrap(on_read))
    end

    local function git_commit()
        local git_commit_handle
        git_commit_handle = uv.spawn('git', {
            args = {'commit', '-m', m_arg},
            cwd = git_root,
        },
        vim.schedule_wrap(function ()
            print("Commit message: "..m_arg)
            git_commit_handle:close()
            git_push()
        end))
    end

    local git_add_handle
    git_add_handle = uv.spawn('git', {
        args = {'add', '*'},
        cwd = git_root,
    },
    vim.schedule_wrap(function ()
        git_add_handle:close()
        git_commit()
    end))
end


return M
