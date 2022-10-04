vim.filetype.add {
    filename = {
        ["_nvimrc"] = "json",
        [".nvimrc"] = "json"
    },
    extension = {
        lua = function ()
            return "lua", function (bufnr)
                vim.bo[bufnr].tabstop = 4
                vim.bo[bufnr].shiftwidth = 4
                vim.bo[bufnr].softtabstop = 4
            end
        end,
        markdown = function ()
            return "vimwiki.markdown", function (bufnr)
                require("utility.util").new_keymap("n", "<Tab>", function (fallback)
                    if require("utility.syn").match_here("Weblink") then
                        fallback()
                    elseif vim.fn.foldlevel(".") > 0 then
                        vim.cmd.normal("za")
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
                vim.keymap.set("n", "<S-Tab>", "zA", {
                    noremap = true,
                    silent = true,
                    buffer = bufnr
                })
                require("utility.util").new_keymap("n", "<CR>", function (fallback)
                    if vim.fn.foldclosed(".") >= 0
                        or require("utility.syn").match_here("Header") then
                        vim.cmd.normal("za")
                    else
                        fallback()
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
            end
        end,
        rs = function ()
            return "rust", function (bufnr)
                vim.bo[bufnr].tabstop = 4
                vim.bo[bufnr].shiftwidth = 4
                vim.bo[bufnr].softtabstop = 4
            end
        end,
        urdf = "xml",
        yaml = function ()
            return "yaml", function (bufnr)
                vim.bo[bufnr].textwidth = 0
                vim.wo.wrap = false
                vim.wo.linebreak = false
            end
        end,
    }
}
