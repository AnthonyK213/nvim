local M = {}
local lib = require("utility.lib")
local Process = require("utility.proc")
local Task = require("utility.task")

---Open terminal and launch shell.
function M.terminal()
    local exec
    local my_sh = _my_core_opt.dep.sh
    if type(my_sh) == "table" and #my_sh > 0 then
        exec = my_sh[1]
    elseif type(my_sh) == "string" then
        exec = my_sh
    else
        lib.notify_err("The shell is invalid, please check `nvimrc`.")
        return false
    end

    if vim.fn.executable(exec) ~= 1 then
        lib.notify_err(exec .. " is not a valid shell.")
        return false
    end

    lib.belowright_split(15)
    vim.api.nvim_win_set_option(0, "number", false)
    vim.fn.termopen(vim.tbl_flatten({ my_sh }))
    return true
end

---Open and edit text file in vim.
---@param file_path string File path.
---@param chdir boolean True to change cwd automatically.
function M.edit_file(file_path, chdir)
    local path = vim.fs.normalize(file_path)
    if vim.api.nvim_buf_get_name(0) == "" then
        vim.cmd.edit {
            args = { path },
            mods = {
                silent = true
            }
        }
    else
        vim.cmd.tabnew {
            args = { path },
            mods = {
                silent = true
            }
        }
    end
    if chdir then
        vim.api.nvim_set_current_dir(lib.get_buf_dir())
    end
end

---Match path or URL under the cursor.
---@return string? match_result
function M.match_path_or_url_under_cursor()
    local _, url = lib.match_url(vim.fn.expand("<cWORD>"))
    if url then return url end

    local path = vim.fn.expand("<cfile>")
    if lib.path_exists(path, lib.get_buf_dir()) then
        return vim.fs.normalize(path)
    end

    return nil
end

---Open path or URL with system default application.
---The environment variables should be expanded already.
---@param obj string? Path or URL to open.
---@param use_local? boolean Use current file directory as cwd.
function M.sys_open(obj, use_local)
    local cwd = use_local and lib.get_buf_dir() or vim.loop.cwd()
    if type(obj) ~= "string"
        or not (lib.path_exists(obj, cwd) or lib.match_url(obj)) then
        lib.notify_err("Nothing found.")
        return
    end
    local cmd
    local args = {}
    local my_start = _my_core_opt.dep.start
    if type(my_start) == "table" then
        cmd = my_start[1]
        if #my_start >= 2 then
            for i = 2, #my_start, 1 do
                table.insert(args, my_start[i])
            end
        end
    elseif type(my_start) == "string" then
        cmd = my_start
    else
        lib.notify_err("Invalid definition of `start`.")
        return
    end
    table.insert(args, obj)
    local handle
    handle = vim.loop.spawn(cmd, {
        args = args,
        cwd = cwd,
    }, vim.schedule_wrap(function()
        handle:close()
    end))
end

---Auto-update the color scheme highlight groups.
---@param scheme string Name of color scheme.
---@param hl_table table<string, table<string, string>> See onedark.nvim
---@param palette function Returns a color map (table).
function M.auto_hl(scheme, hl_table, palette)
    ---Get color value from a color table.
    ---@param color_map table<string, string>
    ---@param name string Name of the color.
    ---@return string? corlor_value
    local c = function(color_map, name)
        if not name then return nil end
        if vim.startswith(name, "#") then
            return name
        elseif vim.startswith(name, "$") then
            local key = name:sub(2)
            return color_map[key]
        else
            return nil
        end
    end

    local id = vim.api.nvim_create_augroup(scheme .. "Extd", {
        clear = true
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = id,
        pattern = scheme,
        callback = function()
            local map = palette()
            for k, v in pairs(hl_table) do
                ---Highlighting definition map.
                ---@type table<string, any>
                local val = {
                    fg = c(map, v["fg"]),
                    bg = c(map, v["bg"]),
                    sp = c(map, v["sp"]),
                }
                if v["fmt"] then
                    for _, attr in ipairs(vim.split(v["fmt"], ",", {
                        plain = false,
                        trimempty = true
                    })) do
                        val[vim.trim(attr)] = true
                    end
                end
                vim.api.nvim_set_hl(0, k, val)
            end
        end
    })
