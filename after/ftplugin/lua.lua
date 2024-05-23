local has_cmp, cmp = pcall(require, "cmp")
if has_cmp then
  cmp.setup.buffer {
    sources = {
      {
        name = "nvim_lsp",
        entry_filter = function(entry, _)
          return require("cmp.types").lsp
              .CompletionItemKind[entry:get_kind()] ~= "Text"
        end
      },
      { name = "luasnip" },
      { name = "path" },
      { name = "nvim_lsp_signature_help" },
    },
  }
end
