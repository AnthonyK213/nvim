local M = {}
local uv = vim.loop
local lib = require('utility.lib')
local Process = require('utility.proc')


---Invoke callback function for `on_event`.
---@param cb function Callback function.
---@param arg_tbl table Arguments table.
---@return function
local function on_event(cb, arg_tbl)
    return function (...)
        cb(arg_tbl, {...})
    end
end

---Run compiled binary.
---@param arg_tbl table Arguments table.
---@param cb_args table Callback arguments.
local function cb_run_bin(arg_tbl, cb_args)
    if cb_args[2] == 0 and cb_args[3] == 'exit' then
        vim.cmd(':vertical new')
        vim.fn.termopen({arg_tbl.fwd..'/'..arg_tbl.bin}, {
            cwd = arg_tbl.fwd
        })
    end
end

---@class Cmd
---@field cmd string|table|nil command.
---@field cwd string? working directory.
---@field cb function? call_back.
local Cmd = {}

Cmd.__index = Cmd

---Constructor.
---@param cmd string|table|nil
---@param cwd string?
---@param cb function?
---@return Cmd
function Cmd.new(cmd, cwd, cb)
    local o = {
        cmd = cmd,
        cwd = cwd,
        cb = cb
    }
    setmetatable(o, Cmd)
    return o
end

---Run command.
---@param tbl table
function Cmd:run(tbl)
    if type(self.cmd) == 'table' then
        lib.belowright_split(30)
        if self.cb then
            vim.fn.termopen(self.cmd, {
                cwd = self.cwd or tbl.fwd,
                on_exit = on_event(self.cb, tbl),
            })
        else
            vim.fn.termopen(self.cmd, {
                cwd = self.cwd or tbl.fwd,
            })
        end
    elseif type(self.cmd) == 'string' then
        vim.api.nvim_set_current_dir(tbl.fwd)
        vim.schedule(function ()
            vim.api.nvim_set_current_dir(tbl.bwd)
        end)
        vim.cmd(self.cmd)
    end
end

