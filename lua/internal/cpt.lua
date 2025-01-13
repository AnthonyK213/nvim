local min_supported_version = "0.10.0"

---WORKAROUND: [#28782](https://github.com/neovim/neovim/issues/28782)
if not vim.version or vim.version.lt({
      vim.version().major,
      vim.version().minor,
      vim.version().patch,
    }, min_supported_version) then
  vim.notify("The minimum supported version is " .. min_supported_version .. ", time to upgrade!",
    vim.log.levels.ERROR)
end

---WORKAROUND: [#31675](https://github.com/neovim/neovim/issues/31675)
if vim.version and vim.version.eq(vim.version(), { 0, 10, 3 }) then
  vim.hl = vim.highlight
end

local function report_legacy()
  vim.notify_once("The current version may have some deprecated features, time to upgrade!",
    vim.log.levels.WARN)
end

if not vim.uv then
  vim.uv = vim.loop
  report_legacy()
end

if not vim.list_contains then
  vim.list_contains = vim.tbl_contains
  report_legacy()
end

if not vim.islist then
  vim.islist = vim.tbl_islist
  report_legacy()
end

if not vim.lsp.get_clients then
  vim.lsp.get_clients = vim.lsp.get_active_clients
  report_legacy()
end

local M = {}

---Set color scheme.
---@param fallback? fun(cs: string):boolean Fall back function.
---@return boolean load_3rd_ui
function M.set_color_scheme(fallback)
  vim.o.tgc = true
  vim.o.bg = _my_core_opt.tui.theme or "dark"
  vim.g._my_theme_switchable = false

  local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC
  local load_3rd_ui = nvim_init_src ~= "neatUI"
  if nvim_init_src == "nano" then
    _my_core_opt.tui.scheme = "nanovim"
    load_3rd_ui = false
  end

  if _my_core_opt.tui.scheme == "nanovim" then
    vim.g._my_theme_switchable = true
    vim.g.nano_transparent = _my_core_opt.tui.transparent and 1 or 0
    vim.cmd.colorscheme("nanovim")
  elseif fallback and fallback(_my_core_opt.tui.scheme) then
  else
    pcall(vim.cmd.colorscheme, _my_core_opt.tui.scheme)
  end

  return load_3rd_ui
end

return M
