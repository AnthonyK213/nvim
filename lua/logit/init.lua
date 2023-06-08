local M = {}
local lib = require("utility.lib")
local futures = require("futures")
local Process = futures.Process

---Get root and branch of the repository.
---@return string? root
---@return string? branch
local function repo()
    if not lib.executable("git") then return end
    local git_root = lib.get_root([[^\.git$]], "directory")
    if git_root then
        return git_root, lib.get_git_branch(git_root)
    else
        git_root = lib.get_root([[^\.git$]], "directory", vim.uv.cwd())
        if git_root then
            return git_root, lib.get_git_branch(git_root)
        else
            lib.notify_err("Not a git repository.")
            return
        end
    end
end

---Commit.
---@param message string
---@param root? string
---@return futures.Process?
function M.commit(message, root)
    root = root or repo()
    if not root then return end
    return Process.new("git", {
        args = { "commit", "-m", message },
        cwd = root,
    }):continue_with(function(proc, code, _)
        if code == 0 then
            vim.notify("Commit message: " .. message)
        else
            proc:notify_err()
        end
    end)
end

---Push.
---@param remote? string
---@param branch? string
---@param root? string
---@return futures.Process?
function M.push(remote, branch, root)
    root = root or repo()
    if not root then return end
    local args = { "push", "--porcelain" }
    if remote and branch then
        args = { "push", remote, branch, "--porcelain" }
    end
    local git_push = Process.new("git", {
        args = args,
        cwd = root,
    }):continue_with(function(proc, code, _)
        if code == 0 then
            vim.notify(table.concat(proc.stdout_buf):gsub("[\t\n\r]", " "))
        else
            proc:notify_err()
        end
    end)
    git_push.record = true
    return git_push
end

---Pull.
---@param remote? string
---@param branch? string
---@param root? string
---@return futures.Process?
function M.pull(remote, branch, root)
    root = root or repo()
    if not root then return end
    local args = { "pull" }
    if remote and branch then
        args = { "pull", remote, branch }
    end
    local git_pull = Process.new("git", {
        args = args,
        cwd = root,
    }):continue_with(function(proc, code, _)
        if code == 0 then
            vim.notify(table.concat(proc.stdout_buf))
        else
            proc:notify_err()
        end
    end)
    git_pull.record = true
    return git_pull
end

---Throw away your brain, just push it!
---@param arg_tbl table<string, string>
function M.push_all(arg_tbl)
    local root, branch = repo()
    if not branch then
        lib.notify_err("Not a valid git repository.")
        return
    end

    -- `-m`: commit
    local m_arg = arg_tbl["-m"] or os.date("%y%m%d")
    -- `-b`: branch
    local b_arg = arg_tbl["-b"] or branch
    -- `-r`: remote
    local r_arg = arg_tbl["-r"] or "origin"

    local git_add = Process.new("git", { args = { "add", "*" }, cwd = root })
    local git_commit = M.commit(m_arg, root)
    local git_push = M.push(r_arg, b_arg, root)

    futures.queue { git_add, git_commit, git_push }
end

return M
