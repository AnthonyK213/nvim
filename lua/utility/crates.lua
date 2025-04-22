local lib = require("utility.lib")
local futures = require("futures")

local Process = futures.Process
local Task = futures.Task

local M = {}

---Get the directory stores the dylibs.
---@return string
function M.get_dylib_dir()
  return vim.fn.stdpath("data") .. "/dylib/"
end

---Get dynamic library path in data/dylib/.
---@param dylib_name string
---@return string?
function M.get_dylib_path(dylib_name)
  local dylib_ext = lib.get_dylib_ext()
  if not dylib_ext then
    lib.warn("Unsupported OS.")
    return
  end
  local dylib_dir = M.get_dylib_dir()
  local dylib_file = dylib_name .. dylib_ext
  local dylib_path = vim.fs.joinpath(dylib_dir, dylib_file)
  if not lib.path_exists(dylib_path) then
    lib.warn(dylib_file .. " is not found.")
    return
  end
  return dylib_path
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

  local dylibs_dir = M.get_dylib_dir()
  local dylib_ext = lib.get_dylib_ext()
  local dylib_prefix = lib.has_windows() and "" or "lib"

  if not lib.path_exists(dylibs_dir) then
    if not vim.uv.fs_mkdir(dylibs_dir, 448) then
      lib.warn("Could not crate directory `dylib`.")
      return
    end
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
      local dylib_name = crate_name .. dylib_ext
      local path_from = vim.fs.joinpath(crate_info.path, "target/release/" .. dylib_prefix .. dylib_name)
      local path_to = vim.fs.joinpath(dylibs_dir, dylib_name)
      local err, success = futures.uv.fs_copyfile(path_from, path_to)
      if success then
        print(crate_name .. ": Done")
      else
        lib.warn(err)
      end
    end)
    table.insert(build_tasks, task)
  end

  if vim.tbl_isempty(build_tasks) then
    vim.notify("No crates to build")
    return
  end

  futures.spawn(function()
    print("Building...")
    local handles = vim.tbl_map(function(task)
      return futures.spawn(task())
    end, build_tasks)
    for _, handle in ipairs(handles) do
      handle:await()
    end
    Task.delay(1000):await()
    print("Done")
  end)
end

return M
