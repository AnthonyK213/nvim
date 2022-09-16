vim.cmd [[packadd indent-blankline.nvim]]

require("indent_blankline").setup {
    char = "▏",
    context_char = "▏",
    use_treesitter = true,
    space_char_blankline = " ",
    show_current_context = true,
    context_patterns = {
        "class",
        "function",
        "method",
        "^if",
        "^while",
        "^for",
        "^object",
        "^table",
        "block",
        "arguments",
    },
    buftype_exclude = { "help", "quickfix", "terminal" },
    filetype_exclude = {
        "aerial", "alpha",
        "markdown", "presenting_markdown",
        "vimwiki", "NvimTree", "mason"
    }
}
