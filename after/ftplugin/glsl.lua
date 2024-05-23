vim.bo.omnifunc = "v:lua.require('utility.glsl').omnifunc"

local has_cmp, cmp = pcall(require, "cmp")
if has_cmp then
  cmp.setup.buffer {
    formatting = {
      format = function(entry, vim_item)
        vim_item.menu = ({
          omni = "[GLSL]",
          buffer = "[Buffer]",
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = {
      { name = "omni" },
      { name = "buffer" },
      { name = "path" },
    },
  }
end

vim.keymap.set("n", "<leader>mt", require("utility.glsl").toggle)
vim.keymap.set("n", "<leader>mi", require("utility.glsl").input)
