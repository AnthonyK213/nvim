local lib = require("utility.lib")

---Registers filetypes for the pasers.
---@param parser_table table<string, string|string[]>
local function register_parsers(parser_table)
  for parser, filetypes in pairs(parser_table) do
    vim.treesitter.language.register(parser, filetypes)
  end
end

---Installs the parsers that not installed yet.
---Hope function `install` won't output anything when nothing to install thus
---no need to check installed parsers in this function.
---@param parsers string[]
---@return boolean
local function install_parsers(parsers)
  if not lib.executable("tree-sitter") then
    return false
  end

  local installed = require("nvim-treesitter.config").installed_parsers()

  local to_install = {}
  for _, parser in ipairs(parsers) do
    if not vim.list_contains(installed, parser) then
      table.insert(to_install, parser)
    end
  end

  if #to_install > 0 then
    require("nvim-treesitter").install(to_install)
  end

  return true
end

---Enables parsers for corresponding filetypes.
---@param parsers string[]
local function enable_parsers(parsers)
  local ft_list = {}
  for _, parser in ipairs(parsers) do
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
end

-- Setup treesitter.
local ts_option = _G._my_core_opt.ts or {}
---@type string[]
local ensure_installed = ts_option.ensure_installed or {}

if install_parsers(ensure_installed) then
  register_parsers {
    powershell = { "ps1" },
    -- markdown   = { "vimwiki.markdown" },
  }
  enable_parsers(ensure_installed)
else
  -- TODO: Download tree-sitter cli and add it to path if not found.
  lib.warn("tree-sitter cli was not found")
end
