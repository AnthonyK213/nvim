local util = {}
local lib = require('utility/lib')


-- Variables
--- Local
---- OS
local util_def_start, util_def_shell, util_def_cc
if vim.fn.has("win32") == 1 then
    util_def_start = 'start'
    util_def_shell = lib.get_var(vim.g.default_shell, 'powershell.exe -nologo')
    util_def_cc    = lib.get_var(vim.g.default_c_compiler, 'gcc')
elseif vim.fn.has("unix") == 1 then
    util_def_start = 'xdg-open'
    util_def_shell = lib.get_var(vim.g.default_shell, 'bash')
    util_def_cc    = lib.get_var(vim.g.default_c_compiler, 'gcc')
elseif vim.fn.has("mac") == 1 then
    util_def_start = 'open'
    util_def_shell = lib.get_var(vim.g.default_shell, 'zsh')
    util_def_cc    = lib.get_var(vim.g.default_c_compiler, 'clang')
end
--- Global
---- Escape string for URL.
util.url_escape = {
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
function util.mouse_toggle()
    if (vim.o.mouse == 'a') then
        vim.o.mouse = ''
        print("Mouse disabled.")
    else
        vim.o.mouse = 'a'
        print("Mouse enabled.")
    end
end

--- Background toggle
function util.bg_toggle()
    if (vim.o.background == 'dark') then
        vim.o.background = 'light'
    else
        vim.o.background = 'dark'
    end
    if (vim.g.colors_name) then
        vim.fn.execute('colorscheme '..vim.g.colors_name)
    end
end

--- Open terminal and launch shell.
function util.terminal()
    lib.belowright_split(15)
    vim.fn.execute('terminal '..util_def_shell)
end

--- Open file with system default browser.
function util.open_file(file_path)
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
function util.hanzi_count(mode)
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
function util.search_web(mode, site)
    local search_obj
    if mode == 'n' then
        local del_list = {
            ".", ",", "'", "\"",
            ";", "*", "~", "`",
            "(", ")", "[", "]", "{", "}"
        }
        search_obj = lib.str_escape(lib.get_clean_cWORD(del_list), util.url_escape)
    elseif mode == 'v' then
        search_obj = lib.str_escape(lib.get_visual_selection(), util.url_escape)
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

--- Calculate the day of week from a date(yyyy-mm-dd).
function util.append_day_from_date()
    local str = vim.fn.expand("<cWORD>")
    if str:match('^$') then return end
    local str_date, m2, m3, m4 = str:match('^.*((%d%d%d%d)%-(%d%d)%-(%d%d)).*$')
    local int_a, int_m, int_d
    if (str_date) then
        int_a = tonumber(m2)
        int_m = tonumber(m3)
        int_d = tonumber(m4)
    else
        print("Not a valid date expression.")
        return
    end

    local day_of_week = lib.zeller(int_a, int_m, int_d)
    if (day_of_week) then
        local line = vim.fn.getline('.')
        local cursor_pos = vim.fn.col('.')
        local match_start = 0
        local match_cword
        while (true) do
            match_cword = vim.fn.matchstrpos(line, str, match_start)
            if (match_cword[2] <= cursor_pos and
                match_cword[3] >= cursor_pos) then
                break
            end
            match_start = match_cword[3]
        end
        local cword_stt = match_cword[2]
        local cword_end = vim.fn.matchstrpos(line, str_date, cword_stt)[3]
        vim.fn.setpos('.', {0, vim.fn.line('.'), cword_end})
        -- Why not?
        --vim.fn.nvim_feedkeys('a '..day_of_week, 'x', true)
        vim.fn.execute('normal! a '..day_of_week)
    else
        return
    end
end

--- Markdown number bullet
local function md_check_line(lnum)
    local lstr = vim.fn.getline(lnum)
    local start, indent = lstr:find('^%s*', 1, false)
    local detect = 0
    local bullet
    if (lstr:match('^%s*[%+%-%*]%s+.*$')) then
        detect = 1
        bullet = lstr:match('^%s*([%+%-%*])%s+.*$')
    elseif (lstr:match('^%s*%d+%.%s+.*$')) then
        detect = 2
        bullet = lstr:match('^%s*(%d+)%.%s+.*$')
    end
    return detect, lstr, bullet, indent
end

function util.md_insert_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = md_check_line('.')
    local l_det = 0
    local l_bul, l_ind

    if (c_det == 0) then
        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = md_check_line(b_num)
            if (b_ind < c_ind and b_det ~= 0) then
                l_det = b_det
                l_bul = b_bul
                l_ind = b_ind
                break
            end
            b_num = b_num - 1
        end
    else
        l_det = c_det
        l_bul = c_bul
        l_ind = c_ind
    end

    if (l_det == 0) then
        vim.fn.nvim_input('<C-O>o')
    else
        local f_num = c_num + 1
        local move_stp = 0
        local move_rec = {}
        while (f_num <= vim.fn.line('$')) do
            local f_det, f_str, f_bul, f_ind = md_check_line(f_num)
            if (f_det == l_det and f_ind == l_ind) then
                table.insert(move_rec, move_stp)
                if (l_det == 1) then
                    break
                elseif (l_det == 2 and f_det == 2) then
                    local f_new = f_str:gsub(tostring(f_bul), tostring(f_bul + 1), 1)
                    vim.fn.setline(f_num, f_new)
                end
            elseif (f_ind <= l_ind) then
                table.insert(move_rec, move_stp)
                break
            elseif (f_num == vim.fn.line('$')) then
                table.insert(move_rec, move_stp + 1)
                break
            end
            f_num = f_num + 1
            move_stp  = move_stp + 1
        end
        local count_d, l_bul_new
        if (#move_rec == 0) then
            count_d = 0
        else
            count_d = move_rec[1]
        end
        if (l_det == 2) then
            l_bul_new = tostring(l_bul + 1)..". "
        else
            l_bul_new = l_bul.." "
        end
        local feed_string = vim.fn.nvim_replace_termcodes(string.rep('<Down>', count_d)..
        '<C-O>o<C-O>i'..string.rep('<SPACE>', l_ind)..l_bul_new, true, false, true)
        vim.fn.nvim_feedkeys(feed_string, 'i', true)
    end
end

function util.md_sort_num_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = md_check_line('.')

    if (c_det == 2) then
        local b_num_list = { c_num }
        local f_num_list = {}

        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = md_check_line(b_num)
            if (b_det == 2) then
                if (b_ind == c_ind) then
                    table.insert(b_num_list, b_num)
                elseif (b_ind < c_ind) then
                    break
                end
            elseif (b_det ~= 2 and b_ind <= c_ind) then
                break
            end
            b_num = b_num - 1
        end

        local f_num = c_num + 1
        while (f_num <= vim.fn.line('$')) do
            local f_det, f_str, f_bul, f_ind = md_check_line(f_num)
            if (f_det == 2) then
                if (f_ind == c_ind) then
                    table.insert(f_num_list, f_num)
                elseif (f_ind < c_ind) then
                    break
                end
            elseif (f_det ~= 2 and f_ind <= c_ind) then
                break
            end
            f_num = f_num + 1
        end

        local b_len = #b_num_list
        for i, u in ipairs(b_num_list) do
            local lb_new = vim.fn.getline(u):gsub('%d+', tostring(b_len - i + 1), 1)
            vim.fn.setline(u, lb_new)
        end

        for j, v in ipairs(f_num_list) do
            local lf_new = vim.fn.getline(v):gsub('%d+', tostring(j + b_len), 1)
            vim.fn.setline(v, lf_new)
        end
    else
        print("Not in a line of any numbered lists.")
    end
end

--- LaTeX recipes
function util.latex_xelatex()
    local name = vim.fn.expand('%:r')
    vim.fn.execute('!xelatex -synctex=1 '..
    '-interaction=nonstopmode -file-line-error '..name..'.tex', '')
end

function util.latex_xelatex2()
    util.latex_xelatex()
    util.latex_xelatex()
end

function util.latex_biber()
    local name = vim.fn.expand('%:r')
    util.latex_xelatex()
    vim.fn.execute('!biber '..name..'.bcf', '')
    util.latex_xelatex2()
end

--- Run code
function util.run_or_compile(option)
    local size = 30
    local cmdh = 'term'
    local path = vim.fn.expand('%:p')
    local file = vim.fn.expand('%:t')
    local name = vim.fn.expand('%:r')
    local exts = string.lower(vim.fn.expand('%:e'))
    local exec, oute

    if vim.fn.has('win32') then
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
        elseif vim.fn.match(option, '\\v^b(exe|winexe|library|module)') then
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

--- Git push all
function util.git_push_all(...)
    local arg_list = {...}
    local git_root = lib.get_git_root()
    local git_branch

    if git_root then
        git_branch = lib.get_git_branch(git_root)
    else
        print("Not a git repository.")
        return
    end

    if git_branch then
        print("Root directory: "..git_root)
        print("Current branch: "..git_branch)
        vim.fn.execute('cd '..git_root)
    else
        print("Not a valid git repository.")
        return
    end

    if #arg_list % 2 == 0 then
        local m_idx = vim.fn.index(arg_list, "-m") + 1
        local b_idx = vim.fn.index(arg_list, "-b") + 1
        local m_arg, b_arg

        if m_idx > 0 and m_idx % 2 == 1 then
            m_arg = arg_list[m_idx + 1]
        elseif m_idx == 0 then
            m_arg = vim.fn.strftime('%y%m%d')
        else
            print("Invalid commit argument.")
            return
        end

        vim.fn.execute('!git add *')
        vim.fn.execute('!git commit -m '..m_arg)
        print('Commit message: '..m_arg)

        if b_idx > 0 and b_idx % 2 == 1 then
            b_arg = arg_list[b_idx + 1]
        elseif b_idx == 0 then
            b_arg = git_branch
        else
            print("Invalid branch argument.")
        end

        vim.fn.execute('!git push origin '..b_arg, false)
    else
        print("Wrong number of arguments is given.")
    end
end

--- Surround
local function sur_pair(pair_a)
    local pairs = { ["("]=")", ["["]="]", ["{"]="}", ["<"]=">", [" "]=" ", ["《"]="》", ["“"]="”" }
    if pair_a:match('^[%(%[{<%s《“]+$') then
        local str_list = vim.fn.split(pair_a, '\\zs')
        local new_list = {}
        for _,val in ipairs(str_list) do
            table.insert(new_list, 1, pairs[val])
        end
        return table.concat(new_list)
    elseif vim.fn.matchstr(pair_a, '\\v^(\\<\\w+\\>)+$') ~= '' then
        local str_list = vim.fn.split(pair_a, '<')
        local new_list = {}
        for _,val in ipairs(str_list) do
            table.insert(new_list, 1, val)
        end
        return '</'..table.concat(new_list, '</')
    else
        return pair_a
    end
end

function util.sur_add(mode, ...)
    local arg_list = {...}
    local pair_a
    if #arg_list > 0 then
        pair_a = arg_list[1]
    else
        pair_a = vim.fn.input("Surrounding add: ")
    end
    local pair_b = sur_pair(pair_a)

    if mode == 'n' then
        local origin = vim.fn.getpos('.')
        if (lib.get_context('f'):match('^.%s') or
            lib.get_context('f'):match('^.$')) then
            vim.fn.execute('normal! a'..pair_b)
        else
            vim.fn.execute('normal! Ea'..pair_b)
        end
        vim.fn.setpos('.', origin)
        if (lib.get_context('l'):match('%s') or
            lib.get_context('b'):match('^$')) then
            vim.fn.execute('normal! i'..pair_a)
        else
            vim.fn.execute('normal! Bi'..pair_a)
        end
    elseif mode == 'v' then
        local stt_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        vim.fn.setpos('.', end_pos)
        vim.fn.execute('normal! a'..pair_b)
        vim.fn.setpos('.', stt_pos)
        vim.fn.execute('normal! i'..pair_a)
    end
end

function util.sur_sub(...)
    local arg_list = {...}
    local back = lib.get_context('b')
    local fore = lib.get_context('f')
    local pair_a = vim.fn.input("Surrounding delete: ")
    local pair_b = sur_pair(pair_a)
    local pair_a_new
    if #arg_list > 0 then
        pair_a_new = arg_list[1]
    else
        pair_a_new = vim.fn.input("Change to: ")
    end
    local pair_b_new = sur_pair(pair_a_new)
    local search_back = '\\v.*\\zs'..vim.fn.escape(pair_a, ' ()[]{}<>.+*^$')
    local search_fore = '\\v'..vim.fn.escape(pair_b, ' ()[]{}<>.+*^$')

    if (vim.fn.matchstr(back, search_back) ~= '' and
        vim.fn.matchstr(fore, search_fore) ~= '') then
        local back_new = vim.fn.substitute(back, search_back, pair_a_new, '')
        local fore_new = vim.fn.substitute(fore, search_fore, pair_b_new, '')
        local line_new = back_new..fore_new
        vim.fn.setline(vim.fn.line('.'), line_new)
    end
end

--- Toggle math display.
function util.vim_markdown_math_toggle()
    vim.g.vim_markdown_math = 1 - vim.g.vim_markdown_math
    vim.fn.execute('syn off | syn on')
end

--- Show documents.
function util.show_doc()
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.fn.execute('h '..vim.fn.expand('<cword>'))
    else
        vim.lsp.buf.hover()
    end
end


return util
