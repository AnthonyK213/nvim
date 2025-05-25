local ts_option = _G._my_core_opt.ts or {}
---@type string[]
local ensure_installed = ts_option.ensure_installed or {}

-- Register filetypes for pasers.
vim.treesitter.language.register("powershell", { "ps1" })
-- vim.treesitter.language.register("markdown", { "vimwiki.markdown" })

-- Install parsers.
local installed = require("nvim-treesitter.config").installed_parsers()

local to_install = {}
for _, parser in ipairs(ensure_installed) do
  if not vim.list_contains(installed, parser) then
    table.insert(to_install, parser)
  end
end

if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end

-- Enable treesitter for filetypes.
local ft_list = {}
for _, parser in ipairs(ensure_installed) do
  local langs = vim.treesitter.language.get_filetypes(parser)
  for _, lang in ipairs(langs) do
    table.insert(ft_list, lang)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = ft_list,
  callback = function()
    vim.treesitter.start()
    vim.wo.foldexpr = [[v:lua.vim.treesitter.foldexpr()]]
    vim.bo.indentexpr = [[v:lua.require("nvim-treesitter").indentexpr()]]
  end
})
