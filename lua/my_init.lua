require("internal")

if _G._my_core_opt.general.offline then
  require("utility.lib").vim_source("viml/subsrc")
  require("internal.tui").set_color_scheme()
else
  require("packages")
end