---Cmd constructor table for various filetypes.
local comp_table = {
    arduino = function (tbl)
        if not lib.executable('processing-java') then return end
        local output_dir
        local sketch_name = vim.fn.expand('%:p:h:t')
        if lib.has_windows() then
            output_dir = vim.env.TEMP..'\\nvim_processing\\'..sketch_name
        else
            output_dir = '/tmp/nvim_processing/'..sketch_name
        end
        if tbl.opt == '' then
            return Cmd.new {
                'processing-java',
                '--sketch='..tbl.fwd,
                '--output='..output_dir,
                '--force',
                '--run'
            }
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    c = function (tbl)
        local my_cc = _my_core_opt.dep.cc
        if not lib.executable(my_cc) then return end
        local cmd_tbl = {
            ['']  = { my_cc, tbl.fnm, '-o', tbl.bin },
            check = { my_cc, tbl.fnm, '-g', '-o', tbl.bin },
            build = { my_cc, tbl.fnm, '-O2', '-o', tbl.bin },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            if tbl.opt == '' then
                return Cmd.new(cmd, nil, cb_run_bin)
            else
                return Cmd.new(cmd)
            end
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    cpp = function (tbl)
        local cc_tbl = {
            gcc = 'g++',
            clang = 'clang++'
        }
        local cc = cc_tbl[_my_core_opt.dep.cc]
        if cc then
            if not lib.executable(cc) then return end
            if tbl.opt == '' then
                return Cmd.new({ cc, tbl.fnm, '-o', tbl.bin }, nil, cb_run_bin)
            else
                lib.notify_err('Invalid argument.')
            end
        end
    end,
    cs = function (tbl)
        if not lib.executable('dotnet') then return end
        local sln_root = lib.get_root("*.sln")
        if sln_root then
            if not lib.executable('MSBuild') then return end
            return Cmd.new { 'MSBuild.exe', sln_root }
        end
        local cmd_tbl = {
            ['']   = { 'dotnet', 'run' },
            build  = { 'dotnet', 'build', '--configuration', 'Release' },
            clean  = { 'dotnet', 'clean' },
            test   = { 'dotnet', 'test' },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return Cmd.new(cmd)
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    lisp = function (tbl)
        if not lib.executable('sbcl') then return end
        local cmd_tbl = {
            ['']  = {
                'sbcl', '--noinform', '--load',
                tbl.fnm, '--eval', '(exit)'
            },
            build = {
                'sbcl', '--noinform', '--load', tbl.fnm, '--eval',
                [[(sb-ext:save-lisp-and-die "]]..tbl.bin
                ..[[" :toplevel (quote main) :executable t)]],
            },
        }
        local cmd = cmd_tbl[tbl.opt]
        if cmd then
            return Cmd.new(cmd)
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    lua = function (tbl)
        if tbl.opt == '' then
            return Cmd.new('luafile %')
        elseif tbl.opt == 'nojit' then
            if not lib.executable('lua') then return end
            return Cmd.new { 'lua', tbl.fnm }
        elseif tbl.opt == 'test' then
            lib.feedkeys("<Plug>PlenaryTestFile", "n", false)
        else
            lib.notify_err('Invalid arguments.')
        end
    end,
    python = function (tbl)
        if not lib.executable('python') then return end
        if tbl.opt == '' then
            return Cmd.new { 'python', tbl.fnm }
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    ruby = function (tbl)
        if not lib.executable('ruby') then return end
        if tbl.opt == '' then
            return Cmd.new { 'ruby', tbl.fnm }
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    rust = function (tbl)
        if not lib.executable('cargo') then return end
        local cargo_root = lib.get_root('Cargo.toml')
        if cargo_root then
            local cmd_tbl = {
                ['']  = { 'cargo', 'run' },
                build = { 'cargo', 'build', '--release' },
                check = { 'cargo', 'check' },
                clean = { 'cargo', 'clean' },
                test  = { 'cargo', 'test' }
            }
            local cmd = cmd_tbl[tbl.opt]
            if cmd then
                return Cmd.new(cmd, cargo_root)
            else
                lib.notify_err('Invalid argument.')
            end
        end
        return Cmd.new({ 'rustc', tbl.fnm, '-o', tbl.bin }, nil, cb_run_bin)
    end,
    tex = function (tbl)
        local step = 1
        local name = vim.fn.expand('%:p:r')
        ---Create tex callback.
        ---@param label string
        ---@return function
        local tex_cb = function (label)
            ---Callback function.
            ---@param proc Process
            ---@param code integer
            ---@param _ any
            return function (proc, code, _)
                if code == 0 then
                    vim.notify(step.." -> "..label)
                    step = step + 1
                else
                    lib.belowright_split(15)
                    local chan = vim.api.nvim_open_term(0, {})
                    local data = table.concat(proc.standard_output)
                    vim.api.nvim_chan_send(chan, data)
                    lib.notify_err(label..": Compilation failed.")
                end
            end
        end
        local tex_done_cb = function (_, code, _)
            if code == 0 then
                vim.notify("Done.")
            end
        end
        local xelatex = Process.new('xelatex', {
            args = {
                '-synctex=1',
                '-interaction=nonstopmode',
                '-file-line-error',
                name..'.tex'
            }
        }, tex_cb("XeLaTeX"))
        ---@type table<string, Process>
        local bib_table = {
            biber = Process.new('biber', {
                args = { name..'.bcf' }
            }, tex_cb("BibTeX")),
            bibtex = Process.new('bibtex', {
                args = { name..'.aux' }
            }, tex_cb("BibTeX"))
        }
        if tbl.opt == '' then
            vim.notify("Start compilation.")
            local x1 = xelatex:clone()
            local x2 = xelatex:clone()
            x1:continue_with(x2)
            x2:append_cb(tex_done_cb)
            x1:start()
        elseif bib_table[tbl.opt] then
            vim.notify("Start compilation.")
            local x1 = xelatex:clone()
            local x2 = xelatex:clone()
            ---@type Process
            local b = bib_table[tbl.opt]:clone()
            local x3 = xelatex:clone()
            x1:continue_with(x2)
            x2:continue_with(b)
            b:continue_with(x3)
            x3:append_cb(tex_done_cb)
            x1:start()
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    vim = function (tbl)
        if tbl.opt == '' then
            return Cmd.new('source %')
        else
            lib.notify_err('Invalid argument.')
        end
    end,
}

---Run or compile the code.
---@param option string Option as string.
function M.run_or_compile(option)
    local tbl = {
        bin = '_'..vim.fn.expand('%:t:r')..(lib.has_windows() and '.exe' or ''),
        bwd = uv.cwd(),
        fnm = vim.fn.expand('%:t'),
        fwd = vim.fn.expand('%:p:h'),
        opt = option,
    }
    if comp_table[vim.bo.ft] then
        ---@type Cmd
        local cmd = comp_table[vim.bo.ft](tbl)
        if cmd then cmd:run(tbl) end
    else
        lib.notify_err("File type is not supported yet.")
    end
end


return M
