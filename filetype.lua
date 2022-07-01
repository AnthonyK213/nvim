vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0
vim.filetype.add {
    filename = {
        ["_nvimrc"] = "json",
        [".nvimrc"] = "json"
    },
    extension = {
        lua = function ()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.softtabstop = 4
            return "lua"
        end,
        markdown = function (_, bufnr)
            vim.keymap.set("n", "<Tab>", "za", {
                noremap = true,
                silent = true,
                buffer = bufnr
            })
            vim.keymap.set("n", "<S-Tab>", "zA", {
                noremap = true,
                silent = true,
                buffer = bufnr
            })
            require("utility.util").new_keymap("n", "<CR>", function (fallback)
                if vim.fn.foldclosed(".") >= 0 then
                    vim.cmd[[normal! za]]
                else
                    fallback()
                end
            end, {
                noremap = true,
                silent = true,
                buffer = bufnr
            })
            return "vimwiki.markdown"
        end,
        rs = function ()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.softtabstop = 4
            return "rust"
        end,
        yaml = function ()
            vim.bo.textwidth = 0
            vim.wo.wrap = false
            vim.wo.linebreak = false
            return "yaml"
        end
    }
}
