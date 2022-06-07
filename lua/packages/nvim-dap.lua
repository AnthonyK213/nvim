local dap = require("dap")
local dap_option = _my_core_opt.dap or {}
local lib = require("utility.lib")
local Process = require("utility.proc")
local dir = vim.fn.stdpath("data").."/dap_adapters"
if not lib.path_exists(dir) then vim.loop.fs_mkdir(dir, 448) end

--#region Adapter
---@class A
---@field typename string
---@field filetype string
---@field option table
---@field configuration table
---@field installer function
local A = {}

A.__index = A

---Constructor.
---@param filetype string|string[]
---@param typename string
---@param option table
---@param configuration table[]
---@param installer function?
---@return A
function A.new(filetype, typename, option, configuration, installer)
    local o = {
        filetype = filetype,
        typename = typename,
        option = option,
        configuration = configuration,
        installer = installer
    }
    setmetatable(o, A)
    return o
end

---Initialize the adapter.
function A:init()
    if vim.fn.executable(self.option.command) == 1 then
        dap.adapters[self.typename] = self.option
        for _, config in ipairs(self.configuration) do
            config.type = self.typename
        end
        dap.configurations[self.filetype] = self.configuration
    else
        if self.installer then self.installer(self) end
    end
end
--#endregion

--#region Adapter instances
local dap_python = A.new("python", "python", {
    type = "executable",
    command = dir.."/debugpy/bin/python",
    args = { "-m", "debugpy.adapter" }
}, {
    {
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            local cwd = vim.loop.cwd()
            if vim.fn.executable(cwd.."/venv/bin/python") == 1 then
                return cwd..'/venv/bin/python'
            elseif vim.fn.executable(cwd.."/.venv/bin/python") == 1 then
                return cwd.."/.venv/bin/python"
            else
                return _my_core_opt.dep.py3
            end
        end,
    }
}, vim.schedule_wrap(function (a)
    local new_venv = Process.new("python", {
        args = { "-m", "venv", dir.."/debugpy" }
    })
    local install = Process.new(a.option.command, {
        args = { "-m", "pip", "install", "debugpy" },
        cwd = dir.."/debugpy/bin/"
    }, function (_, code, _)
        if code == 0 then
            vim.notify("Installed debugpy")
        end
    end)
    new_venv:continue_with(install)
    new_venv:start()
end))

local dap_csharp = A.new("csharp", "coreclr", {
    type = "executable",
    command = dir.."netcoredbg/netcoredbg",
    args = { "--interpreter=vscode" }
}, {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to dll: ", vim.loop.cwd().."/bin/Debug/", "file")
        end,
    },
})

if dap_option.python then dap_python:init() end
if dap_option.csharp then dap_csharp:init() end
--#endregion

--#region Key mappings
local kbd = vim.keymap.set
local ntst = { noremap = true, silent = true }
kbd('n', '<F5>', function () dap.continue() end, ntst)
kbd('n', '<F6>', function () dap.step_over() end, ntst)
kbd('n', '<F7>', function () dap.step_into() end, ntst)
kbd('n', '<F8>', function () dap.step_out() end, ntst)
kbd('n', '<leader>db', function () dap.toggle_breakpoint() end, ntst)
kbd('n', '<leader>dc', function () dap.clear_breakpoints() end, ntst)
kbd('n', '<leader>dl', function () dap.run_last() end, ntst)
kbd('n', '<leader>dr', function () dap.repl.toggle() end, ntst)
kbd('n', '<leader>dt', function () dap.terminate() end, ntst)
--#endregion
