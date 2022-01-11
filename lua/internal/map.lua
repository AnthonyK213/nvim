local keymap = vim.api.nvim_set_keymap

local nt = { noremap = true }
local ntst = { noremap = true, silent = true }
local ntstet = { noremap = true, silent = true, expr = true }


-- Adjust window size.
keymap('n', '<C-UP>',    '<C-W>-', nt)
keymap('n', '<C-DOWN>',  '<C-W>+', nt)
keymap('n', '<C-LEFT>',  '<C-W>>', nt)
keymap('n', '<C-RIGHT>', '<C-W><', nt)
-- Terminal.
keymap('t', '<ESC>', '<C-\\><C-N>',         nt)
keymap('t', '<M-d>', '<C-\\><C-N>:bd!<CR>', ntst)
-- Find and replace.
keymap('n', '<M-g>', ':%s/', nt)
keymap('v', '<M-g>', ':s/',  nt)
-- Normal command.
keymap('n', '<M-n>', ':%normal ', nt)
keymap('v', '<M-n>', ':normal ',  nt)
-- Buffer.
keymap('n', '<leader>bc', '<Cmd>cd %:p:h<CR>:pwd<CR>', nt)
keymap('n', '<leader>bd',
[[index(['help','terminal','nofile','quickfix'], &buftype) >= 0 ||]]..
[[len(getbufinfo({'buflisted':1})) <= 2 ?]]..
[[":bd<CR>" : ":bp|bd#<CR>"]],
ntstet)
keymap('n', '<leader>bh', '<Cmd>noh<CR>', ntst)
keymap('n', '<leader>bl', '<Cmd>ls<CR>',  ntst)
keymap('n', '<leader>bn', '<Cmd>bn<CR>',  ntst)
keymap('n', '<leader>bp', '<Cmd>bp<CR>',  ntst)
-- Toggle spell check status.
keymap('n', '<leader>cs', '<Cmd>setlocal spell! spelllang=en_us<CR>', ntst)
-- Navigate windows.
for _, direct in ipairs({'h', 'j', 'k', 'l', 'w'}) do
    keymap('n', '<M-'..direct..'>', '<C-W>'..direct,            ntst)
    keymap('i', '<M-'..direct..'>', '<ESC><C-W>'..direct,       ntst)
    keymap('t', '<M-'..direct..'>', '<C-\\><C-N><C-W>'..direct, ntst)
end
-- Switch tab.
for i = 1, 10, 1 do
    local tab_key
    if i == 10 then tab_key = 0 else tab_key = i end
    keymap('n', '<M-'..tostring(tab_key)..'>', '<Cmd>tabn '..tostring(i)..'<CR>',  ntst)
    keymap('i', '<M-'..tostring(tab_key)..'>', '<C-O>:tabn '..tostring(i)..'<CR>', ntst)
end
-- Command mode.
keymap('c', '<C-A>',  '<C-B>',     nt)
keymap('c', '<C-B>',  '<LEFT>',    nt)
keymap('c', '<C-F>',  '<RIGHT>',   nt)
keymap('c', '<C-H>',  '<C-F>',     nt)
keymap('c', '<M-b>',  '<C-LEFT>',  nt)
keymap('c', '<M-f>',  '<C-RIGHT>', nt)
keymap('c', '<M-BS>', '<C-W>',     nt)


-- Windows shit.
keymap('n', '<C-S>', ':w<CR>',             ntst)
keymap('i', '<C-S>', '<C-\\><C-O>:w<CR>',  ntst)
keymap('v', '<M-c>', '"+y',                ntst)
keymap('v', '<M-x>', '"+x',                ntst)
keymap('n', '<M-v>', '"+p',                ntst)
keymap('v', '<M-v>', '"+p',                ntst)
keymap('i', '<M-v>', '<C-R>=@+<CR>',       ntst)
keymap('n', '<M-a>', 'ggVG',               ntst)
-- Emacs shit.
keymap('n', '<M-x>', ':',                   nt)
keymap('i', '<M-x>', '<C-\\><C-O>:',        nt)
keymap('i', '<M-b>', '<C-\\><C-O>b',        ntst)
keymap('i', '<M-f>', '<C-\\><C-O>e<Right>', ntst)
keymap('n', '<M-b>', 'b',                   ntst)
keymap('n', '<M-f>', 'e',                   ntst)
keymap('i', '<C-A>', '<C-\\><C-O>g0',       ntst)
keymap('i', '<C-E>', '<C-\\><C-O>g$',       ntst)
keymap('i', '<C-K>', '<C-\\><C-O>D',        ntst)
keymap('i', '<C-F>', [[col('.') >= col('$') ? "<C-\><C-O>+" : g:const_dir_r]],     ntstet)
keymap('i', '<C-B>', [[col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:const_dir_l]], ntstet)
keymap('i', '<M-d>', '<C-\\><C-O>dw', ntst)
for key, val in pairs({n='j', p='k'}) do
    keymap('n', '<C-'..key..'>', 'g'..val,            ntst)
    keymap('v', '<C-'..key..'>', 'g'..val,            ntst)
    keymap('i', '<C-'..key..'>', '<C-\\><C-O>g'..val, ntst)
end


