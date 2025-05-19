local dap = require("dap")
local lib = require("utility.lib")
local mason_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason")

---@class my.dap.Adapter
---@field typename string
---@field filetype string|string[]
---@field option table
---@field configuration table
local A = {}

A.__index = A

---Constructor.
---@param filetype string|string[]
---@param typename string
---@param option table
---@param configuration table[]
---@return my.dap.Adapter
function A.new(filetype, typename, option, configuration)
  local o = {
    filetype = filetype,
    typename = typename,
    option = option,
    configuration = configuration,
  }
  setmetatable(o, A)
  return o
end

---Setup the adapter.
function A:setup()
  dap.adapters[self.typename] = self.option
  for _, config in ipairs(self.configuration) do
    config.type = self.typename
  end
  local ft = self.filetype
  if type(ft) == "string" then
    dap.configurations[ft] = self.configuration
  elseif type(ft) == "table" then
    for _, t in ipairs(ft) do
      dap.configurations[t] = self.configuration
    end
  end
end

---@type table<string, my.dap.Adapter>
local adapters = {}

adapters.codelldb = A.new({ "c", "cpp", "rust" }, "codelldb", {
  type = "executable",
  command = vim.fs.joinpath(mason_dir, "packages/codelldb/extension/adapter/codelldb"),
  name = "codelldb",
  detached = not lib.has_windows(),
}, {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input {
        prompt = "Path to executable: ",
        default = vim.uv.cwd() .. "/",
        completion = "file"
      }
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  }
})

local function get_netcoredbg_path()
  if lib.has_windows() then
    return vim.fs.joinpath(mason_dir, "packages/netcoredbg/netcoredbg/netcoredbg")
  else
    return vim.fs.joinpath(mason_dir, "bin/netcoredbg")
  end
end

adapters.coreclr = A.new("cs", "coreclr", {
  type = "executable",
  command = get_netcoredbg_path(),
  args = { "--interpreter=vscode" }
}, {
  {
    name = "Launch",
    type = "coreclr",
    request = "launch",
    program = function()
      return vim.fn.input {
        prompt = "Path to dll: ",
        default = vim.uv.cwd() .. "/",
        completion = "file"
      }
    end,
  },
  {
    name = "Attach",
    type = "coreclr",
    request = "attach",
    processId = require("dap.utils").pick_process,
    args = {}
  }
})

local function get_python_path()
  local dir = lib.has_windows() and "Scripts" or "bin"
  return vim.fs.joinpath(mason_dir, "packages/debugpy/venv", dir, "python")
end

adapters.python = A.new("python", "python", {
  type = "executable",
  command = get_python_path(),
  args = { "-m", "debugpy.adapter" }
}, {
  {
    type = "python",
    name = "Launch",
    request = "launch",
    program = "${file}",
    pythonPath = get_python_path,
  }
})

-- Setup adapters.
for type_, load in pairs(_G._my_core_opt.dap or {}) do
  local adapter = adapters[type_]
  if load and adapter then
    adapter:setup()
  end
end

-- Enable overseer integration.
require("overseer").enable_dap()
