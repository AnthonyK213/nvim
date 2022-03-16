local lib = require('utility.lib')

vim.keymap.set('i', '/', function ()
    if lib.get_context('b'):match('^%s*//$') then
        local keys = '/ <summary>\n\n</summary><Up> '
        local term_rep = vim.api.nvim_replace_termcodes(keys, true, false, true)
        vim.api.nvim_feedkeys(term_rep, 'n', true)
    else
        vim.api.nvim_feedkeys('/', 'n', true)
    end
end, { noremap = true, silent = true, buffer = true })
