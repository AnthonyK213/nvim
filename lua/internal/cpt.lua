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