end

---Create new mapping with fallback.
---@param mode string Mode short-name.
---@param lhs string Left-hand-side of the mapping.
---@param new_rhs function A function passed with argument `fallback`.
---@param opts? table<string, boolean|integer> Optional parameters map.
function M.new_keymap(mode, lhs, new_rhs, opts)
    opts = opts or {}
    local kbd_table = opts.buffer
        and vim.api.nvim_buf_get_keymap(opts.buffer, mode)
        or vim.api.nvim_get_keymap(mode)

    local fallback

    for _, val in ipairs(kbd_table) do
        if val.lhs == lhs then
            if val.rhs then
                fallback = function()
                    lib.feedkeys(val.rhs, "n", true)
                end
            elseif val.callback then
                fallback = val.callback
            end
            break
        end
    end

    if fallback == nil then
        fallback = function()
            lib.feedkeys(lhs, "n", true)
        end
    end

    vim.keymap.set(mode, lhs, function() new_rhs(fallback) end, opts)
end

---Throw away your brain, just push it!
---@param arg_tbl table<string, string>
function M.git_push_all(arg_tbl)
    -- Check git status.
    if not lib.executable("git") then return end

    local git_root = lib.get_root("^.git$")
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

    -- `-m`: commit
    local m_arg = arg_tbl["-m"] or os.date("%y%m%d")
    -- `-b`: branch
    local b_arg = arg_tbl["-b"] or git_branch
    -- `-r`: remote
    local r_arg = arg_tbl["-r"] or "origin"

    local git_add = Process.new("git", {
        args = { "add", "*" },
        cwd = git_root,
    })

    local git_commit = Process.new("git", {
        args = { "commit", "-m", m_arg },
        cwd = git_root,
    }, function(proc, code, _)
        if code == 0 then
            vim.notify("Commit message: " .. m_arg)
        else
            lib.notify_err(table.concat(proc.standard_output))
        end
    end)

    local git_push = Process.new("git", {
        args = { "push", r_arg, b_arg, "--porcelain" },
        cwd = git_root,
    }, function(proc, code, _)
        if code == 0 then
            vim.notify(table.concat(proc.standard_output):gsub("[\t\n\r]", " "))
        else
            lib.notify_err(table.concat(proc.standard_output))
        end
    end)

    Process.queue_all { git_add, git_commit, git_push }
end

