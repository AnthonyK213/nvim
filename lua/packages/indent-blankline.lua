require("indent_blankline").setup {
    char = "▏",
    use_treesitter = true,
    space_char_blankline = " ",
    show_current_context = true,
    context_patterns = {
        'class',
        'function',
        'method',
        '^if',
        '^while',
        '^for',
        '^object',
        '^table',
        'block',
        'arguments',
    },
    buftype_exclude = {"terminal", 'NvimTree'},
    filetype_exclude = {"alpha", "markdown", "presenting_markdown"}
}
