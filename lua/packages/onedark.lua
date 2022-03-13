vim.cmd('packadd onedark.nvim')

require('onedark').setup  {
    style = core_opt.tui.style,
    transparent = core_opt.tui.transparent,
    term_colors = true,
    ending_tildes = false,
    toggle_style_key = '<leader>bs',
    toggle_style_list = {
        'dark', 'darker', 'cool',
        'deep', 'warm', 'warmer',
        'light'
    },
    code_style = {
        comments = 'italic',
        keywords = 'none',
        functions = 'none',
        strings = 'none',
        variables = 'none'
    },
    colors = {},
    highlights = {
        FloatBorder = { fg = '$cyan' },
        SpellBad = { fg = '$red', fmt = 'underline' },
        SpellCap = { fg = '$yellow', fmt = 'underline' },
        markdownH1 =               { fg = '$red', fmt = 'bold' },
        markdownH2 =               { fg = '$red', fmt = 'bold' },
        markdownH3 =               { fg = '$red', fmt = 'bold' },
        markdownH4 =               { fg = '$red' },
        markdownH5 =               { fg = '$red' },
        markdownH6 =               { fg = '$red' },
        markdownHeadingDelimiter = { fg = '$red', fmt = 'bold' },
        markdownUrl =              { fg = '$blue' },
        markdownBold =             { fg = '$yellow', fmt = 'bold' },
        markdownCode =             { fg = '$green' },
        markdownItalic =           { fg = '$purple', fmt = 'italic' },
        markdownCodeDelimiter =    { fg = '$bg3' },
        markdownLinkText =         { fg = '$cyan', fmt = 'underline' },
        markdownTSEmphasis =       { fg = '$purple', fmt = 'italic' },
        markdownTSLiteral =        { fg = '$green' },
        markdownTSNone =           { fg = '$light_grey' },
        markdownTSPunctSpecial =   { fg = '$red' },
        markdownTSPunctDelimiter = { fg = '$bg3' },
        markdownTSStringEscape =   { fg = '$cyan', fmt = 'bold' },
        markdownTSStrong =         { fg = '$yellow', fmt = 'bold' },
        markdownTSTextReference =  { fg = '$cyan', fmt = 'underline' },
        markdownTSTitle =          { fg = '$red', fmt = 'bold' },
        markdownTSURI =            { fg = '$blue' },
    },
    diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
    },
}

require('onedark').load()
