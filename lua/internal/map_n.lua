local kbd = vim.keymap.set

local nt = { noremap = true }
local ntst = { noremap = true, silent = true }
local ntstet = { noremap = true, silent = true, expr = true }


-- Open opt file.
kbd('n', '<M-,>', vim.fn['usr#misc#open_opt'], ntst)
-- Explorer.
kbd('n', '<leader>oe', function ()
    require('utility.util').sys_open(vim.fn.expand('%:p:h'))
end, ntst)
-- Terminal
kbd('n', '<leader>ot', function ()
    require('utility.util').terminal()
end, ntst)
-- Open file of current buffer with system default browser.
