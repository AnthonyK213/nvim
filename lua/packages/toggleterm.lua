local Terminal = require('toggleterm.terminal').Terminal

local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd("n", "<leader>gn", function()
    Terminal:new {
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
            border = _my_core_opt.tui.border,
        },
    }:toggle()
end, _o)