-- Search visual selection.
keymap('v', '*', [[<ESC>/\V<C-r>=luaeval('require("utility.lib").get_visual_selection()')<CR><CR>]], ntst)
-- Mouse toggle.
keymap('n', '<F2>', '<Cmd>call usr#misc#mouse_toggle()<CR>',            ntst)
keymap('v', '<F2>', ':<C-U>call usr#misc#mouse_toggle()<CR>',           ntst)
keymap('i', '<F2>', '<C-\\><C-O><Cmd>call usr#misc#mouse_toggle()<CR>', ntst)
keymap('t', '<F2>', '<C-\\><C-N><Cmd>call usr#misc#mouse_toggle()<CR>', ntst)
-- Run code.
keymap('n', '<F5>', '<Cmd>lua require("utility.comp").run_or_compile("")<CR>', ntst)
-- Show document.
keymap('n', 'K', '<Cmd>lua require("utility.util").show_doc()<CR>', ntst)
-- Background toggle.
keymap('n', '<leader>bg', '<Cmd>call usr#misc#bg_toggle()<CR>', ntst)
-- Open opt file.
keymap('n', '<M-,>', '<Cmd>call usr#misc#open_opt()<CR>', ntst)
-- Explorer.
keymap('n', '<leader>oe', '<Cmd>lua require("utility.util").sys_open(vim.fn.expand("%:p:h"))<CR>', ntst)
-- Terminal.
keymap('n', '<leader>ot', '<Cmd>lua require("utility.util").terminal()<CR>i', ntst)
-- Open file of current buffer with system default browser.
keymap('n', '<leader>ob', '<Cmd>lua require("utility.util").sys_open(vim.fn.expand("%:p"))<CR>', ntst)
-- Open path or url under the cursor or in the selection.
keymap('n', '<leader>ou',
[[<Cmd>lua local util = require("utility.util") ]]..
[[util.sys_open(util.match_path_or_url_under_cursor(), true)<CR>]], ntst)
-- Evaluate formula surrounded by `.
keymap('n', '<leader>ev', '<Cmd>lua require("utility.eval").lua_eval()<CR>',  ntst)
keymap('n', '<leader>el', '<Cmd>lua require("utility.eval").lisp_eval()<CR>', ntst)
-- Append day of week after the date.
keymap('n', '<leader>dd', ':lua require("utility.gtd").append_day_from_date()<CR>', ntst)
-- Insert an timestamp after cursor.
keymap('n', '<leader>ds', "a<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>", ntst)
-- Print TODO list.
keymap("n", "<leader>dt", '<Cmd>lua require("utility.gtd").print_todo_list()<CR>', ntst)
-- Hanzi count.
keymap('n', '<leader>cc', '<Cmd>lua require("utility.note").hanzi_count("n")<CR>',  ntst)
keymap('v', '<leader>cc', ':<C-u>lua require("utility.note").hanzi_count("v")<CR>', ntst)
-- List bullets.
keymap('i', '<M-CR>', '<C-\\><C-O>:lua require("utility.note").md_insert_bullet()<CR>',  ntst)
keymap('n', '<leader>ml', ':lua require("utility.note").md_sort_num_bullet()<CR>', ntst)
keymap('n', '<leader>mv', ':call usr#misc#show_toc()<CR>', ntst)
-- Echo git status.
keymap('n', '<leader>gs', ':!git status<CR>', ntst)
-- Search cword in web browser.
local web_list = {
    b = "https://www.baidu.com/s?wd=",
    g = "https://www.google.com/search?q=",
    h = "https://github.com/search?q=",
    y = "https://dict.youdao.com/w/eng/"
}
for key, val in pairs(web_list) do
    keymap('n', '<leader>h'..key, '<Cmd>lua require("utility.util").search_web("n", "'..val..'")<CR>',  ntst)
    keymap('v', '<leader>h'..key, ':<C-U>lua require("utility.util").search_web("v", "'..val..'")<CR>', ntst)
end
-- Surround
keymap('n', '<leader>sa', '<Cmd>lua require("utility.srd").srd_add("n")<CR>',  ntst)
keymap('v', '<leader>sa', ':<C-U>lua require("utility.srd").srd_add("v")<CR>', ntst)
keymap('n', '<leader>sd', '<Cmd>lua require("utility.srd").srd_sub("")<CR>',   ntst)
keymap('n', '<leader>sc', '<Cmd>lua require("utility.srd").srd_sub()<CR>',     ntst)
for key, val in pairs({P='`', I='*', B='**', M='***', U='<u>'}) do
    keymap('n', '<M-'..key..'>', '<Cmd>lua require("utility.srd").srd_add("n","'..val..'")<CR>',  ntst)
    keymap('v', '<M-'..key..'>', ':<C-U>lua require("utility.srd").srd_add("v","'..val..'")<CR>', ntst)
end
-- Comment
keymap("n", "<leader>kc", '<Cmd>lua require("utility.cmt").cmt_add_norm()<CR>', ntst)
keymap("v", "<leader>kc", ':<C-U>lua require("utility.cmt").cmt_add_vis()<CR>', ntst)
keymap("n", "<leader>ku", '<Cmd>lua require("utility.cmt").cmt_del_norm()<CR>', ntst)
keymap("v", "<leader>ku", ':<C-U>lua require("utility.cmt").cmt_del_vis()<CR>', ntst)
-- Show highlight information.
keymap("n", "<leader>vs", '<Cmd>lua require("utility.vis").show_hl_captures()<CR>', ntst)
