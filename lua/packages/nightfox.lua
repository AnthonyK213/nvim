vim.cmd[[packadd nightfox.nvim]]


require('nightfox').setup { }


local styles = { "night", "day", "dawn", "dusk", "nord", "tera" }
local opt_style = _my_core_opt.tui.style
local style = vim.tbl_contains(styles, opt_style) and opt_style or "night"
vim.cmd([[colorscheme ]]..style..[[fox]])
