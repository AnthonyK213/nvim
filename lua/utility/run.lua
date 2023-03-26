local uv = vim.loop
local lib = require("utility.lib")
local futures = require("futures")
local Process = futures.Process
local Task = futures.Task
local Terminal = futures.Terminal

local M = {}

---Determine if the terminal process has run and exited successfully.
---@param data integer
---@param event string
---@return boolean ok
local ok = function(data, event)
    return data == 0 and event == "exit"
end

---Wrap a termianl process to a recipe function.
---@param terminal futures.Terminal
---@return fun():boolean
local wrap = function(terminal)
    return function()
        local data, event = terminal:await()
        if not ok(data, event) then
            return false
        end
        return true
    end
end

---Run the compiled binary.
---@param tbl table
---@return boolean
local run_bin = function(tbl)
    local bin = lib.path_append(tbl.fwd, tbl.bin)
    local data, event = Terminal.new({ bin }, {
        cwd = tbl.fwd,
    }):continue_with(function()
        -- `jobstart()` cannot handle negative return code, so this callback
        -- for cleaning up may not be called if the process faulted...
        -- Perhaps I would try `futures.Terminal2` someday.
        if lib.path_exists(bin) then
            vim.loop.fs_unlink(bin)
        end
    end):await()
    if not ok(data, event) then return false end
    return true
end

---Check if `proc` has error, if so, print the `stderr`.
---@param proc futures.Process
---@param label? string
local has_error = function(proc, label)
    proc.record = true
    if proc:await() ~= 0 then
        if not lib.new_split("belowright") then return false end
        local chan = vim.api.nvim_open_term(0, {})
        local stderr = vim.tbl_isempty(proc.stderr_buf) and "" or
            [[

--------------------------------------------------------------------------------
                                 STANDARD ERROR
--------------------------------------------------------------------------------

]]
            .. table.concat(proc.stderr_buf)
        local stdout = vim.tbl_isempty(proc.stdout_buf) and "" or
            [[

--------------------------------------------------------------------------------
                                  STANDARD OUT
--------------------------------------------------------------------------------

]]
            .. table.concat(proc.stdout_buf)
        local data = (stderr .. stdout):gsub("\n", "\r\n")
        vim.api.nvim_chan_send(chan, data)
        local l = ""
        if label then l = label .. ": " end
        lib.notify_err(l .. "Compilation failed.")
        return true
    end
    return false
end

