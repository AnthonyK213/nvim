require("cmp").setup.buffer {
    sources = {
        { name = "crates" },
    },
}

local crates = require("crates")
local kbd = vim.keymap.set
local _o = { noremap = true, silent = true }
kbd('n', '<leader>ct', crates.toggle, _o)
kbd('n', '<leader>cr', crates.reload, _o)
kbd('n', '<leader>cv', crates.show_versions_popup, _o)
kbd('n', '<leader>cf', crates.show_features_popup, _o)
kbd('n', '<leader>cd', crates.show_dependencies_popup, _o)
kbd('n', '<leader>cu', crates.update_crate, _o)
kbd('v', '<leader>cu', crates.update_crates, _o)
kbd('n', '<leader>ca', crates.update_all_crates, _o)
kbd('n', '<leader>cU', crates.upgrade_crate, _o)
kbd('v', '<leader>cU', crates.upgrade_crates, _o)
kbd('n', '<leader>cA', crates.upgrade_all_crates, _o)
kbd('n', '<leader>cH', crates.open_homepage, _o)
kbd('n', '<leader>cR', crates.open_repository, _o)
kbd('n', '<leader>cD', crates.open_documentation, _o)
kbd('n', '<leader>cC', crates.open_crates_io, _o)
