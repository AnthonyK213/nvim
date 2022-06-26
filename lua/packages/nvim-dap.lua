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

---Setup the adapter.
function A:setup()
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
    command = dir.."/debugpy/"..(lib.has_windows() and "Scripts/" or "bin/").."python",
    args = { "-m", "debugpy.adapter" }
}, {
    {
        name = "Launch",
        request = "launch",
        program = "${file}",
        pythonPath = function() return _my_core_opt.dep.py3 end,
    }
}, vim.schedule_wrap(function (a)
    local new_venv = Process.new("python", {
        args = { "-m", "venv", dir.."/debugpy" }
    })
    local pip_args = { "-m", "pip", "install", "debugpy" }
    if _my_core_opt.dep.proxy then
        vim.tbl_extend("keep", pip_args, { "--proxy", _my_core_opt.dep.proxy })
    end
    local install = Process.new(a.option.command, {
        args = pip_args
    }, function (_, code, _)
        if code == 0 then
            vim.notify("Installed debugpy")
        end
    end)
    new_venv:continue_with(install)
    new_venv:start()
end))

local dap_csharp = A.new("cs", "coreclr", {
    type = "executable",
    command = dir.."/netcoredbg/netcoredbg",
    args = { "--interpreter=vscode" }
}, {
    {
        name = "Launch",
        type = "coreclr",
        request = "launch",
        program = function()
            return vim.fn.input {
                prompt = "Path to dll: ",
                default = vim.loop.cwd().."/bin/Debug/",
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
}, vim.schedule_wrap(function ()
    local archive, archive_path, extract
    local extract_cb = function (_, code, _)
        if code == 0 then
            vim.loop.fs_unlink(archive_path)
            vim.notify("Installed netcoredbg")
        end
    end
    if lib.has_windows() then
        archive = "netcoredbg-win64.zip"
        archive_path = dir.."/"..archive
        extract = Process.new("powershell", {
            args = { "-c", "Expand-Archive -Path "..archive_path.." -DestinationPath "..dir }
        }, extract_cb)
    elseif vim.fn.has("unix") == 1 then
        archive = "netcoredbg-linux-amd64.tar.gz"
        archive_path = dir.."/"..archive
        extract = Process.new("tar", {
            args = { "-xf", archive_path, "-C", dir }
        }, extract_cb)
    else
        return
    end
    local source = "https://github.com/Samsung/netcoredbg/releases/latest/download/"..archive
    local curl_args = { "-L", source, "-o", archive_path }
    if _my_core_opt.dep.proxy then
        vim.tbl_extend("keep", curl_args, { "-x", _my_core_opt.dep.proxy })
    end
    local download = Process.new("curl", { args = curl_args })
    download:continue_with(extract)
    download:start()
end))

if dap_option.python then dap_python:setup() end
if dap_option.csharp then dap_csharp:setup() end
--#endregion

--#region Key mappings
local kbd = vim.keymap.set
local ntst = { noremap = true, silent = true }
kbd("n", "<F5>", function () dap.continue() end, ntst)
kbd("n", "<F6>", function () dap.step_over() end, ntst)
kbd("n", "<F7>", function () dap.step_into() end, ntst)
kbd("n", "<F8>", function () dap.step_out() end, ntst)
kbd("n", "<leader>db", function () dap.toggle_breakpoint() end, ntst)
kbd("n", "<leader>dc", function () dap.clear_breakpoints() end, ntst)
kbd("n", "<leader>dl", function () dap.run_last() end, ntst)
kbd("n", "<leader>dr", function () dap.repl.toggle() end, ntst)
kbd("n", "<leader>dt", function () dap.terminate() end, ntst)
--#endregion
