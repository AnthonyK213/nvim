local float_opts = {
  border = _G._my_core_opt.tui.border,
  max_width = 80,
}

-- Attaches.
local function custom_attach(_, bufnr)
  local kbd = vim.keymap.set
  local kbd_opts = { noremap = true, silent = true, buffer = bufnr }
  local picker = require("snacks").picker

  kbd("n", "<F12>", picker.lsp_definitions, kbd_opts)
  kbd("n", "<F2>", vim.lsp.buf.rename, kbd_opts)
  kbd("n", "<S-F12>", picker.lsp_references, kbd_opts)
  kbd("n", "<F24>", picker.lsp_references, kbd_opts)
  kbd("n", "<C-F12>", picker.lsp_implementations, kbd_opts)
  kbd("n", "<F36>", picker.lsp_implementations, kbd_opts)

  kbd("n", "K", function() vim.lsp.buf.hover(float_opts) end, kbd_opts)
  kbd("n", "<leader>l0", vim.lsp.buf.document_symbol, kbd_opts)
  kbd("n", "<leader>la", vim.lsp.buf.code_action, kbd_opts)
  kbd("n", "<leader>ld", vim.lsp.buf.declaration, kbd_opts)
  kbd("n", "<leader>lf", vim.lsp.buf.definition, kbd_opts)
  kbd("n", "<leader>lh", vim.lsp.buf.signature_help, kbd_opts)
  kbd("n", "<leader>li", vim.lsp.buf.implementation, kbd_opts)
  kbd("n", "<leader>lm", function() vim.lsp.buf.format { async = false } end, kbd_opts)
  kbd("n", "<leader>ln", vim.lsp.buf.rename, kbd_opts)
  kbd("n", "<leader>lr", vim.lsp.buf.references, kbd_opts)
  kbd("n", "<leader>lt", vim.lsp.buf.type_definition, kbd_opts)
  kbd("n", "<leader>lw", vim.lsp.buf.workspace_symbol, kbd_opts)
  kbd("n", "<leader>lk", function() vim.diagnostic.open_float(float_opts) end, kbd_opts)
  kbd("n", "<leader>l[", function() vim.diagnostic.jump { count = -1, float = float_opts } end, kbd_opts)
  kbd("n", "<leader>l]", function() vim.diagnostic.jump { count = 1, float = float_opts } end, kbd_opts)
end

-- Modify or overwrite the config of a server.
local server_settings = {
  clangd = function(o, _)
    o.on_new_config = function(new_config, _)
      local status, cmake = pcall(require, "cmake-tools")
      if status then
        cmake.clangd_on_new_config(new_config)
      end
    end
  end,
}

---Setup servers.
---@param name string Name of the language server.
---@param config boolean|table<string, any> Server configuration from `nvimrc`.
local function setup_server(name, config)
  local config_table

  if type(config) == "boolean" then
    config_table = { load = config }
  elseif type(config) == "table" then
    config_table = config
  else
    return
  end

  ---@type vim.lsp.Config
  local cfg = {}

  cfg.on_attach = custom_attach

  -- Disable semantic tokens.
  if config_table.disable_semantic_tokens then
    cfg.on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
      custom_attach(client, bufnr)
    end
  end

  -- Merge custom LSP configurations.
  local option_settings
  if type(config_table.settings) == "table" then
    option_settings = config_table.settings
  end
  local server_setting = server_settings[name]
  if type(server_setting) == "function" then
    server_setting(cfg, option_settings)
  else
    local s = option_settings or server_setting
    if s then
      cfg.settings = s
    end
  end

  -- Configure the server.
  vim.lsp.config(name, cfg)

  -- Enable the server.
  if config_table.load then
    vim.lsp.enable(name)
  end
end

-- Setup servers.
for name, config in pairs(_G._my_core_opt.lsp or {}) do
  setup_server(name, config)
end

-- Diagnostics
vim.diagnostic.config {
  virtual_text     = true,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = false,
  float            = float_opts,
}
