local ts_option = require("core/opt").ts or {}
require('nvim-treesitter.configs').setup {
    ensure_installed = ts_option.ensure or {},
    highlight = {
        enable = true,
        disable = ts_option.hi_disable or {}
    },
}
