local dap = require("dap")
local lib = require("utility.lib")
local dir = vim.fn.stdpath("data").."/dap_adapters/"

if not lib.path_exists(dir) then vim.loop.fs_mkdir(dir, 448) end


dap.adapters.python = {
    type = "executable",
    command = dir.."debugpy/bin/python",
    args = { '-m', 'debugpy.adapter' }
}

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd..'/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd..'/.venv/bin/python'
            else
                return '/usr/bin/python'
            end
        end,
    },
}

dap.adapters.coreclr = {
    type = "executable",
    command = dir.."netcoredbg/netcoredbg",
    args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd().."/bin/Debug/", "file")
        end,
    },
}


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
