local kbd = vim.keymap.set
local nt = { noremap = true }
local ntst = { noremap = true, silent = true }
local ntstet = { noremap = true, silent = true, expr = true }
local web_list = {
    b = "https://www.baidu.com/s?wd=",
    g = "https://www.google.com/search?q=",
    h = "https://github.com/search?q=",
    y = "https://dict.youdao.com/w/eng/"
}

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

-- Adjust window size.
kbd('n', '<C-UP>',    '<C-W>-', nt)
kbd('n', '<C-DOWN>',  '<C-W>+', nt)
kbd('n', '<C-LEFT>',  '<C-W>>', nt)
kbd('n', '<C-RIGHT>', '<C-W><', nt)
-- Terminal.
kbd('t', '<ESC>', '<C-\\><C-N>',         nt)
kbd('t', '<M-d>', '<C-\\><C-N>:bd!<CR>', ntst)
-- Find and replace.
kbd('n', '<M-g>', ':%s/', nt)
kbd('v', '<M-g>', ':s/',  nt)
-- Buffer.
kbd('n', '<leader>bh', '<Cmd>noh<CR>', ntst)
kbd('n', '<leader>bl', '<Cmd>ls<CR>',  ntst)
kbd('n', '<leader>bn', '<Cmd>bn<CR>',  ntst)
kbd('n', '<leader>bp', '<Cmd>bp<CR>',  ntst)
-- Toggle spell check status.
kbd('n', '<leader>cs', '<Cmd>setlocal spell! spelllang=en_us<CR>', ntst)
-- Navigate windows.
for _, direct in ipairs({'h', 'j', 'k', 'l', 'w'}) do
    kbd('n', '<M-'..direct..'>', '<C-W>'..direct,            ntst)
    kbd('i', '<M-'..direct..'>', '<ESC><C-W>'..direct,       ntst)
    kbd('t', '<M-'..direct..'>', '<C-\\><C-N><C-W>'..direct, ntst)
end
-- Switch tab.
for i = 1, 10, 1 do
    local tab_key
    if i == 10 then tab_key = 0 else tab_key = i end
    kbd('n', '<M-'..tostring(tab_key)..'>', '<Cmd>tabn '..tostring(i)..'<CR>',  ntst)
    kbd('i', '<M-'..tostring(tab_key)..'>', '<C-O>:tabn '..tostring(i)..'<CR>', ntst)
end
-- Command mode.
kbd('c', '<C-A>',  '<C-B>',     nt)
kbd('c', '<C-B>',  '<LEFT>',    nt)
kbd('c', '<C-F>',  '<RIGHT>',   nt)
kbd('c', '<C-H>',  '<C-F>',     nt)
kbd('c', '<M-b>',  '<C-LEFT>',  nt)
kbd('c', '<M-f>',  '<C-RIGHT>', nt)
kbd('c', '<M-BS>', '<C-W>',     nt)
-- Windows shit.
kbd('n', '<C-S>', ':w<CR>',             ntst)
kbd('i', '<C-S>', '<C-\\><C-O>:w<CR>',  ntst)
kbd('v', '<M-c>', '"+y',                ntst)
kbd('v', '<M-x>', '"+x',                ntst)
kbd('n', '<M-v>', '"+p',                ntst)
kbd('v', '<M-v>', '"+p',                ntst)
kbd('i', '<M-v>', '<C-R>=@+<CR>',       ntst)
kbd('n', '<M-a>', 'ggVG',               ntst)
-- Emacs shit.
kbd('n', '<M-x>', ':',                   nt)
kbd('i', '<M-x>', '<C-\\><C-O>:',        nt)
kbd('i', '<M-b>', '<C-\\><C-O>b',        ntst)
kbd('i', '<M-f>', '<C-\\><C-O>e<Right>', ntst)
kbd('n', '<M-b>', 'b',                   ntst)
kbd('n', '<M-f>', 'e',                   ntst)
kbd('i', '<C-A>', '<C-\\><C-O>g0',       ntst)
kbd('i', '<C-E>', '<C-\\><C-O>g$',       ntst)
kbd('i', '<C-K>', '<C-\\><C-O>D',        ntst)
kbd('i', '<C-F>', [[col('.') >= col('$') ? "<C-\><C-O>+" : g:_const_dir_r]],     ntstet)
kbd('i', '<C-B>', [[col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:_const_dir_l]], ntstet)
kbd('i', '<M-d>', '<C-\\><C-O>dw', ntst)
for key, val in pairs({ n = 'j', p = 'k' }) do
    kbd('n', '<C-'..key..'>', 'g'..val,            ntst)
    kbd('v', '<C-'..key..'>', 'g'..val,            ntst)
    kbd('i', '<C-'..key..'>', '<C-\\><C-O>g'..val, ntst)
end
-- Move line.
kbd('n', '<M-p>', '<Cmd>exe "move" max([line(".") - 2, 0])<CR>', ntst)
kbd('n', '<M-n>', '<Cmd>exe "move" min([line(".") + 1, line("$")])<CR>', ntst)
kbd('v', '<M-p>', [[:<C-U>exe "'<,'>move" max([line("'<") - 2, 0])<CR>gv]], ntst)
kbd('v', '<M-n>', [[:<C-U>exe "'<,'>move" min([line("'>") + 1, line("$")])<CR>gv]], ntst)

