local M = {}
local uv = vim.loop
local lib = require('utility/lib')
local pub = require('utility/pub')


--- LaTeX recipes
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

--- Run code
---- Support list:
----   1. C
----   2. C++
----   3. C#
----   4. Python
----   5. Rust
----   6. Vim script
----   7. Lua (Neovim)
----   8. LaTeX
function M.run_or_compile(option)
    local gcwd = vim.fn.getcwd()
    local size = 30
    local cmdh = 'term'
    local path = vim.fn.expand('%:p')
    local file = vim.fn.expand('%:t')
    local name = vim.fn.expand('%:r')
    local exts = string.lower(vim.fn.expand('%:e'))
    local exec, oute

    if vim.fn.has('win32') == 1 then
        exec = ''
        oute = '.exe'
    else
        exec = './'
        oute = ''
    end

    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))

    local term_cmd
    local term_use = true
    if exts == 'py' then
        term_cmd = cmdh..' python '..file
    elseif exts == 'rb' then
        term_cmd = cmdh..' ruby '..file
    elseif exts == 'c' then
        if option == '' then
            term_cmd = cmdh..' '..pub.ccomp..' '..
            file..' -o '..name..oute..' && '..exec..name
        elseif option == 'check' then
            term_cmd = cmdh..' '..pub.ccomp..' '..
            file..' -g -o '..name..oute
        elseif option == 'build' then
            term_cmd = cmdh..' '..pub.ccomp..' '..
            file..' -O2 -o '..name..oute
        else
            print('Invalid argument.')
            goto skip_exec
        end
    elseif exts == 'cpp' then
        term_cmd = cmdh..' g++ '..file..' -o '..name..oute..' && '..exec..name
    elseif exts == 'cs' then
        if vim.fn.has("win32") ~= 1 then return end
        if option == '' then
            term_cmd = cmdh..' csc '..file..' && '..exec..name
        elseif vim.fn.match(option, '\\v^b(exe|winexe|library|module)') >= 0 then
            local target = option:match('^b(.+)$')
            term_cmd = cmdh..' csc /target:'..target..' '..file
        else
            print('Invalid argument.')
            goto skip_exec
        end
    elseif exts == 'rs' then
        if option == '' then
            term_cmd = cmdh..' cargo run'
        elseif option == 'rustc' then
            term_cmd = cmdh..' rustc '..file..' && '..exec..name
        elseif option == 'clean' then
            term_cmd = 'silent !cargo clean'
            term_use = false
        elseif option == 'check' then
            term_cmd = cmdh..' cargo check'
        elseif option == 'build' then
            term_cmd = cmdh..' cargo build --release'
        else
            print('Invalid argument.')
            goto skip_exec
        end
    elseif exts == 'vim' then
        term_cmd = 'source '..path
        term_use = false
    elseif exts == 'lua' then
        term_cmd = 'luafile '..path
        term_use = false
    elseif exts == 'tex' then
        latex_step = 1
        latex_name = vim.fn.expand('%:p:r')
        if option == '' then
            latex_xelatex()
            return
        elseif prog_table[option] then
            latex_xelatex_bib(option)
            return
        else
            print('Invalid argument.')
            goto skip_exec
        end
    elseif exts == 'pde' then
        if vim.fn.has(":RunProcessing") == 1 then
            vim.cmd("RunProcessing")
        end
        return
    else
        print('Unknown file type: .'..exts)
        goto skip_exec
    end

    if term_use then
        lib.belowright_split(size)
    end

    vim.cmd(term_cmd)

    ::skip_exec::
    vim.api.nvim_set_current_dir(gcwd)
end


return M
