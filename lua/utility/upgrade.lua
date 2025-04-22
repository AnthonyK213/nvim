local lib = require("utility.lib")
local crates = require("utility.crates")
local futures = require("futures")

local Process = futures.Process

local M = {}

---
---@param channel? string
---@return string?
local function get_channel(channel)
  local version = vim.version()

  if not channel or channel:len() == 0 then
    return version.prerelease and "nightly" or "stable"
  elseif channel ~= "stable" and channel ~= "nightly" then
    lib.warn("Invalid neovim release channel.")
    return
  end

  return channel
end

---comment
---@async
---@param channel "stable"|"nightly"
---@param proxy? string
---@return vim.Version?
local function fetch_version(channel, proxy)
  local cmd = "curl"
  if not lib.executable(cmd, true) then
    return
  end

  local args = { "-L", "https://github.com/neovim/neovim/releases/tag/" .. channel }
  if proxy then
    table.insert(args, "-x")
    table.insert(args, proxy)
  end

  local target = [[content="NVIM ]]
  local version = nil

  local fetch_tag_page = Process.new("curl", { args = args })
  fetch_tag_page.on_stdout = function(data)
    if version then
      return
    end
    local _, e = data:find(target, 1, true)
    if not e then
      return
    end
    local ver_str = data:match("v([%d%l%+%-%.]+)\n", e)
    if not ver_str then
      return
    end
    version = vim.version.parse(ver_str)
  end
  fetch_tag_page:await()

  return version
end

---comment
---@async
---@param channel "stable"|"nightly"
---@param proxy? string
---@return vim.Version?
local function check_update(channel, proxy)
  local ver_local = vim.version()
  local ver_fetch = fetch_version(channel, proxy)

  if not ver_fetch then
    lib.warn("Failed to fetch version")
    return
  end

  if vim.version.ge(ver_local, ver_fetch) then
    lib.warn("Nvim is up to date")
    return
  end

  return ver_fetch
end

---
---@return string?
local function get_nvim_dir()
  return vim.fs.dirname(vim.fs.dirname(vim.uv.exepath()))
end

---
---@return string?
local function get_proxy()
  return _my_core_opt.dep.proxy or os.getenv("HTTP_PROXY")
end

---comment
---@return string?
local function get_source_name()
  local os_type = lib.get_os_type()

  -- TODO: Downlaod file depend on OS and Arch.

  if os_type == lib.OS.Windows then
    return "nvim-win64.zip"
  elseif os_type == lib.OS.Linux then
    return "nvim-linux-x86_64.tar.gz"
  elseif os_type == lib.OS.MacOS then
    lib.warn("Maybe using a package manager is better on macOS...")
    return
  else
    lib.warn("Unsupported OS")
    return
  end
end

---
---@param install_dir string
---@return string
local function get_bak_name(install_dir)
  local version = vim.version()
  return string.format(
    "%s_%d.%d.%d_%s%s",
    vim.fs.basename(install_dir),
    version.major,
    version.minor,
    version.patch,
    os.date("%y%m%d%H%M%S"),
    version.prerelease and "_dev" or "")
end

---Upgrade neovim.
---@param channel? "stable"|"nightly" Upgrade channel.
function M.nvim_upgrade(channel)
  channel = get_channel(channel)
  if not channel then
    return
  end

  local proxy = get_proxy()

  futures.spawn(function()
    local new_ver = check_update(channel, proxy)
    if not new_ver then
      return
    end

    local yes_no = futures.ui.input {
      prompt = "Upgrade to " .. tostring(new_ver) .. "? [Y/n] "
    }
    if not yes_no or yes_no:lower() ~= "y" then
      return
    end

    local source_name = get_source_name()
    if not source_name then
      return
    end

    local source_url = "https://github.com/neovim/neovim/releases/download/"
        .. channel .. "/" .. source_name

    local nvim_dir = get_nvim_dir()
    if not nvim_dir then
      return
    end

    local nvim_dir_name = vim.fs.basename(nvim_dir)

    local install_dir = vim.fs.dirname(nvim_dir)
    if not install_dir then
      return
    end

    local backup_name = get_bak_name(install_dir)

    local upgrader = crates.get_bin_path("nvim-upgrade")

    local cmd = {
      upgrader,
      "--install-dir", install_dir,
      "--nvim-dir-name", nvim_dir_name,
      "--backup-name", backup_name,
      "--source-url", source_url,
    }

    if proxy then
      table.insert(cmd, "--proxy")
      table.insert(cmd, proxy)
    end

    vim.fn.jobstart(cmd, { detach = true, term = true })
    -- vim.cmd.quitall { bang = true }
  end)
end

return M
