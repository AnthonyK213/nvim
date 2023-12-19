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
