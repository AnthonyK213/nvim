local has_cmp, cmp = pcall(require, "cmp")
if has_cmp then
  cmp.setup.buffer {
    formatting = {
      format = function(entry, vim_item)
        vim_item.menu = ({
          omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
          buffer = "[Buffer]",
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = {
      { name = "luasnip" },
      { name = "omni" },
      { name = "buffer" },
      { name = "path" },
    },
  }
end

local _opt = { noremap = true, silent = true, buffer = true }

require("utility.util").set_srd_shortcuts({
  ["<M-I>"] = { { "\\textit{", "}" }, [[\vtexStyle(Ital|Both)]] },
  ["<M-B>"] = { { "\\textbf{", "}" }, [[\vtexStyleBo(ld|th)]] },
  ["<M-M>"] = { { "\\textrm{", "}" }, [[\vtex(StyleArgConc|MathTextConcArg)]] },
}, _opt)
vim.keymap.set("n", "<leader>mv", "<Cmd>VimtexTocToggle<CR>", _opt)
vim.keymap.set("n", "<leader>mt", function()
  local pdf_path = ((vim.b.vimtex and vim.b.vimtex.base)
    and vim.fn.fnamemodify(vim.b.vimtex.tex, ":r")
    or vim.fn.expand("%:p:r")) .. ".pdf"
  if not require("utility.lib").path_exists(pdf_path) then
    local futures = require("futures")
    futures.spawn(function()
      if futures.ui.input {
            prompt = "Compile the project? y/n: "
          } ~= "y" then
        return
      end
      local opt = futures.ui.select({ "none", "biber", "bibtex" }, {
        prompt = "Compile option: "
      })
      if not opt then return end
      local recipe = require("utility.run").get_recipe(opt == "none" and "" or opt)
      if recipe and recipe() then
        require("utility.util").sys_open(pdf_path)
      end
    end)
  else
    require("utility.util").sys_open(pdf_path)
  end
end, _opt)
