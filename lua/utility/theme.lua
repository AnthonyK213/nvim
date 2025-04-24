local lib = require("utility.lib")

local M = {}

---@type uv.uv_timer_t?
local _bg_timer

---Determine if the background lock is active.
---@return boolean is_active
function M.bg_lock_is_active()
  if not _bg_timer or not _bg_timer:is_active() then
    return false
  end
  return true
end

---Set background according to the time.
function M.bg_lock_toggle()
  if _bg_timer then
    if _bg_timer:is_active() then
      _bg_timer:stop()
      vim.notify("theme-auto-switch: OFF")
    else
      _bg_timer:again()
      vim.notify("theme-auto-switch: ON")
    end
  else
    _bg_timer = vim.uv.new_timer()
    if not _bg_timer then
      lib.warn("Failed to create timer")
      return
    end
    _bg_timer:start(0, 600, vim.schedule_wrap(function()
      local hour = os.date("*t").hour
      local bg = (hour > 6 and hour < 18) and "light" or "dark"
      if vim.g._my_theme_switchable == true then
        if vim.o.bg ~= bg then vim.o.bg = bg end
      elseif vim.is_callable(vim.g._my_theme_switchable) then
        vim.g._my_theme_switchable(bg)
      else
        _bg_timer:stop()
      end
    end))
  end
end

return M
