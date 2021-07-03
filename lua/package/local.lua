local core_opt = require('core/opt')


-- Built-in plugins.
if core_opt.plug then
    if not core_opt.plug.matchit then vim.g.loaded_matchit = 1 end
    if not core_opt.plug.matchparen then vim.g.loaded_matchparen = 1 end
end


-- lua-pairs
require('lua-pairs').setup {
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
    }
}
