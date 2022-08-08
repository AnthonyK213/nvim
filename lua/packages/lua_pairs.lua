require("lua-pairs").setup {
    ret = false,
    bak = true,
    spc = true,
    extd = {
        ["$"]   = "$",
        ["`"]   = "`",
        ["*"]   = "*",
        ["**"]  = "**",
        ["***"] = "***",
        ["<u>"] = "</u>"
    },
    extd_map = {
        ["<M-P>"] = "`",
        ["<M-I>"] = "*",
        ["<M-B>"] = "**",
        ["<M-M>"] = "***",
        ["<M-U>"] = "<u>"
    },
    exclude = {
        --buftype = { "prompt" },
        filetype = { "DressingInput" },
    },
}
