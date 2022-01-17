local kbd = vim.api.nvim_set_keymap

local nt = { noremap = true }
local ntst = { noremap = true, silent = true }
local ntstet = { noremap = true, silent = true, expr = true }


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
kbd('n', '<leader>bc', '<Cmd>cd %:p:h<CR>:pwd<CR>', nt)
kbd('n', '<leader>bd',
[[index(['help', 'terminal', 'nofile', 'quickfix'], &buftype) >= 0 ||]]
..[[len(getbufinfo({'buflisted':1})) <= 2 ?]]
..[[":bd<CR>" : ":bp|bd#<CR>"]], ntstet)
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
kbd('i', '<C-F>', [[col('.') >= col('$') ? "<C-\><C-O>+" : g:const_dir_r]],     ntstet)
kbd('i', '<C-B>', [[col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:const_dir_l]], ntstet)
kbd('i', '<M-d>', '<C-\\><C-O>dw', ntst)
for key, val in pairs({n='j', p='k'}) do
    kbd('n', '<C-'..key..'>', 'g'..val,            ntst)
    kbd('v', '<C-'..key..'>', 'g'..val,            ntst)
    kbd('i', '<C-'..key..'>', '<C-\\><C-O>g'..val, ntst)
end
-- Move line.
kbd('n', '<M-p>', '<Cmd>exe "move" max([line(".") - 2, 0])<CR>', ntst)
kbd('n', '<M-n>', '<Cmd>exe "move" min([line(".") + 1, line("$")])<CR>', ntst)
kbd('v', '<M-p>', [[:<C-U>exe "'<,'>move" max([line("'<") - 2, 0])<CR>gv]], ntst)
kbd('v', '<M-n>', [[:<C-U>exe "'<,'>move" min([line("'>") + 1, line("$")])<CR>gv]], ntst)


-- Search visual selection.
kbd('v', '*', [[<ESC>/\V<C-r>=v:lua.require("utility.lib").get_visual_selection()<CR><CR>]], ntst)
-- Mouse toggle.
kbd('n', '<F2>', '<Cmd>call usr#misc#mouse_toggle()<CR>',            ntst)
kbd('v', '<F2>', ':<C-U>call usr#misc#mouse_toggle()<CR>',           ntst)
kbd('i', '<F2>', '<C-\\><C-O><Cmd>call usr#misc#mouse_toggle()<CR>', ntst)
kbd('t', '<F2>', '<C-\\><C-N><Cmd>call usr#misc#mouse_toggle()<CR>', ntst)
-- Run code.
kbd('n', '<F5>', '<Cmd>lua require("utility.comp").run_or_compile("")<CR>', ntst)
-- Show document.
kbd('n', 'K', '<Cmd>lua require("utility.util").show_doc()<CR>', ntst)
-- Background toggle.
kbd('n', '<leader>bg', '<Cmd>call usr#misc#bg_toggle()<CR>', ntst)
-- Open opt file.
kbd('n', '<M-,>', '<Cmd>call usr#misc#open_opt()<CR>', ntst)
-- Explorer.
kbd('n', '<leader>oe', '<Cmd>lua require("utility.util").sys_open(vim.fn.expand("%:p:h"))<CR>', ntst)
-- Terminal.
kbd('n', '<leader>ot', '<Cmd>lua require("utility.util").terminal()<CR>i', ntst)
-- Open file of current buffer with system default browser.
kbd('n', '<leader>ob', '<Cmd>lua require("utility.util").sys_open(vim.fn.expand("%:p"))<CR>', ntst)
-- Open path or url under the cursor or in the selection.
kbd('n', '<leader>ou',
[[<Cmd>lua local util = require("utility.util") ]]..
[[util.sys_open(util.match_path_or_url_under_cursor(), true)<CR>]], ntst)
-- Evaluate formula surrounded by `.
kbd('n', '<leader>ev', '<Cmd>lua require("utility.eval").lua_eval()<CR>',  ntst)
kbd('n', '<leader>el', '<Cmd>lua require("utility.eval").lisp_eval()<CR>', ntst)
-- Append day of week after the date.
kbd('n', '<leader>dd', ':lua require("utility.gtd").append_day_from_date()<CR>', ntst)
-- Insert an timestamp after cursor.
kbd('n', '<leader>ds', "a<C-R>=strftime('<%Y-%m-%d %a %H:%M>')<CR><Esc>", ntst)
-- Print TODO list.
kbd("n", "<leader>dt", '<Cmd>lua require("utility.gtd").print_todo_list()<CR>', ntst)
-- Hanzi count.
kbd('n', '<leader>cc', '<Cmd>lua require("utility.note").hanzi_count("n")<CR>',  ntst)
kbd('v', '<leader>cc', ':<C-u>lua require("utility.note").hanzi_count("v")<CR>', ntst)
-- List bullets.
kbd('i', '<M-CR>', '<C-\\><C-O>:lua require("utility.note").md_insert_bullet()<CR>',  ntst)
kbd('n', '<leader>ml', ':lua require("utility.note").md_sort_num_bullet()<CR>', ntst)
kbd('n', '<leader>mv', ':call usr#misc#show_toc()<CR>', ntst)
-- Echo git status.
kbd('n', '<leader>gs', ':!git status<CR>', ntst)
-- Search cword in web browser.
local web_list = {
    b = "https://www.baidu.com/s?wd=",
    g = "https://www.google.com/search?q=",
    h = "https://github.com/search?q=",
    y = "https://dict.youdao.com/w/eng/"
}
for key, val in pairs(web_list) do
    kbd('n', '<leader>h'..key, '<Cmd>lua require("utility.util").search_web("n", "'..val..'")<CR>',  ntst)
    kbd('v', '<leader>h'..key, ':<C-U>lua require("utility.util").search_web("v", "'..val..'")<CR>', ntst)
end
-- Surround
kbd('n', '<leader>sa', '<Cmd>lua require("utility.srd").srd_add("n")<CR>',  ntst)
kbd('v', '<leader>sa', ':<C-U>lua require("utility.srd").srd_add("v")<CR>', ntst)
kbd('n', '<leader>sd', '<Cmd>lua require("utility.srd").srd_sub("")<CR>',   ntst)
kbd('n', '<leader>sc', '<Cmd>lua require("utility.srd").srd_sub()<CR>',     ntst)
for key, val in pairs({P='`', I='*', B='**', M='***', U='<u>'}) do
    kbd('n', '<M-'..key..'>', '<Cmd>lua require("utility.srd").srd_add("n","'..val..'")<CR>',  ntst)
    kbd('v', '<M-'..key..'>', ':<C-U>lua require("utility.srd").srd_add("v","'..val..'")<CR>', ntst)
end
-- Comment
kbd("n", "<leader>kc", '<Cmd>lua require("utility.cmt").cmt_add_norm()<CR>', ntst)
kbd("v", "<leader>kc", ':<C-U>lua require("utility.cmt").cmt_add_vis()<CR>', ntst)
kbd("n", "<leader>ku", '<Cmd>lua require("utility.cmt").cmt_del_norm()<CR>', ntst)
kbd("v", "<leader>ku", ':<C-U>lua require("utility.cmt").cmt_del_vis()<CR>', ntst)
-- Show highlight information.
kbd("n", "<leader>vs", '<Cmd>lua require("utility.vis").show_hl_captures()<CR>', ntst)
