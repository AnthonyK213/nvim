local M = {}
local uv = vim.loop
local lib = require('utility.lib')
local pub = require('utility.pub')


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
--   10. Lua (Neovim)
--   11. LaTeX


-- LaTeX recipes
local latex_step
local latex_name

local function latex_xelatex(cb, cb_cb, cb_cb_cb)
    Handle_latex = uv.spawn('xelatex', {
        args = {
            '-synctex=1',
            '-interaction=nonstopmode',
            '-file-line-error',
            latex_name..'.tex'
        }
    },
    vim.schedule_wrap(function()
        print(latex_step.." -> Xelatex")
        latex_step = latex_step + 1
        Handle_latex:close()
        if cb then cb(cb_cb, cb_cb_cb) end
    end))
end

local function latex_biber(cb, cb_cb)
    Handle_biber = uv.spawn('biber', {
        args = { latex_name..'.bcf' }
    },
    vim.schedule_wrap(function()
        print(latex_step.." -> Biber")
        latex_step = latex_step + 1
        Handle_biber:close()
        if cb then cb(cb_cb) end
    end))
end

local function latex_bibtex(cb, cb_cb)
    Handle_bibtex = uv.spawn('bibtex', {
        args = { latex_name..'.aux' }
    },
    vim.schedule_wrap(function()
        print(latex_step.." -> Bibtex")
        latex_step = latex_step + 1
        Handle_bibtex:close()
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

local function exists_exec(exe)
    if vim.fn.executable(exe) == 1 then return true end
    lib.notify_err('Executable '..exe..' is not found.')
    return false
end

local function on_event(cb, arg_tbl)
    return function (...)
        cb(arg_tbl, {...})
    end
end

local function cb_run_bin(arg_tbl, cb_args)
    if cb_args[2] == 0 and cb_args[3] == 'exit' then
        vim.cmd(':vertical new')
        vim.fn.termopen({arg_tbl.fwd..'/'..arg_tbl.bin}, {
            cwd = arg_tbl.fwd
        })
    end
end

local comp_c = function (tbl)
    if not exists_exec(pub.ccomp) then return nil, nil end

    local cmd_tbl = {
        ['']  = { pub.ccomp, tbl.fnm, '-o', tbl.bin },
        check = { pub.ccomp, tbl.fnm, '-g', '-o', tbl.bin },
        build = { pub.ccomp, tbl.fnm, '-O2', '-o', tbl.bin },
    }
    local cmd = cmd_tbl[tbl.opt]
    if cmd then
        if tbl.opt == '' then
            return cb_run_bin, cmd
        else
            return nil, cmd
        end
    else
        lib.notify_err('Invalid argument.')
        return nil, nil
    end
end

local comp_clisp = function (tbl)
    if not exists_exec('sbcl') then return nil, nil end

    local cmd_tbl = {
        ['']  = { 'sbcl', '--noinform', '--load', tbl.fnm, '--eval', '(exit)' },
        build = {
            'sbcl', '--noinform', '--load', tbl.fnm, '--eval',
            [[(sb-ext:save-lisp-and-die "]]..tbl.bin
            ..[[" :toplevel (quote main) :executable t)]],
        },
    }
    local cmd = cmd_tbl[tbl.opt]
    if cmd then
        return nil, cmd
    else
        lib.notify_err('Invalid argument.')
        return nil, nil
    end
end

local comp_cpp = function (tbl)
    local cc_tbl = {
        gcc = 'g++',
        clang = 'clang++'
    }

    local cc = cc_tbl[pub.ccomp]
    if cc then
        if not exists_exec(cc) then return nil, nil end
        return cb_run_bin, { cc_tbl[pub.ccomp], tbl.fnm, '-o', tbl.bin }
    else
        return false, nil
    end
end

local comp_csharp = function (tbl)
    if not lib.has_win32() then return end
    local sln_root = lib.get_root("*.sln")

    if sln_root then
        if not exists_exec('MSBuild') then return nil, nil end
        return nil, { 'MSBuild.exe', sln_root }
    end

    if not exists_exec('csc') then return nil, nil end

    local cmd_tbl = {
        ['']    = { 'csc', tbl.fnm },
        exe     = { 'csc', '/target:exe', tbl.fnm },
        winexe  = { 'csc', '/target:winexe', tbl.fnm },
        library = { 'csc', '/target:library', tbl.fnm },
        module  = { 'csc', '/target:module', tbl.fnm },
    }
    local cmd = cmd_tbl[tbl.opt]
    if cmd then
        if tbl.opt == '' then
            return cb_run_bin, cmd
        else
            return nil, cmd
        end
    else
        lib.notify_err('Invalid argument.')
        return nil, nil
    end
end

local comp_lua = function (_)
    return nil, 'luafile %'
end

local comp_processing = function (_)
    if vim.fn.exists(":RunProcessing") == 2 then
        return nil, "RunProcessing"
    end
    return nil, nil
end

local comp_python = function (tbl)
    if not exists_exec('python') then return nil, nil end
    return nil, { 'python', tbl.fnm }
end

local comp_ruby = function (tbl)
    if not exists_exec('ruby') then return nil, nil end
    return nil, { 'ruby', tbl.fnm }
end

local comp_rust = function (tbl)
    if not exists_exec('rustc') then return nil, nil end
    local cmd_tbl = {
        ['']  = { 'cargo', 'run' },
        build = { 'cargo', 'build', '--release' },
        check = { 'cargo', 'check' },
        clean = { 'cargo', 'clean' },
        rustc = { 'rustc', tbl.fnm, '-o', tbl.bin },
    }
    local cmd = cmd_tbl[tbl.opt]
    if cmd then
        if tbl.opt == 'rustc' then
            return cb_run_bin, cmd
        else
            return nil, cmd
        end
    else
        lib.notify_err('Invalid argument.')
        return nil, nil
    end
end

local comp_latex = function (tbl)
    latex_step = 1
    latex_name = vim.fn.expand('%:p:r')
    if tbl.opt == '' then
        latex_xelatex_2()
    elseif prog_table[tbl.opt] then
        latex_xelatex_bib(tbl.opt)
    else
        lib.notify_err('Invalid argument.')
    end
    return nil, nil
end

local comp_vim = function (_)
    return nil, 'source %'
end

local comp_table = {
    c = comp_c,
    cpp = comp_cpp,
    cs = comp_csharp,
    lisp = comp_clisp,
    lua = comp_lua,
    processing = comp_processing,
    python = comp_python,
    ruby = comp_ruby,
    rust = comp_rust,
    tex = comp_latex,
    vim = comp_vim
}

function M.run_or_compile(option)
    local tbl = {
        bin = '_'..vim.fn.expand('%:t:r')..(lib.has_win32() and '.exe' or ''),
        bwd = uv.cwd(),
        fnm = vim.fn.expand('%:t'),
        fwd = vim.fn.expand('%:p:h'),
        opt = option,
    }

    if comp_table[vim.o.ft] then
        local term_cb, term_cmd = comp_table[vim.o.ft](tbl)
        if type(term_cmd) == 'table' then
            lib.belowright_split(30)
            if term_cb then
                vim.fn.termopen(term_cmd, {
                    cwd = tbl.fwd,
                    on_exit = on_event(term_cb, tbl),
                })
            else
                vim.fn.termopen(term_cmd, {
                    cwd = tbl.fwd,
                })
            end
        elseif type(term_cmd) == 'string' then
            vim.api.nvim_set_current_dir(tbl.fwd)
            vim.cmd(term_cmd)
            vim.api.nvim_set_current_dir(tbl.bwd)
        end
    else
        lib.notify_err("File type is not supported yet.")
    end
end


return M
