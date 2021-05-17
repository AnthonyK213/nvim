local M = {}
local core_opt = require('core/opt')


if vim.fn.has("win32") == 1 then
    M.start = 'start'
    M.shell = core_opt.dep.sh or 'powershell.exe -nologo'
    M.ccomp = core_opt.dep.cc or 'gcc'
elseif vim.fn.has("unix") == 1 then
    M.start = 'xdg-open'
    M.shell = core_opt.dep.sh or 'bash'
    M.ccomp = core_opt.dep.cc or 'gcc'
elseif vim.fn.has("mac") == 1 then
    M.start = 'open'
    M.shell = core_opt.dep.sh or 'zsh'
    M.ccomp = core_opt.dep.cc or 'clang'
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
