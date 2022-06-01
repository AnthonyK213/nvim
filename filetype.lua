vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0
vim.filetype.add {
    filename = {
        ["_nvimrc"] = "json",
        [".nvimrc"] = "json"
    }
}
