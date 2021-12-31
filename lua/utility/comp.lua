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

local function on_event(arg_tbl, cb)
    return function (...)
        cb(arg_tbl, {...})
    end
end

local function cb_run_bin(arg_tbl, cb_args)
    if cb_args[2] == 0 then
        vim.cmd(':vertical new')
        vim.fn.termopen({arg_tbl.name}, { cwd = arg_tbl.fcwd })
    end
end

local comp_c = function (tbl)
    if not exists_exec(pub.ccomp) then return nil, nil end

    local cmd_tbl = {
        ['']  = { pub.ccomp, tbl.file, '-o', tbl.name..tbl.oute },
        check = { pub.ccomp, tbl.file, '-g', '-o', tbl.name..tbl.oute },
        build = { pub.ccomp, tbl.file, '-O2', '-o', tbl.name..tbl.oute },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == '' then
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
        ['']  = { 'sbcl', '--noinform', '--load', tbl.file, '--eval', '(exit)' },
        build = {
            'sbcl', '--noinform', '--load', tbl.file, '--eval',
            [[(sb-ext:save-lisp-and-die "]]..tbl.name..tbl.oute
            ..[[" :toplevel (quote main) :executable t)]],
        },
    }
    local cmd = cmd_tbl[tbl.optn]
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
        return cb_run_bin, { cc_tbl[pub.ccomp], tbl.file, '-o', tbl.name..tbl.oute }
    else
        return false, nil
    end
end

local comp_csharp = function (tbl)
    if vim.fn.has("win32") ~= 1 then return end
    local sln_root = lib.get_root("*.sln")

    if sln_root then
        if not exists_exec('MSBuild') then return nil, nil end
        return nil, { 'MSBuild.exe', sln_root }
    end

    if not exists_exec('csc') then return nil, nil end

    local cmd_tbl = {
        ['']    = { 'csc', tbl.file },
        exe     = { 'csc', '/target:exe', tbl.file },
        winexe  = { 'csc', '/target:winexe', tbl.file },
        library = { 'csc', '/target:library', tbl.file },
        module  = { 'csc', '/target:module', tbl.file },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == '' then
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
    return nil, { 'python', tbl.file }
end

local comp_ruby = function (tbl)
    if not exists_exec('ruby') then return nil, nil end
    return nil, { 'ruby', tbl.file }
end

local comp_rust = function (tbl)
    if not exists_exec('rustc') then return nil, nil end
    local cmd_tbl = {
        ['']  = { 'cargo', 'run' },
        build = { 'cargo', 'build', '--release' },
        check = { 'cargo', 'check' },
        clean = { 'cargo', 'clean' },
        rustc = { 'rustc', tbl.file },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == 'rustc' then
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
    if tbl.optn == '' then
        latex_xelatex_2()
    elseif prog_table[tbl.optn] then
        latex_xelatex_bib(tbl.optn)
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
        --exec = vim.fn.has("win32") == 1 and '' or './',
        --exts = string.lower(vim.fn.expand('%:e')),
        --path = vim.fn.expand('%:p'),
        file = vim.fn.expand('%:t'),
        name = vim.fn.expand('%:r'),
        bcwd = uv.cwd(),
        fcwd = vim.fn.expand('%:p:h'),
        optn = option,
        oute = vim.fn.has("win32") == 1 and '.exe' or '',
    }

    if comp_table[vim.o.ft] then
        local term_cb, term_cmd = comp_table[vim.o.ft](tbl)
        if type(term_cmd) == 'table' then
            lib.belowright_split(30)
            if term_cb then
                vim.fn.termopen(term_cmd, {
                    cwd = tbl.fcwd,
                    on_exit = on_event(tbl, term_cb),
                })
            else
                vim.fn.termopen(term_cmd, {
                    cwd = tbl.fcwd,
                })
            end
        elseif type(term_cmd) == 'string' then
            vim.api.nvim_set_current_dir(tbl.fcwd)
            vim.cmd(term_cmd)
            vim.api.nvim_set_current_dir(tbl.bcwd)
        end
    else
        lib.notify_err("File type is not supported yet.")
    end
end


return M
