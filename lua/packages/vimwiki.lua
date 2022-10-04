local lib = require("utility.lib")

vim.g.vimwiki_list = { {
    path = lib.path_append(_my_core_opt.path.cloud, "/Notes/"),
    path_html = lib.path_append(_my_core_opt.path.cloud, "/Notes/html/"),
    syntax = "markdown",
    ext = ".markdown"
} }
vim.g.vimwiki_folding = "syntax"
vim.g.vimwiki_filetypes = { "markdown" }
vim.g.vimwiki_ext2syntax = { [".markdown"] = "markdown" }
