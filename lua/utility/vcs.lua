local M = {}
local lib = require('utility.lib')
local uv = vim.loop


local outputs = {}

local function on_collect(stream)
    local vals = vim.split(stream, "\n")
    for _, val in ipairs(vals) do
        if val ~= "" then
            table.insert(outputs, val)
        end
    end
end

local function on_read(err, data)
    if err then
        on_collect(err)
    elseif data then
        on_collect(data)
    end
end

local function git_push_async(b_arg)
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    Handle_push = uv.spawn('git', {
        args = {'push', 'origin', b_arg, '--porcelain'},
        stdio = {stdout, stderr}
    },
    vim.schedule_wrap(function()
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        print(table.concat(outputs, '  '))
        Handle_push:close()
    end))
    outputs = {}
    stdout:read_start(vim.schedule_wrap(on_read))
    stderr:read_start(vim.schedule_wrap(on_read))
end

local function git_commit_async(m_arg, b_arg)
    Handle_commit = uv.spawn('git', {
        args = {'commit', '-m', m_arg}
    },
    vim.schedule_wrap(function ()
        print("Commit message: "..m_arg)
        Handle_commit:close()
        git_push_async(b_arg)
    end))
end

local function git_add_async(m_arg, b_arg)
    Handle_add = uv.spawn('git', {
        args = {'add', '*'}
    },
    vim.schedule_wrap(function ()
        Handle_add:close()
        git_commit_async(m_arg, b_arg)
    end))
end

function M.git_push_all(...)
    local arg_list = {...}
    local git_root = lib.get_root(".git")
    local git_branch

    if git_root then
        git_branch = lib.get_git_branch(git_root)
    else
        lib.notify_err("Not a git repository.")
        return
    end

    if git_branch then
        vim.api.nvim_set_current_dir(git_root)
    else
        lib.notify_err("Not a valid git repository.")
        return
    end

    if #arg_list % 2 == 0 then
        local m_idx = vim.fn.index(arg_list, "-m") + 1
        local b_idx = vim.fn.index(arg_list, "-b") + 1
        local m_arg, b_arg

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

        git_add_async(m_arg, b_arg)
    else
        lib.notify_err("Wrong number of arguments is given.")
    end
end


return M
