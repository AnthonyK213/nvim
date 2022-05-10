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
        all = {
            FloatBorder = { fg = 'palette.cyan' },
            SpellBad = { fg = 'palette.red', style = 'underline' },
            SpellCap = { fg = 'palette.yellow', style = 'underline' },
            --#region Markdown
            markdownH1 =                  { fg = 'palette.red', style = 'bold' },
            markdownH2 =                  { fg = 'palette.red', style = 'bold' },
            markdownH3 =                  { fg = 'palette.red', style = 'bold' },
            markdownH4 =                  { fg = 'palette.red' },
            markdownH5 =                  { fg = 'palette.red' },
            markdownH6 =                  { fg = 'palette.red' },
            markdownBold =                { fg = 'palette.yellow', style = 'bold' },
            markdownItalic =              { fg = 'palette.magenta', style = 'italic' },
            markdownBoldItalic =          { fg = 'palette.yellow', style = 'bold,italic' },
            markdownCode =                { fg = 'palette.green' },
            markdownUrl =                 { fg = 'palette.blue' },
            markdownLinkText =            { fg = 'palette.cyan', style = 'underline' },
            markdownHeadingDelimiter =    { fg = 'palette.red' },
            markdownBoldDelimiter =       { fg = 'bg3' },
            markdownItalicDelimiter =     { fg = 'bg3' },
            markdownBoldItalicDelimiter = { fg = 'bg3' },
            markdownCodeDelimiter =       { fg = 'bg3' },
            markdownLinkDelimiter =       { fg = 'bg3' },
            markdownLinkTextDelimiter =   { fg = 'bg3' },
            markdownTSEmphasis =          { fg = 'palette.magenta', style = 'italic' },
            markdownTSLiteral =           { fg = 'palette.green' },
            markdownTSNone =              { fg = 'fg3' },
            markdownTSPunctSpecial =      { fg = 'palette.red' },
            markdownTSPunctDelimiter =    { fg = 'bg3' },
            markdownTSStringEscape =      { fg = 'palette.cyan', style = 'bold' },
            markdownTSStrong =            { fg = 'palette.yellow', style = 'bold' },
            markdownTSTextReference =     { fg = 'palette.cyan', style = 'underline' },
            markdownTSTitle =             { fg = 'palette.red', style = 'bold' },
            markdownTSURI =               { fg = 'palette.blue' },
            --#endregion
        }
    }
}


local style_list = { "night", "day", "dawn", "dusk", "nord", "tera" }
local opt_style = _my_core_opt.tui.style
local style = vim.tbl_contains(style_list, opt_style) and opt_style or "night"
vim.cmd([[colorscheme ]]..style..[[fox]])
