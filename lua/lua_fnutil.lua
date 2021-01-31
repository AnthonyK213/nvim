init_source('fnutil')


-- Variables
--- OS
local util_def_start, util_def_shell, util_def_cc
if vim.fn.has("win32") == 1 then
    util_def_start = 'start'
    util_def_shell = lib_lua_get(vim.g.default_shell, 'powershell.exe -nologo')
    util_def_cc    = lib_lua_get(vim.g.default_c_compiler, 'gcc')
    vim.g.python3_host_prog = lib_lua_get(
    vim.g.python3_exec_path,
    vim.fn.expand('$HOME/Appdata/Local/Programs/Python/Python38/python.EXE'))

    vim.o.wildignore = vim.o.wildignore..
    "*.o,*.obj,*.bin,*.dll,*.exe,"..
    "*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**,"..
    "*.pyc,"..
    "*.DS_Store,"..
    "*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz"
elseif vim.fn.has("unix") == 1 then
    util_def_start = 'xdg-open'
    util_def_shell = lib_lua_get(vim.g.default_shell, 'bash')
    util_def_cc    = lib_lua_get(vim.g.default_c_compiler, 'gcc')
    vim.g.python3_host_prog = lib_lua_get(vim.g.python3_exec_path, '/usr/bin/python3')

    vim.o.wildignore = vim.o.wildignore.."*.so"
elseif vim.fn.has("mac") == 1 then
    util_def_start = 'open'
    util_def_shell = lib_lua_get(vim.g.default_shell, 'zsh')
    util_def_cc    = lib_lua_get(vim.g.default_c_compiler, 'clang')
end
--- Search web
local util_web_list = {
    b = "https://www.baidu.com/s?wd=",
    g = "https://www.google.com/search?q=",
    h = "https://github.com/search?q=",
    y = "https://dict.youdao.com/w/eng/"
}


-- Functions
--- Mouse toggle
function util_lua_mouse_toggle(args)
    if (vim.o.mouse == 'a') then
        vim.o.mouse = ''
        print("Mouse disabled.")
    else
        vim.o.mouse = 'a'
        print("Mouse enabled.")
    end
end

--- Background toggle
function util_lua_bg_toggle()
    if (vim.o.background == 'dark') then
        vim.o.background = 'light'
    else
        vim.o.background = 'dark'
    end
    if (vim.g.colors_name) then
        vim.fn.execute('colorscheme '..vim.g.colors_name)
    end
end

--- Open terminal and launch shell
function util_lua_terminal()
    lib_lua_belowright_split(15)
    vim.fn.execute('terminal '..util_def_shell)
end

--- Open file with system default browser.
function util_lua_open(file_path)
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
function util_lua_hanzi_count(mode)
    local content
    if (mode == "n") then
        content = vim.fn.getline(1, '$')
    elseif (mode == "v") then
        content = vim.fn.split(lib_lua_get_visual_selection(), "\n")
    else
        return
    end

    local h_count = 0
    for i, line in ipairs(content) do
        for j, char in ipairs(vim.fn.split(line, "\\zs")) do
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
function util_lua_search_web(mode, site)
    local search_obj
    if mode == 'n' then
        local del_list = {
            ".", ",", "'", "\"",
            ";", "*", "~", "`", 
            "(", ")", "[", "]", "{", "}"
        }
        search_obj = lib_lua_escape(lib_lua_get_clean_cWORD(del_list), lib_const_esc_url)
    elseif mode == 'v' then
        search_obj = lib_lua_escape(lib_lua_get_visual_selection(), lib_const_esc_url)
    end

    local url_raw = util_web_list[site]..search_obj
    local url_arg
    if vim.fn.has('win32') then
        url_arg = url_raw
    else
        url_arg = "\""..url_raw.."\""
    end
    vim.fn.execute('!'..util_def_start..' '..url_arg)
end

--- Calculate the day of week from a date(yyyy-mm-dd).
function util_lua_append_day_from_date()
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

    local day_of_week = lib_lua_zeller(int_a, int_m, int_d)
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
local function util_lua_md_check_line(lnum)
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

function util_lua_md_insert_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = util_lua_md_check_line('.')
    local l_det = 0
    local l_bul, l_ind

    if (c_det == 0) then
        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = util_lua_md_check_line(b_num)
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
            local f_det, f_str, f_bul, f_ind = util_lua_md_check_line(f_num)
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

function util_lua_md_sort_num_bullet()
    local c_num = vim.fn.line('.')
    local c_det, c_str, c_bul, c_ind = util_lua_md_check_line('.')

    if (c_det == 2) then
        local b_num_list = { c_num }
        local f_num_list = {}

        local b_num = c_num - 1
        while (b_num > 0) do
            local b_det, b_str, b_bul, b_ind = util_lua_md_check_line(b_num)
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
            local f_det, f_str, f_bul, f_ind = util_lua_md_check_line(f_num)
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
function util_lua_latex_xelatex()
    local name = vim.fn.expand('%:r')
    vim.fn.execute('!xelatex -synctex=1 '..
    '-interaction=nonstopmode -file-line-error '..name..'.tex', '')
end

function util_lua_latex_xelatex2()
    util_lua_latex_xelatex()
    util_lua_latex_xelatex()
end

function util_lua_latex_biber()
    local name = vim.fn.expand('%:r')
    util_lua_latex_xelatex()
    vim.fn.execute('!biber '..name..'.bcf', '')
    util_lua_latex_xelatex2()
end

