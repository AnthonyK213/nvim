local lib = require("utility.lib")

local M = {}

local _min_intv = 3000
local _begin = 6
local _end = 18

---@type uv.uv_timer_t?
local _bg_timer

---
---@return boolean
local function is_day()
  local hour = os.date("*t").hour
  return hour >= _begin and hour < _end
end

---
---@param from_h integer 0-23
---@param from_m integer 0-59
---@param from_s integer 0-61
---@param to_h integer 0-23
---@param to_m integer 0-59
---@param to_s integer 0-61
---@return integer seconds
local function duration(from_h, from_m, from_s, to_h, to_m, to_s)
  if to_h < from_h then
    to_h = to_h + 24
  end
  return 3600 * (to_h - from_h) + 60 * (to_m - from_m) + (to_s - from_s)
end

---
---@return integer interval In milliseconds
local function get_interval()
  local date = os.date("*t")
  local to_h = is_day() and _end or _begin
  local dur = duration(date.hour, date.min, date.sec, to_h, 0, 0)
  return dur * 1000 + _min_intv
end

---Get theme according to the time.
---@return string
local function get_theme()
  return is_day() and "light" or "dark"
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
    return set_theme_by_opt
  elseif vim.is_callable(vim.g._my_theme_switchable) then
    return set_theme_by_cb
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
      _bg_timer:set_repeat(get_interval())
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

    _bg_timer:start(0, get_interval(), vim.schedule_wrap(function()
      cb()
      _bg_timer:set_repeat(get_interval())
      _bg_timer:again()
    end))
    vim.notify("theme-auto-switch: ON")
  end
end

return M
