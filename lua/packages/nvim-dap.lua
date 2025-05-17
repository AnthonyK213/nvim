local dap = require("dap")
local dap_option = _G._my_core_opt.dap or {}
local lib = require("utility.lib")
local dir = vim.fn.stdpath("data") .. "/mason"

--#region Adapter
---@class my.dap.Adaptor
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
---@return my.dap.Adaptor
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

--#endregion

--#region Adapter instances
-- TODO: Using codelldb
local dap_codelldb = A.new({ "c", "cpp", "rust" }, "lldb", {
  type = "executable",
  command = "lldb-dap",
  name = "lldb",
}, {
  {
    name = "Launch",
    type = "lldb",
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

local dap_netcoredbg = A.new("cs", "coreclr", {
  type = "executable",
  command = lib.has_windows()
      and string.format("%s/packages/netcoredbg/netcoredbg/netcoredbg", dir)
      or "netcoredbg",
  args = { "--interpreter=vscode" }
}, {
  {
    name = "Launch",
    type = "coreclr",
    request = "launch",
    program = function()
      return vim.fn.input {
        prompt = "Path to dll: ",
        default = vim.uv.cwd() .. "/bin/Debug/",
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

local dap_debugpy = A.new("python", "python", lib.has_windows() and {
  type = "executable",
  command = string.format("%s/packages/debugpy/venv/Scripts/python", dir),
  args = { "-m", "debugpy.adapter" }
} or {
  type = "executable",
  command = "debugpy-adapter",
}, {
  {
    type = "python",
    name = "Launch",
    request = "launch",
    program = "${file}",
    pythonPath = function()
      return vim.fn.exepath(_G._my_core_opt.dep.py)
    end,
  }
})

if dap_option.codelldb then dap_codelldb:setup() end
if dap_option.coreclr then dap_netcoredbg:setup() end
if dap_option.python then dap_debugpy:setup() end

-- dap.set_log_level("TRACE")
--#endregion
