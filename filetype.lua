vim.filetype.add {
    filename = {
        ["_nvimrc"] = "json",
        [".nvimrc"] = "json",
        ["Cargo.toml"] = function()
            return "toml", function(bufnr)
                require("cmp").setup.buffer { sources = { { name = "crates" } } }
                local crates = require("crates")
                local kbd = vim.keymap.set
                local _o = { noremap = true, silent = true, buffer = bufnr }
                kbd("n", "K", crates.show_popup, _o)
                kbd("n", "<leader>ct", crates.toggle, _o)
                kbd("n", "<leader>cr", crates.reload, _o)
                kbd("n", "<leader>cv", crates.show_versions_popup, _o)
                kbd("n", "<leader>cf", crates.show_features_popup, _o)
                kbd("n", "<leader>cd", crates.show_dependencies_popup, _o)
                kbd("n", "<leader>cu", crates.update_crate, _o)
                kbd("v", "<leader>cu", crates.update_crates, _o)
                kbd("n", "<leader>ca", crates.update_all_crates, _o)
                kbd("n", "<leader>cU", crates.upgrade_crate, _o)
                kbd("v", "<leader>cU", crates.upgrade_crates, _o)
                kbd("n", "<leader>cA", crates.upgrade_all_crates, _o)
                kbd("n", "<leader>cH", crates.open_homepage, _o)
                kbd("n", "<leader>cR", crates.open_repository, _o)
                kbd("n", "<leader>cD", crates.open_documentation, _o)
                kbd("n", "<leader>cC", crates.open_crates_io, _o)
                crates.show()
            end
        end
    },
    extension = {
        lua = function()
            return "lua", function(_)
                require("cmp").setup.buffer {
                    sources = {
                        {
                            name = "nvim_lsp",
                            entry_filter = function(entry, _)
                                return require("cmp.types").lsp
                                    .CompletionItemKind[entry:get_kind()] ~= "Text"
                            end
                        },
                        { name = "nvim_lua" },
                        { name = "luasnip" },
                        { name = "path" },
                        { name = "nvim_lsp_signature_help" },
                    },
                }
            end
        end,
        markdown = function()
            return "vimwiki.markdown", function(bufnr)
                require("utility.util").new_keymap("n", "<Tab>", function(fallback)
                    if require("utility.syn").Syntax.new():match("Weblink") then
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
                require("utility.util").new_keymap("n", "<CR>", function(fallback)
                    if vim.fn.foldclosed(".") >= 0
                        or require("utility.syn").Syntax.new():match("Header") then
                        vim.cmd.normal("za")
                    else
                        fallback()
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
            end
        end,
        urdf = "xml",
        yaml = function()
            return "yaml", function(bufnr)
                vim.bo[bufnr].textwidth = 0
                vim.wo.wrap = false
                vim.wo.linebreak = false
            end
        end,
    }
}
