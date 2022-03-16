local M = {}


if vim.fn.has("win32") == 1 then
    M.start = {'cmd', '/c', 'start', '""'}
    M.shell = _my_core_opt.dep.sh or { 'powershell.exe', '-nologo' }
    M.ccomp = _my_core_opt.dep.cc or 'gcc'
elseif vim.fn.has("unix") == 1 then
    M.start = 'xdg-open'
    M.shell = _my_core_opt.dep.sh or 'bash'
    M.ccomp = _my_core_opt.dep.cc or 'gcc'
elseif vim.fn.has("mac") == 1 then
    M.start = 'open'
    M.shell = _my_core_opt.dep.sh or 'zsh'
    M.ccomp = _my_core_opt.dep.cc or 'clang'
end


--[[Boxes
┌─┐┍━┑┎─┒┏━┓╭─╮╒═╕╓─╖╔═╗
│ ││ │┃ ┃┃ ┃│ ││ │║ ║║ ║
└─┘┕━┙┖─┚┗━┛╰─╯╘═╛╙─╜╚═╝
]]


return M
