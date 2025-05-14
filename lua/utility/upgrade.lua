local lib = require("utility.lib")
local rsmod = require("utility.rsmod")
local futures = require("futures")

local Process = futures.Process

local augroup = vim.api.nvim_create_augroup("my.utility.upgrade", {
  clear = true
})

local source_table = {
  Windows = {
    x64 = "nvim-win64.zip",
  },
  Linux = {
    arm64 = "nvim-linux-arm64.tar.gz",
    x64   = "nvim-linux-x86_64.tar.gz",
  },
  OSX = {
    arm64 = "nvim-macos-arm64.tar.gz",
    x64   = "nvim-macos-x86_64.tar.gz",
  },
}

---@enum upgrade.Status
local Status = {
  Idle = 0,
  Busy = 1,
  Done = 2,
}

local CURL_CMD = "curl"

local M = {}

local _status = Status.Idle

local function idle()
  _status = Status.Idle
end

local function busy()
  _status = Status.Busy
end

local function done()
  _status = Status.Done
end

---Parses the input channel.
---If the input is empty or `nil`, returns the current channel.
---If the input is invalid, returns `nil`.
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

---Fetches the latest version of `channel`.
---@async
---@param channel "stable"|"nightly"
---@param proxy? string
---@return vim.Version?
local function fetch_version(channel, proxy)
  if not lib.executable(CURL_CMD, true) then
    return
  end

  local args = { "-L", "https://github.com/neovim/neovim/releases/tag/" .. channel }
  if proxy then
    table.insert(args, "-x")
    table.insert(args, proxy)
  end

  local target = [[content="NVIM ]]
  local version = nil

  local fetch_tag_page = Process.new(CURL_CMD, { args = args })
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

  -- fetch_tag_page.record = true
  if fetch_tag_page:await() ~= 0 then
    fetch_tag_page:notify_err()
    return
  end

  return version
end

---Checks whether Neovim could be upgarde.
---If the input `channel` is different from current channel, just "upgrade" with
---no hesitation :)
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

  local the_same_channel = (ver_local.prerelease ~= nil) == (ver_fetch.prerelease ~= nil)
  if the_same_channel and vim.version.ge(ver_local, ver_fetch) then
    lib.warn("Nvim is up to date")
    return
  end

  return ver_fetch
end

---Returns install directory of Neovim.
---@return string?
local function get_nvim_dir()
  return vim.fs.dirname(vim.fs.dirname(vim.uv.exepath()))
end

---Returns http proxy from environment variable.
---@return string?
local function get_proxy()
  return _G._my_core_opt.general.proxy or os.getenv("HTTP_PROXY")
end

---Returns the pre-built binary archive name.
---@return string?
local function get_source_name()
  if jit.os == "OSX" then
    lib.warn("Maybe using a package manager is better...")
    return
  end

  local source_name = vim.tbl_get(source_table, jit.os, jit.arch)
  if not source_name then
    lib.warn("No pre-built binaries available")
    return
  end

  return source_name
end

---Returns name of the backup direcroty.
---@param nvim_dir_name string
---@return string
local function get_bak_name(nvim_dir_name)
  local version = vim.version()
  return string.format(
    "%s_%d.%d.%d_%s%s",
    nvim_dir_name,
    version.major,
    version.minor,
    version.patch,
    os.date("%y%m%d%H%M%S"),
    version.prerelease and "_dev" or "")
end

---Downloads the pre-built binary archive.
---@async
---@param source_url string
---@param download_path string
---@param proxy? string
---@return boolean
local function download(source_url, download_path, proxy)
  local args = {
    "-L", source_url,
    "-o", download_path,
  }

  if proxy then
    table.insert(args, "--proxy")
    table.insert(args, proxy)
  end

  local download_proc = Process.new(CURL_CMD, { args = args })

  if download_proc:await() ~= 0 then
    download_proc:notify_err()
    return false
  end

  -- TODO: Checksum

  return true
end

---Upgrade neovim.
---@param channel? "stable"|"nightly" Upgrade channel.
function M.nvim_upgrade(channel)
  if _status == Status.Busy then
    lib.warn("Upgrade in process.")
    return
  elseif _status == Status.Done then
    lib.warn("Pending... Close Neovim to upgrade.")
    return
  end

  busy()

  channel = get_channel(channel)
  if not channel then
    idle()
    return
  end

  local source_name = get_source_name()
  if not source_name then
    idle()
    return
  end

  local upgrader = rsmod.get_bin_path("nvim-upgrade")
  if not upgrader then
    idle()
    return
  end

  local proxy = get_proxy()

  futures.spawn(function()
    local new_ver = check_update(channel, proxy)
    if not new_ver then
      idle()
      return
    end

    local yes_no = futures.ui.input {
      prompt = "Upgrade to " .. tostring(new_ver) .. "? [Y/n] "
    }
    if not yes_no or yes_no:lower() ~= "y" then
      lib.warn("Canceled")
      idle()
      return
    end

    local source_url = "https://github.com/neovim/neovim/releases/download/"
        .. channel .. "/" .. source_name

    local nvim_dir = get_nvim_dir()
    if not nvim_dir then
      idle()
      return
    end

    local nvim_dir_name = vim.fs.basename(nvim_dir)

    local install_dir = vim.fs.dirname(nvim_dir)
    if not install_dir then
      idle()
      return
    end

    local backup_dir = vim.fs.joinpath(install_dir, ".nvim_tmp")
    local backup_name = get_bak_name(nvim_dir_name)
    local download_path = vim.fs.joinpath(backup_dir, source_name)

    if vim.fn.isdirectory(backup_dir) == 0 then
      local err, ok = futures.uv.fs_mkdir(backup_dir, 448)
      if not ok then
        lib.warn(err)
        idle()
        return
      end
    end

    vim.notify("Downloading...")

    if not download(source_url, download_path, proxy) then
      idle()
      return
    end

    vim.api.nvim_create_autocmd("VimLeave", {
      group = augroup,
      callback = function()
        local cmd = {
          upgrader,
          "--install-dir", install_dir,
          "--nvim-dir-name", nvim_dir_name,
          "--backup-dir", backup_dir,
          "--backup-name", backup_name,
          "--source-name", source_name,
        }
        vim.fn.jobstart(cmd, { detach = true })
      end
    })

    vim.notify("Downloaded. Close Neovim to install.")

    done()
  end)
end

return M
