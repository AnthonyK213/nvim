if _my_core_opt.vcs.client == "neogit" then
    require("neogit").setup {
        integrations = {
            diffview = true
        }
    }

    local kbd = vim.keymap.set
    local _o = { noremap = true, silent = true }
    kbd("n", "<leader>gn", require("neogit").open, _o)
end