-- Mouse toggle.
kbd({'n', 'v', 'i', 't'}, '<F2>', vim.fn['my#compat#mouse_toggle'], ntst)
-- Run code.
-- FIXME: Using a function for {rhs} will flush the cmdline output with `print`.
kbd('n', '<F5>', ':lua require("utility.comp").run_or_compile("")<CR>', ntst)
-- Show document.
kbd('n', 'K', function ()
    local lib = require('utility.lib')
    local word, _, _ = lib.get_word()
    lib.try(vim.cmd, 'h '..word)
end, ntst)
-- Search visual selection.
kbd('v', '*', function ()
    local pat = require('utility.lib').get_visual_selection()
    vim.cmd([[/\V]]..pat)
end, ntst)
-- Buffer.
kbd('n', '<leader>bc', function ()
    vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))
    vim.cmd('pwd')
end, nt)
kbd('n', '<leader>bd', function ()
    if vim.tbl_contains({ 'help', 'terminal',
        'nofile', 'quickfix' }, vim.bo.bt)
        or #(vim.fn.getbufinfo({buflisted = 1})) <= 2 then
        return ':bd<CR>'
    else
        return ':bp|bd#<CR>'
    end
end, ntstet)
-- Background toggle.
kbd('n', '<leader>bg', vim.fn['my#compat#bg_toggle'], ntst)
-- Open opt file.
kbd('n', '<M-,>', vim.fn['my#compat#open_opt'], ntst)
-- Explorer.
kbd('n', '<leader>oe', function ()
    require('utility.util').sys_open(vim.fn.expand('%:p:h'))
end, ntst)
-- Terminal
kbd('n', '<leader>ot', function ()
    local ok = require('utility.util').terminal()
    if ok then
        vim.api.nvim_feedkeys('i', 'n', true)
    end
end, ntst)
-- Open file of current buffer with system default browser.
kbd('n', '<leader>ob', function ()
    require('utility.util').sys_open(vim.fn.expand('%:p'))
end, ntst)
-- Open path or url under the cursor or in the selection.
kbd('n', '<leader>ou', function ()
    local util = require('utility.util')
    util.sys_open(util.match_path_or_url_under_cursor(), true)
end, ntst)
-- Evaluate formula surrounded by `.
kbd('n', '<leader>ev', function ()
    require('utility.eval').lua_eval()
end, ntst)
kbd('n', '<leader>el', function ()
    require('utility.eval').lisp_eval()
end, ntst)
-- Insert an timestamp after cursor.
kbd('n', '<leader>ds', function ()
    vim.paste({os.date('<%Y-%m-%d %a %H:%M>')}, -1)
end, ntst)
-- Append day of week after the date.
kbd('n', '<leader>dd', function ()
    require('utility.gtd').append_day_from_date()
end, ntst)
-- Print TODO list.
kbd('n', '<leader>dt', function ()
    require('utility.gtd').print_todo_list()
end, ntst)
-- Hanzi count.
kbd({'n', 'v'}, '<leader>cc', function ()
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
end, ntst)
-- List bullets.
kbd('i', '<M-CR>', function ()
    require('utility.note').md_insert_bullet()
end, ntst)
kbd('n', '<leader>ml', function ()
    require('utility.note').md_sort_num_bullet()
end, ntst)
-- Echo git status.
kbd('n', '<leader>gs', ':!git status<CR>', ntst)
-- Search cword in web browser.
for key, val in pairs(web_list) do
    kbd({'n', 'v'}, '<leader>h'..key, function ()
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
        require("utility.util").sys_open(val..txt)
    end, ntst)
end
-- Surround
kbd({'n', 'v'}, '<leader>sa', function ()
    local mode = get_mode()
    if mode then
        vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<C-\\><C-N>', true, false, true),
        'n', true)
        require('utility.srd').srd_add(mode)
    end
end, ntst)
kbd('n', '<leader>sd', function ()
    require('utility.srd').srd_sub('')
end, ntst)
kbd('n', '<leader>sc', function ()
    require('utility.srd').srd_sub()
end, ntst)
-- Comment
kbd('n', '<leader>kc', function ()
    require('utility.cmt').cmt_add_norm()
end, ntst)
kbd('n', '<leader>ku', function ()
    require('utility.cmt').cmt_del_norm()
end, ntst)
kbd('v', '<leader>kc', [[:<C-U>lua ]]
..[[require('utility.cmt').cmt_add_vis()<CR>]], ntst)
kbd('v', '<leader>ku', [[:<C-U>lua ]]
..[[require('utility.cmt').cmt_del_vis()<CR>]], ntst)
-- Show highlight information.
kbd('n', '<leader>vs', function ()
    require('utility.syn'):new(unpack(vim.api.nvim_win_get_cursor(0))):show()
end, ntst)