local comp_table = {
    arduino = function(tbl)
        if not lib.executable("processing-java") then return end
        local output_dir
        local sketch_name = vim.fs.basename(lib.get_buf_dir())
        if lib.has_windows() then
            output_dir = vim.env.TEMP .. "\\nvim_processing\\" .. sketch_name
        else
            output_dir = "/tmp/nvim_processing/" .. sketch_name
        end
        if tbl.opt == "" then
            return wrap(Terminal.new({
                "processing-java",
                "--sketch=" .. tbl.fwd,
                "--output=" .. output_dir,
                "--force",
                "--run"
            }, { cwd = tbl.fwd }))
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    c = function(tbl)
        local root = lib.get_root("^[Mm]akefile$", "file")
        if root then
            if not lib.executable("make") then return end
            return function()
                return wrap(Terminal.new(tbl.opt == ""
                    and { "make" } or { "make", tbl.opt }, {
                    cwd = root
                }))()
            end
        end
        local my_cc = _my_core_opt.dep.cc
        if not lib.executable(my_cc) then return end
        local cmd_tbl = {
            [""]  = { my_cc, tbl.fnm, "-o", tbl.bin },
            check = { my_cc, tbl.fnm, "-g", "-o", tbl.bin },
            build = { my_cc, tbl.fnm, "-O2", "-o", tbl.bin },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            if tbl.opt == "" then
                return function()
                    if has_error(Process.new(cmd[1], {
                        args = vim.list_slice(cmd, 2, #cmd),
                        cwd = tbl.fwd,
                    })) then
                        return false
                    end
                    return run_bin(tbl)
                end
            else
                return function()
                    return wrap(Terminal.new(cmd, { cwd = tbl.fwd }))()
                end
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    cpp = function(tbl)
        local cc_tbl = {
            gcc = "g++",
            clang = "clang++"
        }
        local cc = cc_tbl[_my_core_opt.dep.cc]
        if cc then
            if not lib.executable(cc) then return end
            if tbl.opt == "" then
                return function()
                    if has_error(Process.new(cc, {
                        args = { tbl.fnm, "-o", tbl.bin },
                        cwd = tbl.fwd,
                    })) then
                        return false
                    end
                    return run_bin(tbl)
                end
            else
                lib.notify_err("Invalid argument.")
            end
        end
    end,
    cs = function(tbl)
        if not lib.executable("dotnet") then return end
        local sln_root = lib.get_root([[\.sln$]], "file")
        if sln_root then
            if not lib.executable("MSBuild") then return end
            return function()
                return wrap(Terminal.new({ "MSBuild.exe", sln_root }, {
                    cwd = sln_root
                }))()
            end
        end
        local cmd_tbl = {
            [""]  = { "dotnet", "run" },
            build = { "dotnet", "build", "--configuration", "Release" },
            clean = { "dotnet", "clean" },
            test  = { "dotnet", "test" },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return function()
                return wrap(Terminal.new(cmd, { cwd = tbl.fwd }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    fsharp = function(tbl)
        if not lib.executable("dotnet") then return end
        local sln_root = lib.get_root([[\.sln$]], "file")
        if sln_root then
            if not lib.executable("MSBuild") then return end
            return function()
                return wrap(Terminal.new({ "MSBuild.exe", sln_root }, {
                    cwd = sln_root
                }))()
            end
        end
        local cmd_tbl = {
            [""]  = { "dotnet", "run" },
            build = { "dotnet", "build", "--configuration", "Release" },
            clean = { "dotnet", "clean" },
            test  = { "dotnet", "test" },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return function()
                return wrap(Terminal.new(cmd, { cwd = tbl.fwd }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    javascript = function(tbl)
        local js = "node"
        if not lib.executable(js) then return end
        if tbl.opt == "" then
            return function()
                return wrap(Terminal.new({ js, tbl.fnm }, {
                    cwd = tbl.fwd
                }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    lisp = function(tbl)
        if not lib.executable("sbcl") then return end
        local cmd_tbl = {
            [""]  = {
                "sbcl", "--noinform", "--load",
                tbl.fnm, "--eval", "(exit)"
            },
            build = {
                "sbcl", "--noinform", "--load", tbl.fnm, "--eval",
                [[(sb-ext:save-lisp-and-die "]] .. tbl.bin
                    .. [[" :toplevel (quote main) :executable t)]],
            },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return function()
                return wrap(Terminal.new(cmd, { cwd = tbl.fwd }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    lua = function(tbl)
        if tbl.opt == "" then
            return "luafile %"
        elseif tbl.opt == "lua" then
            if not lib.executable("lua") then return end
            return function()
                return wrap(Terminal.new({ "lua", tbl.fnm }, {
                    cwd = tbl.fwd
                }))()
            end
        elseif tbl.opt == "jit" then
            if not lib.executable("luajit") then return end
            return function()
                return wrap(Terminal.new({ "luajit", tbl.fnm }, {
                    cwd = tbl.fwd
                }))()
            end
        elseif tbl.opt == "test" then
            if lib.has_windows() then
                lib.notify_err("Test is not supported on Windows")
            else
                lib.feedkeys("<Plug>PlenaryTestFile", "n", false)
            end
        else
            lib.notify_err("Invalid arguments.")
        end
    end,
    make = function(tbl)
        if not lib.executable("make") then return end
        return function()
            return wrap(Terminal.new(tbl.opt == ""
                and { "make" } or { "make", tbl.opt }, {
                cwd = tbl.fwd
            }))()
        end
    end,
    python = function(tbl)
        local py = _my_core_opt.dep.py or "python"
        if not lib.executable(py) then return end
        if tbl.opt == "" then
            return function()
                return wrap(Terminal.new({ py, tbl.fnm }, {
                    cwd = tbl.fwd
                }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    ruby = function(tbl)
        if not lib.executable("ruby") then return end
        if tbl.opt == "" then
            return function()
                return wrap(Terminal.new({ "ruby", tbl.fnm }, {
                    cwd = tbl.fwd
                }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    rust = function(tbl)
        if not lib.executable("cargo") then return end
        local cargo_root = lib.get_root([[^Cargo\.toml$]], "file")
        if not cargo_root then
            return function()
                if has_error(Process.new("rustc", {
                    args = { tbl.fnm, "-o", tbl.bin },
                    cwd = tbl.fwd,
                })) then
                    return false
                end
                return run_bin(tbl)
            end
        end
        local cmd_tbl = {
            [""]  = { "cargo", "run" },
            build = { "cargo", "build", "--release" },
            check = { "cargo", "check" },
            clean = { "cargo", "clean" },
            test  = { "cargo", "test" }
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return function()
                return wrap(Terminal.new(cmd, { cwd = cargo_root }))()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    tex = function(tbl)
        local step = 1
        local name = (vim.b.vimtex and vim.b.vimtex.base)
            and vim.fn.fnamemodify(vim.b.vimtex.tex, ":r")
            or vim.fn.expand("%:p:r")
        local cwd = (vim.b.vimtex and vim.b.vimtex.root)
            and vim.b.vimtex.root
            or uv.cwd()
        ---Create tex callback.
        ---@param label string
        ---@return fun(proc: futures.Process, code: integer, signal: integer)
        local tex_cb = function(label)
            ---Callback function.
            ---@param code integer
            return function(_, code, _)
                if code == 0 then
                    vim.notify(string.format("Step %d: %s", step, label))
                    step = step + 1
                end
            end
        end
        ---Compilation done callback.
        ---@return boolean
        local tex_done = function()
            Task.delay(1000):await()
            vim.notify("Done")
            return true
        end
        local xelatex = Process.new("xelatex", {
            args = {
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                name .. ".tex"
            },
            cwd = cwd,
        }):continue_with(tex_cb("XeLaTeX"))
        ---@type table<string, futures.Process>
        local bib_table = {
            biber = Process.new("biber", {
                args = { name .. ".bcf" },
                cwd = cwd,
            }):continue_with(tex_cb("Biber")),
            bibtex = Process.new("bibtex", {
                args = { name .. ".aux" },
                cwd = cwd,
            }):continue_with(tex_cb("BibTeX"))
        }
        if tbl.opt == "" then
            local x1 = xelatex:clone()
            local x2 = xelatex:clone()
            return function()
                vim.notify("Start compilation.")
                if has_error(x1, "XeLaTeX-1") then return false end
                if has_error(x2, "XeLaTeX-2") then return false end
                return tex_done()
            end
        elseif bib_table[tbl.opt] then
            local x1 = xelatex:clone()
            local x2 = xelatex:clone()
            local b = bib_table[tbl.opt]:clone()
            local x3 = xelatex:clone()
            return function()
                vim.notify("Start compilation.")
                if has_error(x1, "XeLaTeX-1") then return false end
                if has_error(b, tbl.opt) then return false end
                if has_error(x2, "XeLaTeX-2") then return false end
                if has_error(x3, "XeLaTeX-3") then return false end
                return tex_done()
            end
        else
            lib.notify_err("Invalid argument.")
        end
    end,
    vim = function(tbl)
        if tbl.opt == "" then
            return "source %"
        else
            lib.notify_err("Invalid argument.")
        end
    end,
}

---Run task of .vscode/task.json.
---@return boolean
local function vscode_tasks()
    local root = lib.get_root(".vscode", "directory")
    if not root then return false end

    local path = lib.path_append(root, ".vscode/tasks.json")
    if not lib.path_exists(path) then return false end

    local _, content = lib.json_decode(path)
    if not content then return false end

    if not content.tasks
        or not vim.tbl_islist(content.tasks)
        or vim.tbl_isempty(content.tasks) then
        return false
    end

    futures.spawn(function()
        local task = futures.ui.select(content.tasks, {
            prompt = "Select a task: ",
            format_item = function(item)
                return item.label
            end
        })

        if not task then
            return
        end

        if vim.stricmp(task.type, "shell") == 0 then
            local cmd = task.command
            local args = task.args or {}
            if cmd and vim.tbl_islist(args) then
                table.insert(args, 1, cmd)
                print(task.label .. ": running...")
                Terminal.new(args, { cwd = root }):await()
                print(task.label .. ": exit.")
            end
        end
    end)

    return true
end

---Get the recipe running or compiling the code.
---@param option? string The option.
---@return function? recipe The recipe.
---@return boolean is_async True if it is an async block.
function M.get_recipe(option)
    option = option or ""
    local file_name = vim.api.nvim_buf_get_name(0)
    local tbl = {
        bin = "_" .. vim.fn.expand("%:t:r") .. (lib.has_windows() and ".exe" or ""),
        bwd = uv.cwd(),
        fnm = vim.fs.basename(file_name),
        fwd = vim.fs.dirname(file_name),
        opt = option,
    }
    if comp_table[vim.bo.filetype] then
        local terminal = comp_table[vim.bo.filetype](tbl)
        local proc_type = type(terminal)
        if proc_type == "function" then
            return terminal, true
        elseif proc_type == "string" then
            return function()
                vim.api.nvim_set_current_dir(tbl.fwd)
                vim.schedule(function()
                    vim.api.nvim_set_current_dir(tbl.bwd)
                end)
                vim.cmd(terminal)
            end, false
        end
    else
        lib.notify_err("File type is not supported yet.")
    end
    return nil, false
end

---Run or compile the code.
---@param option? string Option as string.
function M.code_run(option)
    if vscode_tasks() then return end
    local recipe, is_async = M.get_recipe(option)
    if recipe then
        if is_async then
            futures.spawn(recipe)
        else
            recipe()
        end
    end
end

return M
