vim.cmd[[packadd nightfox.nvim]]


require('nightfox').setup {
    options = {
        compile_path = vim.fn.stdpath("data").."/nightfox",
        compile_file_suffix = "_compiled",
        transparent = _my_core_opt.tui.transparent,
        styles = {
            comments = "italic"
        }
    },
    groups = {
        markdownBoldDelimiter =       { fg = 'bg3' },
        markdownItalicDelimiter =     { fg = 'bg3' },
        markdownBoldItalicDelimiter = { fg = 'bg3' },
        markdownCodeDelimiter =       { fg = 'bg3' },
        markdownLinkDelimiter =       { fg = 'bg3' },
        markdownLinkTextDelimiter =   { fg = 'bg3' },
        markdownTSNone =              { fg = 'fg3' },
        markdownTSPunctDelimiter =    { fg = 'bg3' }
    }
}


local style_list = { "night", "day", "dawn", "dusk", "nord", "tera" }
local opt_style = _my_core_opt.tui.style
local style = vim.tbl_contains(style_list, opt_style) and opt_style or "night"
vim.cmd([[colorscheme ]]..style..[[fox]])
