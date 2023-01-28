local Syntax = require("utility.syn")

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
            { k = "<M-N>", l = "\\textrm{", r = "}" },
        },
        rust = {
            {
                l = "<",
                r = ">",
                d = function(context)
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    col = col - #context.p
                    if col == 0 then return true end
                    return not Syntax.new(0, row, col):match {
                        vs = [[\v^rust(Identifier|Keyword|FuncName)$]],
                        ts = [[\v^(type|keyword|function)$]],
                    }
                end
            },
        }
    },
    exclude = {
        buftype = { "prompt" },
        filetype = { "DressingInput" },
    },
}