--- Run code
function util_lua_run_or_compile(option)
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
        lib_lua_belowright_split(size)
        vim.fn.execute(term_cmd)
    else
        vim.cmd(term_cmd)
    end
end

--- Git push all
function util_lua_git_push_all(...)
    local arg_list = {...}
    local git_root = lib_lua_get_git_root()
    local git_branch

    if git_root then
        git_branch = lib_lua_get_git_branch(git_root)
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


-- Key maps
--- Windows-like behaviors.
vim.api.nvim_set_keymap('n', '<C-S>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Z>', 'u',      { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-c>', '"+y',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-x>', '"+x',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-v>', '"+p',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-v>', '"+p',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-v>', '<C-R>=@+<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-a>', 'ggVG',   { noremap = true, silent = true })
--- Search visual selection.
vim.api.nvim_set_keymap(
    'v',
    '*',
    'y/\\V<C-r>=v:lua.lib_lua_get_visual_selection()<CR><CR>',
    { noremap = true, silent = true })
--- Mouse toggle.
vim.api.nvim_set_keymap(
    'n',
    '<F2>',
    '<cmd>lua util_lua_mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'v',
    '<F2>',
    ':<C-U>lua util_lua_mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<F2>',
    '<C-O><cmd>lua util_lua_mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    't',
    '<F2>',
    '<C-\\><C-N><cmd>lua util_lua_mouse_toggle()<CR>',
    { noremap = true, silent = true })
--- Background toggle.
vim.api.nvim_set_keymap(
    'n',
    '<leader>bg',
    '<cmd>lua util_lua_bg_toggle()<CR>',
    { noremap = true, silent = true })
--- Explorer.
vim.api.nvim_set_keymap(
    'n',
    '<leader>oe',
    '<cmd>lua util_lua_open(".")<CR>',
    { noremap = true, silent = true })
--- Terminal.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ot',
    '<cmd>lua util_lua_terminal()<CR>i',
    { noremap = true, silent = true })
--- Open with system default browser.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ob',
    '<cmd>lua util_lua_open(vim.fn.expand("%:p"))<CR>',
    { noremap = true, silent = true })
--- Hanzi count.
vim.api.nvim_set_keymap(
    'n',
    '<leader>cc',
    "<cmd>lua util_lua_hanzi_count('n')<CR>",
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'v',
    '<leader>cc',
    ":<C-u>lua util_lua_hanzi_count('v')<CR>",
    { noremap = true, silent = true })
--- Append day of week after the date.
vim.api.nvim_set_keymap(
    'n',
    '<leader>dd',
    ":lua util_lua_append_day_from_date()<CR>",
    { noremap = true, silent = true })
--- Insert an orgmode-style timestamp at the end of the line.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ds',
    "A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>",
    { noremap = true, silent = true })
--- List bullets.
vim.api.nvim_set_keymap(
    'i',
    '<M-CR>',
    "<C-o>:lua util_lua_md_insert_bullet()<CR>",
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>ml',
    ":lua util_lua_md_sort_num_bullet()<CR>",
    { noremap = true, silent = true })
--- Echo git status.
vim.api.nvim_set_keymap(
    'n',
    '<leader>vs',
    ':!git status<CR>',
    { noremap = true, silent = true })
--- Search cword in web browser.
for key,_ in pairs(util_web_list) do
    vim.api.nvim_set_keymap(
        'n',
        '<leader>k'..key,
        '<cmd>lua util_lua_search_web("n", "'..key..'")<CR>',
            { noremap = true, silent = true })
    vim.api.nvim_set_keymap(
        'v',
        '<leader>k'..key,
        ':<C-U>lua util_lua_search_web("v", "'..key..'")<CR>',
        { noremap = true, silent = true })
end
--- Emacs shit.
vim.api.nvim_set_keymap('n', '<M-x>', ':',      { noremap = true })
vim.api.nvim_set_keymap('i', '<M-x>', '<C-O>:', { noremap = true })
vim.api.nvim_set_keymap('i', '<M-b>', '<C-O>b', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-f>', '<C-O>e<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-SPACE>', '<C-O>v', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-A>', '<C-O>g0', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-E>', '<C-O>g$', { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-K>',
    '<C-\\><C-O>D',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-F>',
    [[col('.') >= col('$') ? "\<C-o>+" : g:lib_const_r]],
    { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-B>',
    [[col('.') == 1 ? "\<C-o>-\<C-o>$" : g:lib_const_l]],
    { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<M-d>',
    '<C-\\><C-O>dw',
    { noremap = true, silent = true })
for key,val in pairs({n='j', p='k'}) do
    vim.api.nvim_set_keymap('n', '<C-'..key..'>', 'g'..val, { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<C-'..key..'>', 'g'..val, { noremap = true, silent = true })
    vim.api.nvim_set_keymap('i', '<C-'..key..'>', '<C-O>g'..val, { noremap = true, silent = true })
end


-- Commands
--- LaTeX
vim.cmd('command! Xe1 lua util_lua_latex_xelatex()')
vim.cmd('command! Xe2 lua util_lua_latex_xelatex2()')
vim.cmd('command! Bib lua util_lua_latex_biber()')
vim.cmd('command! PDF lua util_lua_open(vim.fn.expand("%:r")..".pdf")')
--- Run or compile
vim.cmd('command! -nargs=? CodeRun lua util_lua_run_or_compile(<q-args>)')
--- Git push all
vim.cmd('command! -nargs=* PushAll lua util_lua_git_push_all(<f-args>)')
--- Echo time(May be useful in full screen?)
vim.cmd([[command! Time :echo strftime('%Y-%m-%d %a %T')]])
