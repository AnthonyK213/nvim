local lib = require("utility.lib")

local M = {}

local _interval = 5000

---@type uv.uv_timer_t?
local _bg_timer

---Get theme according to the time.
---@return string
local function get_theme()
  local hour = os.date("*t").hour
  return (hour > 6 and hour < 18) and "light" or "dark"
end

local function set_theme_by_opt()
  local bg = get_theme()
  if vim.o.bg ~= bg then
    vim.o.bg = bg
  end
end

local function set_theme_by_cb()
  local bg = get_theme()
  vim.g._my_theme_switchable(bg)
end

local function get_timer_cb()
    if vim.g._my_theme_switchable == true then
      return vim.schedule_wrap(set_theme_by_opt)
    elseif vim.is_callable(vim.g._my_theme_switchable) then
      return vim.schedule_wrap(set_theme_by_cb)
    else
      return nil
    end
end

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
      get_timer_cb()()
      _bg_timer:again()
      vim.notify("theme-auto-switch: ON")
    end
  else
    local cb = get_timer_cb()
    if not cb then
      return
    end

    _bg_timer = vim.uv.new_timer()
    if not _bg_timer then
      lib.warn("Failed to create timer")
      return
    end

    _bg_timer:start(0, _interval, vim.schedule_wrap(cb))
    vim.notify("theme-auto-switch: ON")
  end
end

return M
