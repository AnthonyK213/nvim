vim.cmd[[packadd nightfox.nvim]]


require('nightfox').setup { }


local style_list = { "night", "day", "dawn", "dusk", "nord", "tera" }
local opt_style = _my_core_opt.tui.style
local style = vim.tbl_contains(style_list, opt_style) and opt_style or "night"
vim.cmd([[colorscheme ]]..style..[[fox]])
