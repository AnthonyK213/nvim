local M = {}
local lib = require('utility/lib')
local core_opt = require('core/opt')


if vim.fn.has("win32") == 1 then
    M.start = 'start'
    M.shell = lib.get_var(core_opt.sh, 'powershell.exe -nologo')
    M.ccomp = lib.get_var(core_opt.cc, 'gcc')
elseif vim.fn.has("unix") == 1 then
    M.start = 'xdg-open'
    M.shell = lib.get_var(core_opt.sh, 'bash')
    M.ccomp = lib.get_var(core_opt.cc, 'gcc')
elseif vim.fn.has("mac") == 1 then
    M.start = 'open'
    M.shell = lib.get_var(core_opt.sh, 'zsh')
    M.ccomp = lib.get_var(core_opt.cc, 'clang')
end

M.esc_url = {
    [" "]  = "\\%20", ["!"]  = "\\%21", ['"']  = "\\%22",
    ["#"]  = "\\%23", ["$"]  = "\\%24", ["%"]  = "\\%25",
    ["&"]  = "\\%26", ["'"]  = "\\%27", ["("]  = "\\%28",
    [")"]  = "\\%29", ["*"]  = "\\%2A", ["+"]  = "\\%2B",
    [","]  = "\\%2C", ["/"]  = "\\%2F", [":"]  = "\\%3A",
    [";"]  = "\\%3B", ["<"]  = "\\%3C", ["="]  = "\\%3D",
    [">"]  = "\\%3E", ["?"]  = "\\%3F", ["@"]  = "\\%40",
    ["\\"] = "\\%5C", ["|"]  = "\\%7C", ["\n"] = "\\%20",
    ["\r"] = "\\%20", ["\t"] = "\\%20"
}


return M
