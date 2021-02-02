local keymap = vim.api.nvim_set_keymap


-- Windows shit.
keymap('n', '<C-S>', ':w<CR>',       { noremap = true, silent = true })
keymap('i', '<C-S>', '<C-O>:w<CR>',  { noremap = true, silent = true })
keymap('v', '<M-c>', '"+y',          { noremap = true, silent = true })
keymap('v', '<M-x>', '"+x',          { noremap = true, silent = true })
keymap('n', '<M-v>', '"+p',          { noremap = true, silent = true })
keymap('v', '<M-v>', '"+p',          { noremap = true, silent = true })
keymap('i', '<M-v>', '<C-R>=@+<CR>', { noremap = true, silent = true })
keymap('n', '<M-a>', 'ggVG',         { noremap = true, silent = true })
-- Search visual selection.
keymap('v', '*', [[<ESC>/\V<C-r>=luaeval('require("utility/lib").get_visual_selection()')<CR><CR>]], { noremap = true, silent = true })
-- Mouse toggle.
keymap('n', '<F2>', '<cmd>lua require("utility/util").mouse_toggle()<CR>',            { noremap = true, silent = true })
keymap('v', '<F2>', ':<C-U>lua require("utility/util").mouse_toggle()<CR>',           { noremap = true, silent = true })
keymap('i', '<F2>', '<C-O><cmd>lua require("utility/util").mouse_toggle()<CR>',       { noremap = true, silent = true })
keymap('t', '<F2>', '<C-\\><C-N><cmd>lua require("utility/util").mouse_toggle()<CR>', { noremap = true, silent = true })
-- Background toggle.
keymap('n', '<leader>bg', '<cmd>lua require("utility/util").bg_toggle()<CR>',    { noremap = true, silent = true })
-- Explorer.
keymap('n', '<leader>oe', '<cmd>lua require("utility/util").open_file(".")<CR>', { noremap = true, silent = true })
-- Terminal.
keymap('n', '<leader>ot', '<cmd>lua require("utility/util").terminal()<CR>i',    { noremap = true, silent = true })
-- Open with system default browser.
keymap('n', '<leader>ob', '<cmd>lua require("utility/util").open_file(vim.fn.expand("%:p"))<CR>', { noremap = true, silent = true })
-- Hanzi count.
keymap('n', '<leader>cc', '<cmd>lua require("utility/util").hanzi_count("n")<CR>',  { noremap = true, silent = true })
keymap('v', '<leader>cc', ':<C-u>lua require("utility/util").hanzi_count("v")<CR>', { noremap = true, silent = true })
-- Append day of week after the date.
keymap('n', '<leader>dd', ':lua require("utility/util").append_day_from_date()<CR>', { noremap = true, silent = true })
-- Insert an orgmode-style timestamp at the end of the line.
keymap('n', '<leader>ds', "A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>", { noremap = true, silent = true })
-- List bullets.
keymap('i', '<M-CR>', '<C-o>:lua require("utility/util").md_insert_bullet()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>ml', ':lua require("utility/util").md_sort_num_bullet()<CR>', { noremap = true, silent = true })
-- Echo git status.
keymap('n', '<leader>vs', ':!git status<CR>', { noremap = true, silent = true })
-- Search cword in web browser.
for key,_ in pairs(require('utility/util').web_list) do
    keymap('n', '<leader>k'..key, '<cmd>lua require("utility/util").search_web("n", "'..key..'")<CR>',  { noremap = true, silent = true })
    keymap('v', '<leader>k'..key, ':<C-U>lua require("utility/util").search_web("v", "'..key..'")<CR>', { noremap = true, silent = true })
end
-- Emacs shit.
keymap('n', '<M-x>', ':',             { noremap = true })
keymap('i', '<M-x>', '<C-O>:',        { noremap = true })
keymap('i', '<M-b>', '<C-O>b',        { noremap = true, silent = true })
keymap('i', '<M-f>', '<C-O>e<Right>', { noremap = true, silent = true })
keymap('i', '<C-SPACE>', '<C-O>v',    { noremap = true, silent = true })
keymap('i', '<C-A>', '<C-O>g0',       { noremap = true, silent = true })
keymap('i', '<C-E>', '<C-O>g$',       { noremap = true, silent = true })
keymap('i', '<C-K>', '<C-\\><C-O>D',  { noremap = true, silent = true })
keymap('i', '<C-F>', [[col('.') >= col('$') ? "\<C-o>+" : g:const_dir_r]], { noremap = true, silent = true, expr = true })
keymap('i', '<C-B>', [[col('.') == 1 ? "\<C-o>-\<C-o>$" : g:const_dir_l]], { noremap = true, silent = true, expr = true })
keymap('i', '<M-d>', '<C-\\><C-O>dw', { noremap = true, silent = true })
for key,val in pairs({n='j', p='k'}) do
    keymap('n', '<C-'..key..'>', 'g'..val,      { noremap = true, silent = true })
    keymap('v', '<C-'..key..'>', 'g'..val,      { noremap = true, silent = true })
    keymap('i', '<C-'..key..'>', '<C-O>g'..val, { noremap = true, silent = true })
end
-- Surround
keymap('n', '<leader>sa', '<cmd>lua require("utility/util").sur_add("n")<CR>',  { noremap = true, silent = true })
keymap('v', '<leader>sa', ':<C-U>lua require("utility/util").sur_add("v")<CR>', { noremap = true, silent = true })
keymap('n', '<leader>sd', '<cmd>lua require("utility/util").sur_sub("")<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>sc', '<cmd>lua require("utility/util").sur_sub()<CR>',     { noremap = true, silent = true })
for key,val in pairs({P='`', I='*', B='**', M='***', U='<u>'}) do
    keymap('n', '<M-'..key..'>', '<cmd>lua require("utility/util").sur_add("n","'..val..'")<CR>',  { noremap = true, silent = true })
    keymap('v', '<M-'..key..'>', ':<C-U>lua require("utility/util").sur_add("v","'..val..'")<CR>', { noremap = true, silent = true })
end
