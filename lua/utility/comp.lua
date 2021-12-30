local M = {}
local uv = vim.loop
local lib = require('utility/lib')
local pub = require('utility/pub')


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

-- Supported list:
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
local comp_c = function (tbl)
    local cmd_tbl = {
        -- TODO: exec
        ['']  = { pub.ccomp, tbl.file, '-o', tbl.name..tbl.oute },
        check = { pub.ccomp, tbl.file, '-g', '-o', tbl.name..tbl.oute },
        build = { pub.ccomp, tbl.file, '-O2', '-o', tbl.name..tbl.oute },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == '' then
            return function ()
                return nil
            end, cmd
        else
            return nil, cmd
        end
    else
        print('Invalid argument.')
        return nil, nil
    end
end

local comp_clisp = function (tbl)
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
        print('Invalid argument.')
        return nil, nil
    end
end

local comp_cpp = function (tbl)
    local cc = {
        gcc = 'g++',
        clang = 'clang++'
    }
    if cc[pub.ccomp] then
        -- TODO: exec
        return function ()
            return nil
        end, { cc[pub.ccomp], tbl.file, '-o', tbl.name..tbl.oute }
    else
        return false, nil
    end
end

local comp_csharp = function (tbl)
    if vim.fn.has("win32") ~= 1 then return end
    local cmd_tbl = {
        -- TODO: exec
        ['']    = { 'csc', tbl.file },
        exe     = { 'csc', '/target:exe', tbl.file },
        winexe  = { 'csc', '/target:winexe', tbl.file },
        library = { 'csc', '/target:library', tbl.file },
        module  = { 'csc', '/target:module', tbl.file },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == '' then
            return function ()
                return nil
            end, cmd
        else
            return nil, cmd
        end
    else
        print('Invalid argument.')
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
    return nil, { 'python', tbl.file }
end

local comp_ruby = function (tbl)
    return nil, { 'ruby', tbl.file }
end

local comp_rust = function (tbl)
    local cmd_tbl = {
        ['']  = { 'cargo', 'run' },
        build = { 'cargo', 'build', '--release' },
        check = { 'cargo', 'check' },
        clean = { 'cargo', 'clean' },
        -- TODO: exec
        rustc = { 'rustc', tbl.file },
    }
    local cmd = cmd_tbl[tbl.optn]
    if cmd then
        if tbl.optn == 'rustc' then
            return function ()
                return nil
            end, cmd
        else
            return nil, cmd
        end
    else
        print('Invalid argument.')
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
        print('Invalid argument.')
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
    local gcwd = vim.fn.getcwd()
    local tbl = {
        exec = vim.fn.has("win32") == 1 and '' or './',
        exts = string.lower(vim.fn.expand('%:e')),
        file = vim.fn.expand('%:t'),
        name = vim.fn.expand('%:r'),
        path = vim.fn.expand('%:p'),
        optn = option,
        oute = vim.fn.has("win32") == 1 and '.exe' or '',
    }

    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))

    local term_cb, term_cmd

    if comp_table[vim.o.ft] then
        term_cb, term_cmd = comp_table[vim.o.ft](tbl)
    else
        print("File type has not been supported yet.")
        goto skip_exec
    end

    if term_cmd then
        if type(term_cmd) == 'table' then
            lib.belowright_split(30)
            if term_cb then
                vim.fn.termopen(term_cmd, { on_exit = function ()
                    lib.belowright_split(30)
                    vim.fn.termopen({tbl.exec..tbl.name})
                end })
            else
                vim.fn.termopen(term_cmd)
            end
        else
            vim.cmd(term_cmd)
        end
    end

    ::skip_exec::
    vim.api.nvim_set_current_dir(gcwd)
end

function M.build_or_make()
    local sln_root = lib.get_root("*.sln")

    if sln_root then
        local cmd = 'term MSBuild.exe '..vim.fn.shellescape(sln_root, 1)
        lib.belowright_split(30)
        vim.cmd(cmd)
    end
end


return M
