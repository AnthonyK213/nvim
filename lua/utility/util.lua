local M = {}
local lib = require('utility.lib')


---Use `pcall()` to catch error and display it.
---@param func function The function to test.
---@param args table Function arguments as a table.
local function on_err(func, args)
    local ok, err = pcall(func, unpack(args))
    if not ok then
        local msg = err:match('(E%d+:%s.+)$')
        lib.notify_err(msg and msg or "Error occured!")
    end
end

---Open terminal and launch shell.
function M.terminal()
    local exec
    local my_sh = _my_core_opt.dep.sh
    if type(my_sh) == "table" and #my_sh > 0 then
        exec = my_sh[1]
    elseif type(my_sh) == "string" then
        exec = my_sh
    else
        lib.notify_err("The shell is invalid, please check `opt.json`.")
        return false
    end

    if vim.fn.executable(exec) ~= 1 then
        lib.notify_err(exec.." is not a valid shell.")
        return false
    end

    lib.belowright_split(15)
    vim.api.nvim_win_set_option(0, 'number', false)
    vim.fn.termopen(vim.tbl_flatten({ my_sh }))
    return true
end

---Show documents.
function M.show_doc()
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        vim.lsp.buf.hover()
    elseif vim.tbl_contains({'vim', 'help'}, vim.bo.filetype) then
        local word, _, _ = lib.get_word()
        on_err(vim.cmd, { 'h '..word })
    end
end

---Open and edit text file in vim.
---@param file_path string File path.
---@param chdir boolean True to change cwd automatically.
function M.edit_file(file_path, chdir)
    local path = vim.fn.expand(vim.fn.fnameescape(file_path))
    if vim.fn.expand("%:t") == '' then
        vim.cmd('silent e '..path)
    else
        vim.cmd('silent tabnew '..path)
    end
    if chdir then
        vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))
    end
end

---Match path or URL under the cursor.
---@return string result|nil
function M.match_path_or_url_under_cursor()
    local _, url = lib.match_url(vim.fn.expand('<cWORD>'))
    if url then return url end

    local path = vim.fn.expand('<cfile>')
    if lib.path_exists(path, vim.fn.expand('%:p:h')) then
        return vim.fn.expand(path)
    end

    return nil
end

---Open path or URL with system default application.
---The environment variables should be expanded already.
---@param obj string Path or URL to open.
---@param use_local boolean|nil Use current file directory as cwd.
function M.sys_open(obj, use_local)
    local cwd = use_local and vim.fn.expand('%:p:h') or vim.loop.cwd()
    if type(obj) ~= "string"
        or not (lib.path_exists(obj, cwd) or lib.match_url(obj)) then
        lib.notify_err('Nothing found.')
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
        lib.notify_err('Invalid definition of `start`.')
        return
    end
    table.insert(args, obj)
    local handle
    handle = vim.loop.spawn(cmd, {
        args = args,
        cwd = cwd,
    }, vim.schedule_wrap(function ()
        handle:close()
    end))
end

---Show highlight information under the cursor.
function M.show_hl()
    local pos = vim.api.nvim_win_get_cursor(0)
    local lines = {}

    local show_matches = function(syntax_table)
        if #syntax_table == 0 then
            table.insert(lines, "* No highlight groups found")
        end
        for _, syntax in ipairs(syntax_table) do
            table.insert(lines, syntax:show())
        end
        table.insert(lines, "")
    end

    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
        table.insert(lines, "# Treesitter")
        show_matches(lib.get_treesitter_info(unpack(pos)))
    end

    if vim.b.current_syntax then
        table.insert(lines, "# Syntax")
        show_matches(lib.get_syntax_stack(unpack(pos)))
    end

    vim.lsp.util.open_floating_preview(
    lines, "markdown", { border = "single", pad_left = 4, pad_right = 4 })
end

