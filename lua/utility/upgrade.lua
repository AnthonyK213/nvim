local lib = require("utility.lib")
local futures = require("futures")

local Process = futures.Process
local Task = futures.Task

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

  if os_type == lib.OS.Windows then
    return "nvim-win64.zip"
  elseif os_type == lib.OS.Linux then
    return "nvim-linux-x86_64.tar.gz"
  elseif os_type == lib.OS.MacOS then
    vim.notify("Maybe using a package manager is better...")
    return
  else
    lib.warn("Unsupported OS")
    return
  end
end

---
---@param install_dir string
---@return string
local function get_bak_dir(install_dir)
  return vim.fs.joinpath(install_dir, "nvim_bak")
end

---
---@param install_dir string
---@return string
local function get_bak_name(install_dir)
  local version = vim.version()
  return string.format(
    "%s_%d.%d.%d_%s_%s",
    vim.fs.basename(install_dir),
    version.major,
    version.minor,
    version.patch,
    os.date("%y%m%d%H%M%S"),
    version.prerelease and "_dev" or "")
end

---
---@param nvim_dir string
---@param bak_dir string
---@param bak_name string
---@return boolean
local function nvim_back_up(nvim_dir, bak_dir, bak_name)
  -- TODO
  -- - Check directories;
  -- - Make bak_dir if not exist;
  -- - Copy nvim_dir to bak_dir/bak_name.
  return false
end

---Upgrade neovim.
---@param channel? "stable"|"nightly" Upgrade channel.
function M.upgrade(channel)
  channel = get_channel(channel)
  if not channel then
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

  local install_dir = vim.fs.dirname(nvim_dir)
  if not install_dir then
    return
  end

  local bak_dir = get_bak_dir(install_dir)
  local bak_name = get_bak_name(install_dir)
  if not nvim_back_up(nvim_dir, bak_dir, bak_name) then
    return
  end

  if lib.get_os_type() == lib.OS.Windows then
    -- TODO: Use PS script.
    return
  end

  -- TODO: Use curl and tar.

  futures.spawn(function()

  end)
end

---Upgrade neovim.
---Depends on `plenary.nvim`
---@param channel? string Upgrade channel, "stable" or "nightly".
function M.nvim_upgrade(channel)
  local proxy = _my_core_opt.dep.proxy or os.getenv("HTTP_PROXY")
  local version = vim.version()

  if not channel or channel:len() == 0 then
    channel = version.prerelease and "nightly" or "stable"
  elseif channel ~= "stable" and channel ~= "nightly" then
    lib.warn("Invalid neovim release channel.")
    return
  end

  local Path = require("plenary.path")
  local archive
  local os_type = lib.get_os_type()
  if os_type == lib.OS.Windows then
    archive = "nvim-win64.zip"
  elseif os_type == lib.OS.Linux then
    archive = "nvim-linux-x86_64.tar.gz"
  else
    return
  end

  local nvim_path = Path:new(vim.uv.exepath()):parent():parent()
  local bin_path = nvim_path:parent()
  local archive_path = bin_path:joinpath(archive)
  local backup_path = bin_path:joinpath("nvim_bak")
  local source = "https://github.com/neovim/neovim/releases/download/"
      .. channel .. "/" .. archive

  if not backup_path:exists() then backup_path:mkdir() end

  if nvim_path:exists() then
    local name = string.format("%s_%d.%d.%d%s", os.date("%y%m%d%H%M%S"),
      version.major, version.minor, version.patch,
      version.prerelease and "_dev" or "")
    nvim_path:copy {
      recursive = true,
      override = true,
      destination = backup_path:joinpath(name).filename
    }
  end

  local use_proxy = type(proxy) == "string"

  local dl_exec, dl_args, ex_exec, ex_args
  if os_type == lib.OS.Windows then
    local dl_cmd = "Invoke-WebRequest"
        .. " -Uri " .. source
        .. " -OutFile " .. archive_path.filename
    if use_proxy then dl_cmd = dl_cmd .. " -Proxy " .. proxy end
    local rm_cmd = "Remove-Item"
        .. " -Path " .. nvim_path.filename
        .. " -Recurse"
    local ex_cmd = "Expand-Archive"
        .. " -Path " .. archive_path.filename
        .. " -DestinationPath " .. bin_path.filename
    local rn_cmd = "Rename-Item"
        .. " -Path " .. bin_path:joinpath("nvim-win64").filename
        .. " -NewName " .. nvim_path.filename
    local cl_cmd = "Remove-Item"
        .. " -Path " .. archive_path.filename
    local pwsh_cmd = table.concat({
      dl_cmd, rm_cmd, ex_cmd, rn_cmd, cl_cmd
    }, ";")

    vim.fn.jobstart("powershell.exe -c " .. pwsh_cmd, { detach = true })
    vim.cmd.quitall { bang = true }
    return
  elseif os_type == lib.OS.Linux then
    if not lib.executable("curl", true) then return end
    dl_exec = "curl"
    dl_args = use_proxy and {
      "-L", source,
      "-o", archive_path.filename,
      "-x", proxy
    } or {
      "-L", source,
      "-o", archive_path.filename,
    }
    ex_exec = "tar"
    ex_args = {
      "-xf", archive_path.filename,
      "-C", bin_path.filename
    }
  else
    lib.warn("Unsupported operating system.")
    return
  end

  local download = Process.new(dl_exec, { args = dl_args })
  local extract = Process.new(ex_exec, { args = ex_args })

  futures.spawn(function()
    vim.notify("Downloading...")
    if download:await() ~= 0 then
      download:notify_err()
      return
    end
    vim.notify("Package downloaded. Installing...")
    if extract:await() ~= 0 then
      extract:notify_err()
      return
    end
    nvim_path:rm { recursive = true }
    bin_path:joinpath(archive:match("^(.-)%..+$")):rename {
      new_name = nvim_path.filename
    }
    archive_path:rm()
    Task.delay(1000):await()
    vim.notify("Neovim has been upgraded to " .. channel .. " channel.")
  end)
end

return M
