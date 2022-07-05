vim.cmd[[packadd gruvbox.nvim]]


require("gruvbox").setup {
    undercurl = true,
    underline = true,
    bold = true,
    italic = false,
    inverse = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    contrast = "soft",
    overrides = {},
}

require("utility.util").hl_auto_update("gruvbox", {
    FloatBorder = { fg = "$cyan" },
    SpellBad = { fg = "$red", fmt = "underline" },
    SpellCap = { fg = "$yellow", fmt = "underline" },
    --#region Markdown
    markdownH1 =                  { fg = "$red", fmt = "bold" },
    markdownH2 =                  { fg = "$red", fmt = "bold" },
    markdownH3 =                  { fg = "$red", fmt = "bold" },
    markdownH4 =                  { fg = "$red" },
    markdownH5 =                  { fg = "$red" },
    markdownH6 =                  { fg = "$red" },
    markdownBold =                { fg = "$yellow", fmt = "bold" },
    markdownItalic =              { fg = "$purple", fmt = "italic" },
    markdownBoldItalic =          { fg = "$yellow", fmt = "bold,italic" },
    markdownCode =                { fg = "$green" },
    markdownUrl =                 { fg = "$blue" },
    markdownLinkText =            { fg = "$cyan", fmt = "underline" },
    markdownHeadingDelimiter =    { fg = "$red" },
    markdownBoldDelimiter =       { fg = "$bg3" },
    markdownItalicDelimiter =     { fg = "$bg3" },
    markdownBoldItalicDelimiter = { fg = "$bg3" },
    markdownCodeDelimiter =       { fg = "$bg3" },
    markdownLinkDelimiter =       { fg = "$bg3" },
    markdownLinkTextDelimiter =   { fg = "$bg3" },
    markdownTSEmphasis =          { fg = "$purple", fmt = "italic" },
    markdownTSLiteral =           { fg = "$green" },
    markdownTSNone =              { fg = "$light_grey" },
    markdownTSPunctSpecial =      { fg = "$red" },
    markdownTSPunctDelimiter =    { fg = "$bg3" },
    markdownTSStringEscape =      { fg = "$cyan", fmt = "bold" },
    markdownTSStrong =            { fg = "$yellow", fmt = "bold" },
    markdownTSTextReference =     { fg = "$cyan", fmt = "underline" },
    markdownTSTitle =             { fg = "$red", fmt = "bold" },
    markdownTSURI =               { fg = "$blue" },
    --#endregion
}, function ()
    return {
        red = vim.g.terminal_color_1,
        green = vim.g.terminal_color_2,
        yellow = vim.g.terminal_color_3,
        blue = vim.g.terminal_color_4,
        purple = vim.g.terminal_color_5,
        cyan = vim.g.terminal_color_6,
        light_grey = vim.g.terminal_color_7,
        bg3 = vim.g.terminal_color_8
    }
end)


vim.g._my_theme_switchable = true
vim.cmd[[colorscheme gruvbox]]
