local M = {
  enabled = true,
  width = 50,
  preset = {
    keys = {
      { icon = " ", key = "e", desc = "Empty File", action = ":enew" },
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = " ", key = "s", desc = "Load Session", action = ":SessionManager load_session" },
      { icon = " ", key = ",", desc = "Settings", action = ":call my#compat#open_nvimrc()" },
      { icon = "󰒲 ", key = "p", desc = "Packages", action = ":Lazy" },
      { icon = " ", key = "q", desc = "Quit Neovim", action = ":qa" },
    },
    header = _G._my_core_opt.tui.welcome_header,
  },
  sections = {
    { section = "header" },
    { section = "keys",  gap = 1, padding = 1 },
    -- { section = "startup" },
  },
}

if not _G._my_core_opt.tui.devicons then
  -- Disable icons.
  for _, key in ipairs(M.preset.keys) do
    key.icon = nil
  end
end

return M
