local keymap = vim.api.nvim_set_keymap


-- Adjust window size.
keymap('n', '<C-UP>',    '<C-W>-', { noremap = true })
keymap('n', '<C-DOWN>',  '<C-W>+', { noremap = true })
keymap('n', '<C-LEFT>',  '<C-W>>', { noremap = true })
keymap('n', '<C-RIGHT>', '<C-W><', { noremap = true })
-- Open init file.
keymap('n', '<M-,>', '<Cmd>lua require("utility/util").edit_file("$MYVIMRC", true)<CR>', { noremap = true, expr = false, silent = true })
-- Terminal.
keymap('t', '<ESC>', '<C-\\><C-N>',         { noremap = true })
keymap('t', '<M-d>', '<C-\\><C-N>:bd!<CR>', { noremap = true, silent = true })
-- Find and replace.
keymap('n', '<M-f>', ':%s/', { noremap = true })
keymap('v', '<M-f>', ':s/',  { noremap = true })
-- Normal command.
keymap('n', '<M-n>', ':%normal ', { noremap = true })
keymap('v', '<M-n>', ':normal ',  { noremap = true })
-- Evaluate formula surrounded by `.
keymap('n', '<leader>ev', '<Cmd>lua require("utility/eval").lua_eval()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>el', '<Cmd>lua require("utility/eval").lisp_eval()<CR>', { noremap = true, silent = true })
-- Buffer.
keymap('n', '<leader>bc', '<Cmd>cd %:p:h<CR>:pwd<CR>', { noremap = true })
keymap('n', '<leader>bd',
[[index(['help','terminal','nofile','quickfix'], &buftype) >= 0 ||]]..
[[len(getbufinfo({'buflisted':1})) <= 2 ?]]..
[[":bd<CR>" : ":bp|bd#<CR>"]],
{ noremap = true, silent = true, expr = true })
keymap('n', '<leader>bh', '<Cmd>noh<CR>', { noremap = true, silent = true })
keymap('n', '<leader>bn', '<Cmd>bn<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>bp', '<Cmd>bp<CR>',  { noremap = true, silent = true })
-- Toggle spell check status.
keymap('n', '<leader>cs', '<Cmd>setlocal spell! spelllang=en_us<CR>', { noremap = true, silent = true })
-- Navigate windows.
for _, direct in ipairs({'h', 'j', 'k', 'l', 'w'}) do
    keymap('n', '<M-'..direct..'>', '<C-W>'..direct,            { noremap = true })
    keymap('i', '<M-'..direct..'>', '<ESC><C-W>'..direct,       { noremap = true })
    keymap('t', '<M-'..direct..'>', '<C-\\><C-N><C-W>'..direct, { noremap = true })
end
-- Switch tab.
for i = 1, 10, 1 do
    local tab_key
    if i == 10 then tab_key = 0 else tab_key = i end
    keymap('n', '<M-'..tostring(tab_key)..'>', '<Cmd>tabn '..tostring(i)..'<CR>',  { noremap = true, silent = true })
    keymap('i', '<M-'..tostring(tab_key)..'>', '<C-O>:tabn '..tostring(i)..'<CR>', { noremap = true, silent = true })
end


-- Windows shit.
keymap('n', '<C-S>', ':w<CR>',             { noremap = true, silent = true })
keymap('i', '<C-S>', '<C-\\><C-O>:w<CR>',  { noremap = true, silent = true })
keymap('v', '<M-c>', '"+y',                { noremap = true, silent = true })
keymap('v', '<M-x>', '"+x',                { noremap = true, silent = true })
keymap('n', '<M-v>', '"+p',                { noremap = true, silent = true })
keymap('v', '<M-v>', '"+p',                { noremap = true, silent = true })
keymap('i', '<M-v>', '<C-R>=@+<CR>',       { noremap = true, silent = true })
keymap('n', '<M-a>', 'ggVG',               { noremap = true, silent = true })
-- Search visual selection.
keymap('v', '*', [[<ESC>/\V<C-r>=luaeval('require("utility/lib").get_visual_selection()')<CR><CR>]], { noremap = true, silent = true })
-- Mouse toggle.
keymap('n', '<F2>', '<Cmd>call usr#misc#mouse_toggle()<CR>',            { noremap = true, silent = true })
keymap('v', '<F2>', ':<C-U>call usr#misc#mouse_toggle()<CR>',           { noremap = true, silent = true })
keymap('i', '<F2>', '<C-\\><C-O><Cmd>call usr#misc#mouse_toggle()<CR>', { noremap = true, silent = true })
keymap('t', '<F2>', '<C-\\><C-N><Cmd>call usr#misc#mouse_toggle()<CR>', { noremap = true, silent = true })
-- Background toggle.
keymap('n', '<leader>bg', '<Cmd>call usr#misc#bg_toggle()<CR>', { noremap = true, silent = true })
-- Explorer.
keymap('n', '<leader>oe', '<Cmd>lua require("utility/util").open_file(vim.fn.expand("%:p:h"))<CR>', { noremap = true, silent = true })
-- Terminal.
keymap('n', '<leader>ot', '<Cmd>lua require("utility/util").terminal()<CR>i',    { noremap = true, silent = true })
-- Open with system default browser.
keymap('n', '<leader>ob', '<Cmd>lua require("utility/util").open_file(vim.fn.expand("%:p"))<CR>', { noremap = true, silent = true })
-- Hanzi count.
keymap('n', '<leader>cc', '<Cmd>lua require("utility/note").hanzi_count("n")<CR>',  { noremap = true, silent = true })
keymap('v', '<leader>cc', ':<C-u>lua require("utility/note").hanzi_count("v")<CR>', { noremap = true, silent = true })
-- Append day of week after the date.
keymap('n', '<leader>dd', ':lua require("utility/note").append_day_from_date()<CR>', { noremap = true, silent = true })
-- Insert an timestamp at the end of the line.
keymap('n', '<leader>ds', "A<C-R>=strftime(' [[%Y-%m-%d %a %H:%M]]')<CR><Esc>", { noremap = true, silent = true })
-- List bullets.
keymap('i', '<M-CR>', '<C-\\><C-O>:lua require("utility/note").md_insert_bullet()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>ml', ':lua require("utility/note").md_sort_num_bullet()<CR>', { noremap = true, silent = true })
-- Echo git status.
keymap('n', '<leader>hh', ':!git status<CR>', { noremap = true, silent = true })
-- Search cword in web browser.
local web_list = {
    b = "https://www.baidu.com/s?wd=",
    g = "https://www.google.com/search?q=",
    h = "https://github.com/search?q=",
    y = "https://dict.youdao.com/w/eng/"
}
for key, val in pairs(web_list) do
    keymap('n', '<leader>k'..key, '<Cmd>lua require("utility/util").search_web("n", "'..val..'")<CR>',  { noremap = true, silent = true })
    keymap('v', '<leader>k'..key, ':<C-U>lua require("utility/util").search_web("v", "'..val..'")<CR>', { noremap = true, silent = true })
end
-- Emacs shit.
keymap('n', '<M-x>', ':',                   { noremap = true })
keymap('i', '<M-x>', '<C-\\><C-O>:',        { noremap = true })
keymap('i', '<M-b>', '<C-\\><C-O>b',        { noremap = true, silent = true })
keymap('i', '<M-f>', '<C-\\><C-O>e<Right>', { noremap = true, silent = true })
keymap('i', '<C-A>', '<C-\\><C-O>g0',       { noremap = true, silent = true })
keymap('i', '<C-E>', '<C-\\><C-O>g$',       { noremap = true, silent = true })
keymap('i', '<C-K>', '<C-\\><C-O>D',        { noremap = true, silent = true })
keymap('i', '<C-F>', [[col('.') >= col('$') ? "<C-\><C-O>+" : g:const_dir_r]],     { noremap = true, silent = true, expr = true })
keymap('i', '<C-B>', [[col('.') == 1 ? "<C-\><C-O>-<C-\><C-O>$" : g:const_dir_l]], { noremap = true, silent = true, expr = true })
keymap('i', '<M-d>', '<C-\\><C-O>dw', { noremap = true, silent = true })
for key, val in pairs({n='j', p='k'}) do
    keymap('n', '<C-'..key..'>', 'g'..val,            { noremap = true, silent = true })
    keymap('v', '<C-'..key..'>', 'g'..val,            { noremap = true, silent = true })
    keymap('i', '<C-'..key..'>', '<C-\\><C-O>g'..val, { noremap = true, silent = true })
end
-- Surround
keymap('n', '<leader>sa', '<Cmd>lua require("utility/srd").srd_add("n")<CR>',  { noremap = true, silent = true })
keymap('v', '<leader>sa', ':<C-U>lua require("utility/srd").srd_add("v")<CR>', { noremap = true, silent = true })
keymap('n', '<leader>sd', '<Cmd>lua require("utility/srd").srd_sub("")<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>sc', '<Cmd>lua require("utility/srd").srd_sub()<CR>',     { noremap = true, silent = true })
for key, val in pairs({P='`', I='*', B='**', M='***', U='<u>'}) do
    keymap('n', '<M-'..key..'>', '<Cmd>lua require("utility/srd").srd_add("n","'..val..'")<CR>',  { noremap = true, silent = true })
    keymap('v', '<M-'..key..'>', ':<C-U>lua require("utility/srd").srd_add("v","'..val..'")<CR>', { noremap = true, silent = true })
end
-- Comment
keymap("n", "<leader>la", '<Cmd>lua require("utility/cmt").cmt_add_norm()<CR>', { noremap = true, silent = true })
keymap("v", "<leader>la", ':<C-U>lua require("utility/cmt").cmt_add_vis()<CR>', { noremap = true, silent = true })
keymap("n", "<leader>ld", '<Cmd>lua require("utility/cmt").cmt_del_norm()<CR>', { noremap = true, silent = true })
keymap("v", "<leader>ld", ':<C-U>lua require("utility/cmt").cmt_del_vis()<CR>', { noremap = true, silent = true })
