-- Windows-like behaviors.
vim.api.nvim_set_keymap('n', '<C-S>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-S>', '<C-O>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-c>', '"+y',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-x>', '"+x',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-v>', '"+p',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<M-v>', '"+p',    { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-v>', '<C-R>=@+<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-a>', 'ggVG',   { noremap = true, silent = true })
-- Search visual selection.
vim.api.nvim_set_keymap(
    'v',
    '*',
    [[<ESC>/\V<C-r>=luaeval('require("utility/lib").get_visual_selection()')<CR><CR>]],
    { noremap = true, silent = true })
-- Mouse toggle.
vim.api.nvim_set_keymap(
    'n',
    '<F2>',
    '<cmd>lua require("utility/util").mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'v',
    '<F2>',
    ':<C-U>lua require("utility/util").mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<F2>',
    '<C-O><cmd>lua require("utility/util").mouse_toggle()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    't',
    '<F2>',
    '<C-\\><C-N><cmd>lua require("utility/util").mouse_toggle()<CR>',
    { noremap = true, silent = true })
-- Background toggle.
vim.api.nvim_set_keymap(
    'n',
    '<leader>bg',
    '<cmd>lua require("utility/util").bg_toggle()<CR>',
    { noremap = true, silent = true })
-- Explorer.
vim.api.nvim_set_keymap(
    'n',
    '<leader>oe',
    '<cmd>lua require("utility/util").open_file(".")<CR>',
    { noremap = true, silent = true })
-- Terminal.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ot',
    '<cmd>lua require("utility/util").terminal()<CR>i',
    { noremap = true, silent = true })
-- Open with system default browser.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ob',
    '<cmd>lua require("utility/util").open_file(vim.fn.expand("%:p"))<CR>',
    { noremap = true, silent = true })
-- Hanzi count.
vim.api.nvim_set_keymap(
    'n',
    '<leader>cc',
    '<cmd>lua require("utility/util").hanzi_count("n")<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'v',
    '<leader>cc',
    ':<C-u>lua require("utility/util").hanzi_count("v")<CR>',
    { noremap = true, silent = true })
-- Append day of week after the date.
vim.api.nvim_set_keymap(
    'n',
    '<leader>dd',
    ':lua require("utility/util").append_day_from_date()<CR>',
    { noremap = true, silent = true })
-- Insert an orgmode-style timestamp at the end of the line.
vim.api.nvim_set_keymap(
    'n',
    '<leader>ds',
    "A<C-R>=strftime(' <%Y-%m-%d %a %H:%M>')<CR><Esc>",
    { noremap = true, silent = true })
-- List bullets.
vim.api.nvim_set_keymap(
    'i',
    '<M-CR>',
    '<C-o>:lua require("utility/util").md_insert_bullet()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>ml',
    ':lua require("utility/util").md_sort_num_bullet()<CR>',
    { noremap = true, silent = true })
-- Echo git status.
vim.api.nvim_set_keymap(
    'n',
    '<leader>vs',
    ':!git status<CR>',
    { noremap = true, silent = true })
-- Search cword in web browser.
for key,_ in pairs(require('utility/util').web_list) do
    vim.api.nvim_set_keymap(
        'n',
        '<leader>k'..key,
        '<cmd>lua require("utility/util").search_web("n", "'..key..'")<CR>',
            { noremap = true, silent = true })
    vim.api.nvim_set_keymap(
        'v',
        '<leader>k'..key,
        ':<C-U>lua require("utility/util").search_web("v", "'..key..'")<CR>',
        { noremap = true, silent = true })
end
-- Emacs shit.
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
    [[col('.') >= col('$') ? "\<C-o>+" : g:const_dir_r]],
    { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-B>',
    [[col('.') == 1 ? "\<C-o>-\<C-o>$" : g:const_dir_l]],
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


-- NERDTree
vim.api.nvim_set_keymap(
    'n',
    '<leader>op',
    ':NERDTreeToggle<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<M-e>',
    ':NERDTreeFocus<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<M-e>',
    '<ESC>:NERDTreeFocus<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    't',
    '<M-e>',
    '<C-\\><C-n>:NERDTreeFocus<CR>',
    { noremap = true, silent = true })
-- signify
vim.api.nvim_set_keymap(
    'n',
    '<leader>vj',
    '<Plug>(signify-next-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vk',
    '<Plug>(signify-prev-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vJ',
    '9999<Plug>(signify-next-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vK',
    '9999<Plug>(signify-prev-hunk)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>vt',
    ':SignifyToggle<CR>',
    { noremap = true, silent = true })
-- vim-markdown
vim.api.nvim_set_keymap(
    'n',
    '<leader>mh',
    ':Toch<CR>:resize 15<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>mv',
    ':Tocv<CR>:vertical resize 50<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>mm',
    ':lua require("utility/util").vim_markdown_math_toggle()<CR>',
    { noremap = true, silent = true })
-- vim-table-mode
vim.api.nvim_set_keymap(
    'n',
    '<leader>ta',
    ':TableAddFormula<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>tc',
    ':TableEvalFormulaLine<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>tf',
    ':TableModeRealign<CR>',
    { noremap = true, silent = true })
-- UltiSnips
vim.g.UltiSnipsExpandTrigger       = "<C-C><C-S>"
vim.g.UltiSnipsJumpForwardTrigger  = "<C-C><C-L>"
vim.g.UltiSnipsJumpBackwardTrigger = "<C-C><C-H>"
-- completion-nvim
vim.api.nvim_set_keymap(
    'i',
    '<CR>',
    [[pumvisible() ? complete_info()["selected"] != "-1" ? ]]..
    [["<Plug>(completion_confirm_completion)" : "<C-E><CR>" : ]]..
    [["<Plug>(ipairs_enter)"]],
    { noremap = false, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<TAB>',
    [[luaeval("require('utility/lib').get_context('b')") =~ '\v^\s*(\+|-|*|\d+\.)\s$' ? ]]..
    [["<C-O>V>" . repeat(g:const_dir_r, &ts) : ]]..
    [["<Plug>(completion_smart_tab)"]],
    { noremap = false, silent = true, expr = true })
vim.api.nvim_set_keymap(
    'i',
    '<S-TAB>',
    '<Plug>(completion_smart_s_tab)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-C><C-J>',
    '<Plug>(completion_next_source)',
    { noremap = false, silent = true })
vim.api.nvim_set_keymap(
    'i',
    '<C-C><C-K>',
    '<Plug>(completion_prev_source)',
    { noremap = false, silent = true })
-- nvim-lspconfig
vim.api.nvim_set_keymap(
    'n',
    'K',
    '<cmd>lua require("utility/util").show_doc()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>g0',
    '<cmd>lua vim.lsp.buf.document_symbol()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>ga',
    '<cmd>lua vim.lsp.buf.code_action()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gd',
    '<cmd>lua vim.lsp.buf.declaration()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gf',
    '<cmd>lua vim.lsp.buf.definition()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gh',
    '<cmd>lua vim.lsp.buf.signature_help()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gi',
    '<cmd>lua vim.lsp.buf.implementation()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gr',
    '<cmd>lua vim.lsp.buf.references()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gt',
    '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>gw',
    '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>g[',
    '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap(
    'n',
    '<leader>g]',
    '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',
    { noremap = true, silent = true })