---Upgrade neovim.
---Depends on `plenary.nvim`
---@param channel string|nil Upgrade channel, "stable" or "nightly".
function M.nvim_upgrade(channel)
    local proxy = _my_core_opt.dep.proxy

    local version = vim.api.nvim_exec('version', true)
    local tag, build = version:match('NVIM%sv([%d.]+)(.-)\n')
    local index = build:match('^%-dev%+(%d+)%-.+$')

    if not channel then
        channel = index and 'nightly' or 'stable'
    elseif channel ~= "stable" and channel ~= "nightly" then
        lib.notify_err('Invalid neovim release channel.')
        return
    end

    local Path = require('plenary.path')
    local archive
    if lib.has_windows() then
        archive = 'nvim-win64.zip'
    elseif vim.fn.has("unix") == 1 then
        archive = 'nvim-linux64.tar.gz'
    else
        return
    end

    local nvim_path = Path:new(vim.loop.exepath()):parent():parent()
    local bin_path = nvim_path:parent()
    local archive_path = bin_path:joinpath(archive)
    local backup_path = bin_path:joinpath('nvim_bak')
    local source = 'https://github.com/neovim/neovim/releases/download/'
    ..channel..'/'..archive

    if not backup_path:exists() then backup_path:mkdir() end

    if nvim_path:exists() then
        local time_stamp = os.date('%y%m%d%H%M%S_')
        local name = time_stamp..tag..(index and '_dev'..index or '')
        nvim_path:copy {
            recursive = true,
            override = true,
            destination = backup_path:joinpath(name).filename
        }
    end

    local use_proxy = type(proxy) == "string"

    local dl_handle, dl_exec, dl_args, ex_exec, ex_args
    if lib.has_windows() then
        local dl_cmd = 'Invoke-WebRequest'
        ..' -Uri '..source
        ..' -OutFile '..archive_path.filename
        if use_proxy then dl_cmd = dl_cmd..' -Proxy '..proxy end

        local rm_cmd = 'Remove-Item'
        ..' -Path '..nvim_path.filename
        ..' -Recurse'

        local ex_cmd = 'Expand-Archive'
        ..' -Path '..archive_path.filename
        ..' -DestinationPath '..bin_path.filename

        local rn_cmd = 'Rename-Item'
        ..' -Path '..bin_path:joinpath('nvim-win64').filename
        ..' -NewName '..nvim_path.filename

        local cl_cmd = 'Remove-Item'
        ..' -Path '..archive_path.filename

        local pwsh_cmd = table.concat({
            dl_cmd, rm_cmd, ex_cmd, rn_cmd, cl_cmd
        }, ';')

        vim.fn.jobstart('powershell.exe -c '..pwsh_cmd, { detach = true })
        vim.cmd('xa!')
        return
    elseif vim.fn.has("unix") == 1 then
        if not lib.executable('curl') then return end
        dl_exec = "curl"
        dl_args = use_proxy and {
            '-L', source,
            '-o', archive_path.filename,
            '-x', proxy
        } or {
            '-L', source,
            '-o', archive_path.filename,
        }
        ex_exec = "tar"
        ex_args = {
            '-xf', archive_path.filename,
            '-C', bin_path.filename
        }
    else
        lib.notify_err('Unsupported OS.')
        return
    end

    local extract = function ()
        local ex_handle
        ex_handle = vim.loop.spawn(ex_exec, {
            args = ex_args
        }, vim.schedule_wrap(function ()
            nvim_path:rm { recursive = true }
            bin_path:joinpath(archive:match('^(.-)%..+$')):rename {
                new_name = nvim_path.filename
            }
            archive_path:rm()
            print("Neovim has been upgrade to "..channel.." channel.")
            ex_handle:close()
        end))
    end

    print('Downloading...')
    dl_handle = vim.loop.spawn(dl_exec, {
        args = dl_args
    }, vim.schedule_wrap(function ()
        print('Package downloaded. Installing...')
        extract()
        dl_handle:close()
    end))
end


return M
