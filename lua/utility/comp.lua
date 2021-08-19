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

local function latex_xelatex_bib(prog)
    local f = prog_table[prog]
    if f then
        latex_xelatex(f, latex_xelatex, latex_xelatex)
    end
end

-- Supported list:
--   1. C
--   2. C++
--   3. C#
--   4. Processing
--   5. Python
--   6. Ruby
--   7. Rust
--   8. Vim script
--   9. Lua (Neovim)
--   10. LaTeX
local comp_c = function (tbl)
    local cmd = {
        ['']  = pub.ccomp..' '..tbl.file..' -o '..tbl.name..tbl.oute..' && '..tbl.exec..tbl.name,
        check = pub.ccomp..' '..tbl.file..' -g -o '..tbl.name..tbl.oute,
        build = pub.ccomp..' '..tbl.file..' -O2 -o '..tbl.name..tbl.oute
    }
    if cmd[tbl.optn] then
        return true, cmd[tbl.optn]
    else
        print('Invalid argument.')
        return false, nil
    end
end

local comp_cpp = function (tbl)
    return true, 'g++ '..tbl.file..' -o '..tbl.name..tbl.oute..' && '..tbl.exec..tbl.name
end

local comp_csharp = function (tbl)
    if vim.fn.has("win32") ~= 1 then return end
    local cmd = {
        ['']    = 'csc '..tbl.file..' && '..tbl.exec..tbl.name,
        exe     = 'csc /target:exe '..tbl.file,
        winexe  = 'csc /target:winexe '..tbl.file,
        library = 'csc /target:library '..tbl.file,
        module  = 'csc /target:module '..tbl.file,
    }
    if cmd[tbl.optn] then
        return true, cmd[tbl.optn]
    else
        print('Invalid argument.')
        return false, nil
    end
end

local comp_lua = function (_)
    return false, 'luafile %'
end

local comp_processing = function (_)
    if vim.fn.exists(":RunProcessing") == 2 then
        return false, "RunProcessing"
    end
    return false, nil
end

local comp_python = function (tbl)
    return true, 'python '..tbl.file
end

local comp_ruby = function (tbl)
    return true, 'ruby '..tbl.file
end

local comp_rust = function (tbl)
    local cmd = {
        ['']  = 'cargo run',
        build = 'cargo build --release',
        check = 'cargo check',
        clean = 'cargo clean',
        rustc = 'rustc '..tbl.file..' && '..tbl.exec..tbl.name,
    }
    if cmd[tbl.optn] then
        return true, cmd[tbl.optn]
    else
        print('Invalid argument.')
        return false, nil
    end
end

local comp_latex = function (tbl)
    latex_step = 1
    latex_name = vim.fn.expand('%:p:r')
    if tbl.optn == '' then
        latex_xelatex()
    elseif prog_table[tbl.optn] then
        latex_xelatex_bib(tbl.optn)
    else
        print('Invalid argument.')
    end
    return false, nil
end

local comp_vim = function (_)
    return false, 'source %'
end

local comp_table = {
    c = comp_c,
    cpp = comp_cpp,
    cs = comp_csharp,
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
        file = vim.fn.shellescape(vim.fn.expand('%:t'), 1),
        name = vim.fn.shellescape(vim.fn.expand('%:r'), 1),
        optn = option,
        oute = vim.fn.has("win32") == 1 and '.exe' or '',
        path = vim.fn.shellescape(vim.fn.expand('%:p'), 1),
    }

    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))

    local term_use, term_cmd

    if comp_table[vim.o.ft] then
        term_use, term_cmd = comp_table[vim.o.ft](tbl)
    else
        print("File type not supported yet.")
        goto skip_exec
    end

    if not term_cmd then
        goto skip_exec
    elseif term_use then
        term_cmd = 'term '..term_cmd
        lib.belowright_split(30)
    end

    vim.cmd(term_cmd)

    ::skip_exec::
    vim.api.nvim_set_current_dir(gcwd)
end

function M.msbuild_vs_solution()
    local sln_root = lib.get_root("*.sln")

    if sln_root then
        local cmd = 'term MSBuild.exe '..vim.fn.shellescape(sln_root, 1)
        lib.belowright_split(30)
        vim.cmd(cmd)
    end
end


return M
