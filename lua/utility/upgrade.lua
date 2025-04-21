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
---@return string?
local function nvim_backup(nvim_dir, bak_dir, bak_name)
  -- TODO
  -- - Check directories;
  -- - Make bak_dir if not exist;
  -- - Copy nvim_dir to bak_dir/bak_name.
  return vim.fs.joinpath(bak_dir, bak_name)
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

    local yes_no = futures.ui.input { prompt = "Upgrade to " .. tostring(new_ver) .. "? [Y/n] " }
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

    local install_dir = vim.fs.dirname(nvim_dir)
    if not install_dir then
      return
    end

    local download_path = vim.fs.joinpath(install_dir, source_name)

    local bak_dir = get_bak_dir(install_dir)
    local bak_name = get_bak_name(install_dir)
    local bak_path = nvim_backup(nvim_dir, bak_dir, bak_name)
    if not bak_path then
      return
    end

    if lib.get_os_type() == lib.OS.Windows then
      local dl_cmd = "Invoke-WebRequest"
          .. " -Uri " .. source_url
          .. " -OutFile " .. download_path
      if proxy then
        dl_cmd = dl_cmd .. " -Proxy " .. proxy
      end
      local rm_cmd = "Remove-Item"
          .. " -Path " .. nvim_dir
          .. " -Recurse"
      local ex_cmd = "Expand-Archive"
          .. " -Path " .. download_path
          .. " -DestinationPath " .. install_dir
      local rn_cmd = "Rename-Item"
          .. " -Path " .. vim.fs.joinpath(install_dir, "nvim-win64") -- TODO: use get_source_name
          .. " -NewName " .. nvim_dir
      local cl_cmd = "Remove-Item"
          .. " -Path " .. download_path
      local pwsh_cmd = table.concat({ dl_cmd, rm_cmd, ex_cmd, rn_cmd, cl_cmd }, ";")

      vim.fn.jobstart("powershell.exe -c " .. pwsh_cmd, { detach = true })
      vim.cmd.quitall { bang = true }
      return
    end

    -- Use curl and tar.

    local dl_exec = "curl"
    local dl_args = {
      "-L", source_url,
      "-o", download_path,
    }
    if proxy then
      table.insert(dl_args, "-x")
      table.insert(dl_args, proxy)
    end

    local ex_exec = "tar"
    local ex_args = {
      "-xf", download_path,
      "-C", install_dir, -- TODO: Extract with a certain name.
    }

    local dl_proc = Process.new(dl_exec, { args = dl_args })
    vim.notify("Downloading...")
    if dl_proc:await() ~= 0 then
      dl_proc:notify_err()
      return
    end

    local ex_proc = Process.new(ex_exec, { args = ex_args })
    vim.notify("Package downloaded. Installing...")
    if ex_proc:await() ~= 0 then
      ex_proc:notify_err()
      return
    end

    -- TODO
    -- - Remove old nvim directory (nvim_dir);
    -- - Rename extracted directory to nvim_dir;
    -- - Remove the archive downloaded.

    Task.delay(1000):await()
    vim.notify("Neovim has been upgraded to " .. channel .. " channel.")
  end)
end

return M
