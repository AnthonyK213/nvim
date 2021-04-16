local M = {}
local uv = vim.loop
local lib = require('utility/lib')
local core_opt = require('core/opt')


-- Variables
--- Local
---- OS
local util_def_start, util_def_shell, util_def_cc
if vim.fn.has("win32") == 1 then
    util_def_start = 'start'
    util_def_shell = lib.get_var(core_opt.sh, 'powershell.exe -nologo')
    util_def_cc    = lib.get_var(core_opt.cc, 'gcc')
elseif vim.fn.has("unix") == 1 then
    util_def_start = 'xdg-open'
    util_def_shell = lib.get_var(core_opt.sh, 'bash')
    util_def_cc    = lib.get_var(core_opt.cc, 'gcc')
elseif vim.fn.has("mac") == 1 then
    util_def_start = 'open'
    util_def_shell = lib.get_var(core_opt.sh, 'zsh')
    util_def_cc    = lib.get_var(core_opt.cc, 'clang')
end
---- Escape string for URL.
local url_escape = {
    [" "]  = "\\%20",
    ["!"]  = "\\%21",
    ['"']  = "\\%22",
    ["#"]  = "\\%23",
    ["$"]  = "\\%24",
    ["%"]  = "\\%25",
    ["&"]  = "\\%26",
    ["'"]  = "\\%27",
    ["("]  = "\\%28",
    [")"]  = "\\%29",
    ["*"]  = "\\%2A",
    ["+"]  = "\\%2B",
    [","]  = "\\%2C",
    ["/"]  = "\\%2F",
    [":"]  = "\\%3A",
    [";"]  = "\\%3B",
    ["<"]  = "\\%3C",
    ["="]  = "\\%3D",
    [">"]  = "\\%3E",
    ["?"]  = "\\%3F",
    ["@"]  = "\\%40",
    ["\\"] = "\\%5C",
    ["|"]  = "\\%7C",
    ["\n"] = "\\%20",
    ["\r"] = "\\%20",
    ["\t"] = "\\%20"
}


-- Functions
--- Mouse toggle
function M.mouse_toggle()
    if (vim.o.mouse == 'a') then
        vim.o.mouse = ''
        print("Mouse disabled.")
    else
        vim.o.mouse = 'a'
        print("Mouse enabled.")
    end
end

--- Background toggle
function M.bg_toggle()
    vim.o.bg = vim.o.bg == 'dark' and 'light' or 'dark'
end

--- Open terminal and launch shell.
function M.terminal()
    lib.belowright_split(15)
    vim.fn.execute('terminal '..util_def_shell)
    vim.cmd('setl nonu')
end

--- Show documents.
function M.show_doc()
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.fn.execute('h '..vim.fn.expand('<cword>'))
    else
        vim.lsp.buf.hover()
    end
end

--- Open file with system default browser.
function M.open_file(file_path)
    if vim.fn.glob(file_path) == '' then return end
    local file_path_esc = "\""..vim.fn.escape(file_path, '%#').."\""
    local cmd
    if vim.fn.has("win32") == 1 then
        cmd = util_def_start..' ""'
    else
        cmd = util_def_start
    end
    vim.fn.execute('!'..cmd..' '..file_path_esc)
end

--- Hanzi count.
function M.hanzi_count(mode)
    local content
    if (mode == "n") then
        content = vim.fn.getline(1, '$')
    elseif (mode == "v") then
        content = vim.fn.split(lib.get_visual_selection(), "\n")
    else
        return
    end

    local h_count = 0
    for _,line in ipairs(content) do
        for _,char in ipairs(vim.fn.split(line, "\\zs")) do
            local code = vim.fn.char2nr(char)
            if code >= 0x4E00 and code <= 0x9FA5 then
                h_count = h_count + 1
            end
        end
    end

    if h_count == 0 then
        print("No Chinese characters found.")
    else
        print("The number of Chinese characters is "..tostring(h_count)..'.')
    end
end

--- Search web
function M.search_web(mode, site)
    local search_obj
    if mode == 'n' then
        local del_list = {
            ".", ",", "'", "\"",
            ";", "*", "~", "`",
            "(", ")", "[", "]", "{", "}"
        }
        search_obj = lib.str_escape(lib.get_clean_cWORD(del_list), url_escape)
    elseif mode == 'v' then
        search_obj = lib.str_escape(lib.get_visual_selection(), url_escape)
    end

    local url_raw = site..search_obj
    local url_arg
    if vim.fn.has('win32') == 1 then
        url_arg = url_raw
    else
        url_arg = "\""..url_raw.."\""
    end
    vim.fn.execute('!'..util_def_start..' '..url_arg)
end

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

    local term_cmd
    local term_use = true
    if exts == 'py' then
        term_cmd = cmdh..' python '..file
    elseif exts == 'rb' then
        term_cmd = cmdh..' ruby '..file
    elseif exts == 'c' then
        if option == '' then
            term_cmd = cmdh..' '..util_def_cc..' '..
            file..' -o '..name..oute..' && '..exec..name
        elseif option == 'check' then
            term_cmd = cmdh..' '..util_def_cc..' '..
            file..' -g -o '..name..oute
        elseif option == 'build' then
            term_cmd = cmdh..' '..util_def_cc..' '..
            file..' -O2 -o '..name..oute
        else
            print('Invalid argument.')
            return
        end
    elseif exts == 'cpp' then
        term_cmd = cmdh..' g++ '..file
    elseif exts == 'cs' then
        if vim.fn.has("win32") ~= 1 then return end
        if option == '' then
            term_cmd = cmdh..' csc '..file..' && '..exec..name
        elseif vim.fn.match(option, '\\v^b(exe|winexe|library|module)') >= 0 then
            local target = option:match('^b(.+)$')
            term_cmd = cmdh..' csc /target:'..target..' '..file
        else
            print('Invalid argument.')
            return
        end
    elseif exts == 'rs' then
        if option == '' then
            term_cmd = cmdh..' cargo run'
        elseif option == 'rustc' then
            term_cmd = cmdh..' rustc '..file..
            ' && '..exec..name
        elseif option == 'clean' then
            term_cmd = '!cargo clean'
            term_use = false
        elseif option == 'check' then
            term_cmd = cmdh..' cargo check'
        elseif option == 'build' then
            term_cmd = cmdh..' cargo build --release'
        else
            print('Invalid argument.')
            return
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
            return
        end
    else
        print('Unknown file type: .'..exts)
        return
    end

    if term_use then
        lib.belowright_split(size)
        vim.fn.execute(term_cmd)
    else
        vim.cmd(term_cmd)
    end
end

function M.nvim_nightly_upgrade(...)
    local arg_list = {...}
    local proxy_args

    if #arg_list == 0 then
        proxy_args = ""
    else
        proxy_args = arg_list[1]
    end

    local script_name = "nvim_nightly_upgrade"
    if vim.fn.has("win32") == 1 then
        local script_path = vim.fn.expand("$localappdata")..'/nvim/shell/'..
        script_name.."_win.ps1 -proxy "..proxy_args
        lib.belowright_split(30)
        vim.fn.execute("term powershell "..script_path)
    elseif vim.fn.has("unix") == 1 then
        local script_path = vim.fn.expand("$HOME/.config")..'/nvim/shell/'..
        script_name.."_linux.sh "..proxy_args
        lib.belowright_split(30)
        vim.fn.execute("term bash "..script_path)
    end
end


return M
