require("lua_pairs").setup {
    extd = {
        markdown = {
            { k = "<M-P>", l = "`", r = "`" },
            { k = "<M-I>", l = "*", r = "*" },
            { k = "<M-B>", l = "**", r = "**" },
            { k = "<M-M>", l = "***", r = "***" },
            { k = "<M-U>", l = "<u>", r = "</u>" },
        },
        tex = {
            { k = "<M-B>", l = "\\textbf{", r = "}" },
            { k = "<M-I>", l = "\\textit{", r = "}" },
        },
    },
    exclude = {
        filetype = { "DressingInput" },
    },
}
