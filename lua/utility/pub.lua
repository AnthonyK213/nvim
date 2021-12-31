local M = {}
local core_opt = require('core.opt')


if vim.fn.has("win32") == 1 then
    M.start = {'cmd', '/c', 'start', '""'}
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


--[[Boxes
┌─┐┍━┑┎─┒┏━┓╭─╮╒═╕╓─╖╔═╗
│ ││ │┃ ┃┃ ┃│ ││ │║ ║║ ║
└─┘┕━┙┖─┚┗━┛╰─╯╘═╛╙─╜╚═╝
]]


return M
