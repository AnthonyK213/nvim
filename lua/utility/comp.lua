local M = {}
local uv = vim.loop
local lib = require('utility.lib')


-- Supported language list:
--   1. C
--   2. Common Lisp
--   3. C++
--   4. C#
--   5. Processing
--   6. Python
--   7. Ruby
--   8. Rust
--   9. Vim script
--   10. Lua
--   11. LaTeX


-- LaTeX recipes
local latex_step
local latex_name

local function latex_xelatex(cb, cb_cb, cb_cb_cb)
    local handle
    handle = uv.spawn('xelatex', {
        args = {
            '-synctex=1',
            '-interaction=nonstopmode',
            '-file-line-error',
            latex_name..'.tex'
        }
    },
    vim.schedule_wrap(function ()
        print(latex_step.." -> Xelatex")
        latex_step = latex_step + 1
        handle:close()
        if cb then cb(cb_cb, cb_cb_cb) end
    end))
end

local function latex_biber(cb, cb_cb)
    local handle
    handle = uv.spawn('biber', {
        args = { latex_name..'.bcf' }
    },
    vim.schedule_wrap(function ()
        print(latex_step.." -> Biber")
        latex_step = latex_step + 1
        handle:close()
        if cb then cb(cb_cb) end
    end))
end

local function latex_bibtex(cb, cb_cb)
    local handle
    handle = uv.spawn('bibtex', {
        args = { latex_name..'.aux' }
    },
    vim.schedule_wrap(function ()
        print(latex_step.." -> Bibtex")
        latex_step = latex_step + 1
        handle:close()
        if cb then cb(cb_cb) end
    end))
end

local prog_table = {
    biber = latex_biber,
    bibtex = latex_bibtex,
}

local function latex_xelatex_2()
    latex_xelatex(latex_xelatex)
end

local function latex_xelatex_bib(prog)
    local f = prog_table[prog]
    if f then
        latex_xelatex(f, latex_xelatex, latex_xelatex)
    end
end

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
        vim.cmd(self.cmd)
        vim.api.nvim_set_current_dir(tbl.bwd)
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
        return Cmd.new {
            'processing-java',
            '--sketch='..tbl.fwd,
            '--output='..output_dir,
            '--force',
            '--run'
        }
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
            return
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
            return Cmd.new({ cc, tbl.fnm, '-o', tbl.bin }, nil, cb_run_bin)
        else
            return
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
            return
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
            return
        end
    end,
    lua = function (tbl)
        if tbl.opt == '' then
            return Cmd.new('luafile %')
        elseif tbl.opt == 'nojit' then
            if not lib.executable('lua') then return end
            return Cmd.new { 'lua', tbl.fnm }
        else
            lib.notify_err('Invalid arguments.')
            return
        end
    end,
    python = function (tbl)
        if not lib.executable('python') then return end
        return Cmd.new { 'python', tbl.fnm }
    end,
    ruby = function (tbl)
        if not lib.executable('ruby') then return end
        return Cmd.new { 'ruby', tbl.fnm }
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
                return
            end
        end
        return Cmd.new({ 'rustc', tbl.fnm, '-o', tbl.bin }, nil, cb_run_bin)
    end,
    tex = function (tbl)
        latex_step = 1
        latex_name = vim.fn.expand('%:p:r')
        if tbl.opt == '' then
            latex_xelatex_2()
        elseif prog_table[tbl.opt] then
            latex_xelatex_bib(tbl.opt)
        else
            lib.notify_err('Invalid argument.')
        end
    end,
    vim = function (_) return Cmd.new('source %') end,
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
