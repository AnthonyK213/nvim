local lib = require("utility.lib")
local futures = require("futures")

local Process = futures.Process
local Task = futures.Task

local M = {}

---Get the directory stores the binaries.
---@param name string
---@return string
local function get_release_dir(name)
  return vim.fs.joinpath(vim.fn.stdpath("config"), "rust", name, "target/release")
end

---Get dynamic library path in this config.
---@param dylib_name string
---@return string?
function M.get_dylib_path(dylib_name)
  local dylib_ext = lib.get_dylib_ext()
  if not dylib_ext then
    lib.warn("Unsupported OS.")
    return
  end

  local dylib_dir = get_release_dir(dylib_name)
  local dylib_file = dylib_name .. dylib_ext
  local dylib_path = vim.fs.joinpath(dylib_dir, dylib_file)
  local stat = vim.uv.fs_stat(dylib_path)
  if not stat or stat.type ~= "file" then
    lib.warn(dylib_file .. "is not found.")
  end

  return dylib_path
end

---Get binary/executable file path in this config.
---@param bin_name string
---@return string
function M.get_bin_path(bin_name)
  local bin_dir = get_release_dir(bin_name)
  local bin_ext = lib.has_windows() and ".exe" or ""
  local bin_file = bin_name .. bin_ext
  local bin_path = vim.fs.joinpath(bin_dir, bin_file)
  local stat = vim.uv.fs_stat(bin_path)
  if not stat or stat.type ~= "file" then
    lib.warn(bin_file .. "is not found.")
  end

  return bin_path
end

---Find all crates in this configuration.
---@return table<string,{path:string}> crates
function M.find_crates()
  local crates = {}
  local crates_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "rust")

  for _name, _type in vim.fs.dir(crates_dir) do
    if _type == "directory" and not vim.startswith(_name, "_") then
      local dir = vim.fs.joinpath(crates_dir, _name)
      crates[_name] = {
        path = dir
      }
    end
  end

  return crates
end

---Build crates in this configuration.
---@param crates table<string,{path:string}>
function M.build_crates(crates)
  if not lib.executable("cargo", true) then
    return
  end

  if not crates or vim.tbl_isempty(crates) then
    lib.warn("No crates to build")
    return
  end

  local build_tasks = {}

  for crate_name, crate_info in pairs(crates) do
    local task = futures.async(function()
      local code
      code = Process.new("cargo", {
        args = { "update" },
        cwd = crate_info.path,
      }):await()
      if code ~= 0 then
        lib.warn(crate_name .. ": Could not update the dependencies")
        return
      end
      code = Process.new("cargo", {
        args = { "build", "--release" },
        cwd = crate_info.path,
      }):await()
      if code ~= 0 then
        lib.warn(crate_name .. ": Failed to build the crate")
        return
      end
      vim.notify(crate_name .. ": Done")
    end)
    table.insert(build_tasks, task)
  end

  if vim.tbl_isempty(build_tasks) then
    vim.notify("No crates to build")
    return
  end

  futures.spawn(function()
    vim.notify("Building...")
    local handles = vim.tbl_map(function(task)
      return futures.spawn(task())
    end, build_tasks)
    for _, handle in ipairs(handles) do
      handle:await()
    end
    Task.delay(1000):await()
    vim.notify("Done")
  end)
end

return M