---Upgrade neovim.
---Depends on `plenary.nvim`
---@param channel? string Upgrade channel, "stable" or "nightly".
function M.nvim_upgrade(channel)
    local proxy = _my_core_opt.dep.proxy

    local version = vim.api.nvim_exec("version", true)
    local tag, build = version:match("NVIM%sv([%d.]+)(.-)\n")
    local index = build:match("^%-dev%+(%d+)%-.+$")

    if not channel then
        channel = index and "nightly" or "stable"
    elseif channel ~= "stable" and channel ~= "nightly" then
        lib.notify_err("Invalid neovim release channel.")
        return
    end

    local Path = require("plenary.path")
    local archive
    local os_type = lib.get_os_type()
    if os_type == lib.Os.Windows then
        archive = "nvim-win64.zip"
    elseif os_type == lib.Os.Linux then
        archive = "nvim-linux64.tar.gz"
    else
        return
    end

    local nvim_path = Path:new(vim.loop.exepath()):parent():parent()
    local bin_path = nvim_path:parent()
    local archive_path = bin_path:joinpath(archive)
    local backup_path = bin_path:joinpath("nvim_bak")
    local source = "https://github.com/neovim/neovim/releases/download/"
        .. channel .. "/" .. archive

    if not backup_path:exists() then backup_path:mkdir() end

    if nvim_path:exists() then
        local time_stamp = os.date("%y%m%d%H%M%S_")
        local name = time_stamp .. tag .. (index and "_dev" .. index or "")
        nvim_path:copy {
            recursive = true,
            override = true,
            destination = backup_path:joinpath(name).filename
        }
    end

    local use_proxy = type(proxy) == "string"

    local dl_exec, dl_args, ex_exec, ex_args
    if os_type == lib.Os.Windows then
        local dl_cmd = "Invoke-WebRequest"
            .. " -Uri " .. source
            .. " -OutFile " .. archive_path.filename
        if use_proxy then dl_cmd = dl_cmd .. " -Proxy " .. proxy end

        local rm_cmd = "Remove-Item"
            .. " -Path " .. nvim_path.filename
            .. " -Recurse"

        local ex_cmd = "Expand-Archive"
            .. " -Path " .. archive_path.filename
            .. " -DestinationPath " .. bin_path.filename

        local rn_cmd = "Rename-Item"
            .. " -Path " .. bin_path:joinpath("nvim-win64").filename
            .. " -NewName " .. nvim_path.filename

        local cl_cmd = "Remove-Item"
            .. " -Path " .. archive_path.filename

        local pwsh_cmd = table.concat({
            dl_cmd, rm_cmd, ex_cmd, rn_cmd, cl_cmd
        }, ";")

        vim.fn.jobstart("powershell.exe -c " .. pwsh_cmd, { detach = true })
        vim.cmd.quitall { bang = true }
        return
    elseif os_type == lib.Os.Linux then
        if not lib.executable("curl") then return end
        dl_exec = "curl"
        dl_args = use_proxy and {
            "-L", source,
            "-o", archive_path.filename,
            "-x", proxy
        } or {
            "-L", source,
            "-o", archive_path.filename,
        }
        ex_exec = "tar"
        ex_args = {
            "-xf", archive_path.filename,
            "-C", bin_path.filename
        }
    else
        lib.notify_err("Unsupported operating system.")
        return
    end

    local download = Process.new(dl_exec, { args = dl_args })
    local extract = Process.new(ex_exec, { args = ex_args })

    lib.async(function()
        vim.notify("Downloading...")
        if download:await() ~= 0 then
            lib.notify_err(table.concat(download.standard_output))
            return
        end
        vim.notify("Package downloaded. Installing...")
        if extract:await() ~= 0 then
            lib.notify_err(table.concat(extract.standard_output))
            return
        end
        nvim_path:rm { recursive = true }
        bin_path:joinpath(archive:match("^(.-)%..+$")):rename {
            new_name = nvim_path.filename
        }
        archive_path:rm()
        Task.delay(1000):await()
        vim.notify("Neovim has been upgraded to " .. channel .. " channel.")
    end)
end

---Build crates in `$config/rust/` directory.
function M.build_dylibs()
    local crates_dir = lib.path_append(vim.fn.stdpath("config"), "rust")
    local dylibs_dir = _my_core_opt.path.dylib
    local dylib_ext = lib.get_dylib_ext()
    local dylib_prefix = lib.has_windows() and "" or "lib"
    if not lib.path_exists(dylibs_dir) then
        if not vim.loop.fs_mkdir(dylibs_dir, 448) then
            lib.notify_err("Could not crate directory `dylib`.")
            return
        end
    end

    if not lib.executable("cargo") then return end

    for _name, _type in vim.fs.dir(crates_dir) do
        if _type == "directory" then
            local crate_dir = lib.path_append(crates_dir, _name)
            Process.new("cargo", {
                args = { "build", "--release" },
                cwd = crate_dir,
            }, function(_, code, _)
                if code == 0 then
                    local dylib_name = _name .. "." .. dylib_ext
                    vim.loop.fs_copyfile(lib.path_append(crate_dir,
                        "target/release/" .. dylib_prefix .. dylib_name),
                        lib.path_append(dylibs_dir, dylib_name),
                        vim.schedule_wrap(function(err, success)
                            if success then
                                print("Building `" .. _name .. "`: Succeed.")
                            else
                                print(err)
                            end
                        end))
                else
                    lib.notify_err("Building `" .. _name .. "`: Failed.")
                end
            end):start()
        end
    end
end

return M
