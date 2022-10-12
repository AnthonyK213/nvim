local Terminal = require("toggleterm.terminal").Terminal

local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }

if _my_core_opt.vcs.client == "lazygit" then
    kbd("n", "<leader>gn", function()
        if not require("utility.lib").executable("lazygit") then return end
        Terminal:new {
            cmd = "lazygit",
            hidden = true,
            direction = "float",
            float_opts = {
                border = _my_core_opt.tui.border,
            },
        }:toggle()
    end, _o)
end
