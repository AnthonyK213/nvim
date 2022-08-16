vim.cmd [[packadd onedark.nvim]]


local style_list = {
    "dark", "darker", "cool",
    "deep", "warm", "warmer",
    "light"
}
local opt_style = _my_core_opt.tui.style

require("onedark").setup  {
    style = vim.tbl_contains(style_list, opt_style) and opt_style or "dark",
    transparent = _my_core_opt.tui.transparent,
    term_colors = true,
    ending_tildes = false,
    toggle_style_key = "<leader>bs",
    toggle_style_list = style_list,
    code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none"
    },
    colors = {},
    highlights = {
        FloatBorder = { fg = "$cyan" },
        SpellBad = { fg = "$red", fmt = "underline" },
        SpellCap = { fg = "$yellow", fmt = "underline" },
        Underlined = { sp = "$cyan", fmt = "underline" },
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
        markdownUrl =                 { fg = "$bg3" },
        markdownEscape =              { fg = "$cyan" },
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
        markdownTSURI =               { fg = "$bg3" },
        --#endregion
    },
    diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
    },
}


vim.g._my_theme_switchable = true
require("onedark").load()
