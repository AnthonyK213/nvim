---Add a new mapping.
---@param desc string To give a description to the mapping.
---@param mode string|table Mode short-name.
---@param lhs string Left-hand side {lhs} of the mapping.
---@param rhs string|function Right-hand side {rhs} of the mapping.
---@param opts? table Optional parameters map.
local kbd = function (desc, mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    if desc then options.desc = desc end
    vim.keymap.set(mode, lhs, rhs, options)
end

---Normal mode or Visual mode?
---@return string|nil
local get_mode = function ()
    local m = vim.api.nvim_get_mode().mode
    if m == 'n' then
        return m
    elseif vim.tbl_contains({'v', 'V', ''}, m) then
        return 'v'
    else
        return nil
    end
end

---Switch to normal mode.
local to_normal = function ()
    vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
end

kbd("Adjust window size up", "n", "<C-UP>", "<C-W>-")
kbd("Adjust window size down", "n", "<C-DOWN>", "<C-W>+")
kbd("Adjust window size left", "n", "<C-LEFT>", "<C-W>>")
kbd("Adjust window size right", "n", "<C-RIGHT>", "<C-W><")
kbd("Switch to normal mode in terminal", 't', '<ESC>', '<C-\\><C-N>')
kbd("Close terminal", 't', '<M-d>', '<C-\\><C-N>:bd!<CR>')
kbd("Find and replace", 'n', '<M-g>', ':%s/')
kbd("Find and replace", 'v', '<M-g>', ':s/')
kbd("Stop the search highlighting", 'n', '<leader>bh', '<Cmd>noh<CR>')
kbd("Next buffer", 'n', '<leader>bn', '<Cmd>bn<CR>')
kbd("Previous buffer", 'n', '<leader>bp', '<Cmd>bp<CR>')
kbd("Toggle spell check", 'n', '<leader>cs', '<Cmd>setlocal spell! spelllang=en_us<CR>')
for direct, desc in pairs {
    h = "left", j = "down", k = "up", l = "right", w = "toggle"
}
do
    kbd("Navigate window: "..desc, { "n", "i", "t" }, '<M-'..direct..'>', function ()
        to_normal()
        require("utility.lib").feedkeys("<C-W>"..direct, "nx", false)
    end)
end
for i = 1, 10, 1 do
    kbd("Goto tab "..tostring(i), { "n", "i", "t" }, '<M-'..tostring(i % 10)..'>', function ()
        to_normal()
        vim.cmd("tabn "..tostring(i))
    end)
end
kbd("Cursor to beginning of command-line", 'c', '<C-A>', '<C-B>')
kbd("Cursor left", 'c', '<C-B>', '<LEFT>')
kbd("Cursor right", 'c', '<C-F>', '<RIGHT>')
kbd("Open the command-line window", 'c', '<C-H>', '<C-F>')
kbd("Cursor one WORD left", 'c', '<M-b>', '<C-LEFT>')
kbd("Cursor one WORD right", 'c', '<M-f>', '<C-RIGHT>')
kbd("Delete the word before the cursor", 'c', '<M-BS>', '<C-W>')
kbd("Write the whole buffer to the current file", { "n", "i" }, '<C-S>', function ()
    vim.cmd("write")
end)
kbd("Copy", 'v', '<M-c>', '"+y')
kbd("Cut", 'v', '<M-x>', '"+x')
kbd("Paste", { 'n', 'v' }, '<M-v>', '"+p')
kbd("Paste", 'i', '<M-v>', '<C-R>=@+<CR>')
kbd("Select all lines in buffer", 'n', '<M-a>', 'ggVG')
kbd("Command-line mode", 'n', '<M-x>', ':')
kbd("Command-line mode", 'i', '<M-x>', '<C-\\><C-O>:')
kbd("Cursor one word left", 'i', '<M-b>', '<C-\\><C-O>b')
kbd("Cursor one word right", 'i', '<M-f>', '<C-\\><C-O>e<Right>')
kbd("Cursor one word left", 'n', '<M-b>', 'b')
kbd("Cursor one word right", 'n', '<M-f>', 'e')
kbd("To the first character of the screen line", 'i', '<C-A>', '<C-\\><C-O>g0')
kbd("To the last character of the screen line", 'i', '<C-E>', '<C-\\><C-O>g$')
kbd("Kill text until the end of the line", 'i', '<C-K>', '<C-\\><C-O>D')
kbd("Cursor left", 'i', '<C-B>', [[col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:_const_dir_l]])
kbd("Cursor right", 'i', '<C-F>', [[col('.') >= col('$') ? "<C-\><C-O>+" : g:_const_dir_r]])
kbd("Kill text until the end of the word", 'i', '<M-d>', '<C-\\><C-O>dw')
for key, val in pairs { down = { 'n', 'j' }, up = { 'p', 'k' } } do
    kbd("Cursor "..key, { 'n', 'v' }, '<C-'..val[1]..'>', 'g'..val[2])
    kbd("Cursor "..key, 'i', '<C-'..val[1]..'>', '<C-\\><C-O>g'..val[2])
end
kbd("Move line up", 'n', '<M-p>', '<Cmd>exe "move" max([line(".") - 2, 0])<CR>')
kbd("Move line down", 'n', '<M-n>', '<Cmd>exe "move" min([line(".") + 1, line("$")])<CR>')
kbd("Move block up", 'v', '<M-p>', [[:<C-U>exe "'<,'>move" max([line("'<") - 2, 0])<CR>gv]])
kbd("Move block down", 'v', '<M-n>', [[:<C-U>exe "'<,'>move" min([line("'>") + 1, line("$")])<CR>gv]])
kbd("Mouse toggle", {'n', 'v', 'i', 't'}, '<F2>', function ()
    if vim.o.mouse == "a" then
        vim.o.mouse = ""
        vim.notify("Mouse disabled")
    else
        vim.o.mouse = "a"
        vim.notify("Mouse enabled")
    end
end)
kbd("Run code", 'n', '<F5>', function () require("utility.comp").run_or_compile("") end)
kbd("Run test", 'n', '<F6>', function () require("utility.comp").run_or_compile("test") end)
kbd("Show document", 'n', 'K', function ()
    local lib = require('utility.lib')
    local word, _, _ = lib.get_word()
    lib.try(vim.cmd, 'h '..word)
end)
kbd("Search visual selection forward", 'v', '*', function ()
    local pat = require('utility.lib').get_visual_selection()
    :gsub('([/\\])', function (x)
        return '\\'..x
    end):gsub("\n", [[\n]])
    vim.cmd([[/\V]]..pat)
end)
kbd("Search visual selection backward", 'v', '#', function ()
    local pat = require('utility.lib').get_visual_selection()
    :gsub('([?\\])', function (x)
        return '\\'..x
    end):gsub("\n", [[\n]])
    vim.cmd([[?\V]]..pat)
end)
kbd("Change cwd to current buffer", 'n', '<leader>bc', function ()
    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))
    vim.cmd('pwd')
