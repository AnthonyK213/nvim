if vim.fn.has('win32') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$LOCALAPPDATA/nvim/snippet')
elseif vim.fn.has('unix') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$HOME/.config/nvim/snippet')
end

require('compe').setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 2,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
        nvim_lua = true,
        vsnip = true,
        calc = false,
    }
}


local keymap = vim.api.nvim_set_keymap
keymap('i', '<CR>',
[[compe#confirm("<Plug>(lua_pairs_enter)")]],
{ noremap = false, silent = true, expr = true })
keymap('i', '<ESC>',
[[compe#close("<C-[>")]],
{ noremap = true, silent = true, expr = true })
keymap('i', '<TAB>',
[[pumvisible() ? ]]..
[["<C-n>" : luaeval("require('utility/lib').get_context('b')") =~ '\v^\s*(\+|-|*|\d+\.)\s$' ? ]]..
[["<C-\><C-O>>>" . repeat(g:const_dir_r, &ts) : vsnip#jumpable(1) ? ]]..
[["<Plug>(vsnip-jump-next)" : luaeval("require('utility/lib').get_context('b')") =~ '\v(\w|\.|_|:)$' ? ]]..
[[compe#complete() : "<TAB>"]],
{ noremap = false, silent = true, expr = true })
keymap('s', '<TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
keymap('i', '<S-TAB>',
[[pumvisible() ? ]]..
[["<C-p>" : vsnip#jumpable(1) ? ]]..
[["<Plug>(vsnip-jump-prev)" : "<S-TAB>"]],
{ noremap = false, silent = true, expr = true })
keymap('s', '<S-TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-prev)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
