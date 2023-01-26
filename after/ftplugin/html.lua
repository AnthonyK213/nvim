local _opt = { noremap = true, silent = true, buffer = true }

require("utility.util").set_srd_shortcuts({
    ["<M-I>"] = { "<i>", [[\v(Italic|text\.emphasis)]] },
    ["<M-B>"] = { "<b>", [[\v(Bold|text\.strong)]] },
    ["<M-M>"] = { "<i><b>", [[\v(BoldItalic|ItalicBold|text\.(strong|emphasis))]] },
    ["<M-U>"] = { "<u>", [[\v(text\.)?[Uu]nderline]] },
}, _opt)