end)
kbd("Delete current buffer", 'n', '<leader>bd', function ()
    if vim.tbl_contains({ 'help', 'terminal', 'nofile', 'quickfix' }, vim.bo.bt)
        or #(vim.fn.getbufinfo { buflisted = 1 }) <= 2 then
        vim.cmd('bd')
    else
        vim.cmd('bp|bd#')
    end
end)
kbd("Background toggle", 'n', '<leader>bg', function ()
    if not vim.g._my_theme_switchable or vim.g._my_lock_background then
        return
    end
    vim.o.background = vim.o.background == "dark" and "light" or "dark"
end)
kbd("Open nvimrc", 'n', '<M-,>', vim.fn['my#compat#open_nvimrc'])
kbd("Open system file manager", 'n', '<leader>oe', function ()
    require('utility.util').sys_open(vim.fn.expand('%:p:h'))
end)
kbd("Open terminal", 'n', '<leader>ot', function ()
    local ok = require('utility.util').terminal()
    if ok then
        vim.api.nvim_feedkeys('i', 'n', true)
    end
end)
kbd("Open current file with the system default application", 'n', '<leader>ob', function ()
    require('utility.util').sys_open(vim.fn.expand('%:p'))
end)
kbd("Open path or url under the cursor", 'n', '<leader>ou', function ()
    local util = require('utility.util')
    util.sys_open(util.match_path_or_url_under_cursor(), true)
end)
kbd("Evaluate lua math expression surrounded by `", 'n', '<leader>ev', function ()
    require('utility.eval').lua_eval()
end)
kbd("Evaluate lisp math expression surrounded by `", 'n', '<leader>el', function ()
    require('utility.eval').lisp_eval()
end)
kbd("Insert a timestamp after cursor", 'n', '<leader>ds', function ()
    vim.paste({os.date('<%Y-%m-%d %a %H:%M>')}, -1)
end)
kbd("Append day of week after the date", 'n', '<leader>dd', function ()
    require('utility.gtd').append_day_from_date()
end)
kbd("Print TODO list", 'n', '<leader>dt', function ()
    require('utility.gtd').print_todo_list()
end)
kbd("Hanzi count", {'n', 'v'}, '<leader>cc', function ()
    local mode = get_mode()
    local txt
    if mode == "n" then
        txt = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    elseif mode == "v" then
        txt = require('utility.lib').get_visual_selection()
    else
        return
    end
    require('utility.note').hanzi_count(txt)
end)
kbd("Insert list bullets", 'i', '<M-CR>', function ()
    require('utility.note').md_insert_bullet()
end)
kbd("Regenerate list bullets", 'n', '<leader>ml', function ()
    require('utility.note').md_sort_num_bullet()
end)
kbd("Echo git status", 'n', '<leader>gs', ':!git status<CR>')
for key, val in pairs {
    Baidu  = { "b", "https://www.baidu.com/s?wd=" },
    Google = { "g", "https://www.google.com/search?q=" },
    GitHub = { "h", "https://github.com/search?q=" },
    Youdao = { "y", "https://dict.youdao.com/w/eng/" }
}
do
    kbd("Search cword with "..key, {'n', 'v'}, '<leader>h'..val[1], function ()
        local lib = require('utility.lib')
        local txt
        local mode = get_mode()
        if mode == 'n' then
            local word, _, _ = lib.get_word()
            txt = lib.encode_url(word)
        elseif mode == 'v' then
            txt = lib.encode_url(lib.get_visual_selection())
        else
            return
        end
        require("utility.util").sys_open(val[2]..txt)
    end)
end
kbd("Surrounding add", {'n', 'v'}, '<leader>sa', function ()
    local mode = get_mode()
    if mode then
        to_normal()
        require('utility.srd').srd_add(mode)
    end
end)
kbd("Surrounding delete", 'n', '<leader>sd', function ()
    require('utility.srd').srd_sub('')
end)
kbd("Surrounding change", 'n', '<leader>sc', function ()
    require('utility.srd').srd_sub()
end)
kbd("Comment current/selected line(s)", {'n', 'v'}, '<leader>kc', function ()
    local mode = get_mode()
    if mode == 'n' then
        require('utility.cmt').cmt_add_norm()
    elseif mode == 'v' then
        to_normal()
        require('utility.cmt').cmt_add_vis()
    else
        return
    end
end)
kbd("Uncomment current/selected line(s)", {'n', 'v'}, '<leader>ku', function ()
    local mode = get_mode()
    if mode == 'n' then
        require('utility.cmt').cmt_del_norm()
    elseif mode == 'v' then
        to_normal()
        require('utility.cmt').cmt_del_vis()
    else
        return
    end
end)
kbd("Show highlight information", 'n', '<leader>vs', function ()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    require('utility.syn').new(row, col):show()
end)
