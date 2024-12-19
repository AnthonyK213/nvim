local lib = require("utility.lib")

local M = {}

---@enum date.DayOfWeek
local DayOfWeek = {
  Monday    = 1,
  Tuesday   = 2,
  Wednesday = 3,
  Thursday  = 4,
  Friday    = 5,
  Saturday  = 6,
  Sunday    = 7,
}

M.DayOfWeek = lib.make_readonly(DayOfWeek)

-- Get the day of week from a date (yyyy-mm-dd).
---@param year integer Year.
---@param month integer Month.
---@param date integer Date.
---@return date.DayOfWeek? result The day of week.
function M.get_day_of_week_from_date(year, month, date)
  if (month < 1 or month > 12) then
    lib.warn("Not a valid month.")
    return
  end

  local month_days_count
  if (month == 2) then
    month_days_count = 28
    if ((year % 100 ~= 0 and year % 4 == 0) or year % 400 == 0) then
      month_days_count = month_days_count + 1
    end
  else
    month_days_count = 30
    if (month <= 7 and month % 2 == 1)
        or (month >= 8 and month % 2 == 0) then
      month_days_count = month_days_count + 1
    end
  end

  if (date < 1 or date > month_days_count) then
    lib.warn("Not a valid date.")
    return
  end

  if (month == 1 or month == 2) then
    year = year - 1
    month = month + 12
  end

  local c = math.floor(year / 100)
  local y = year - c * 100
  local x = math.floor(c / 4) + y + math.floor(y / 4) +
      math.floor(13 * (month + 1) / 5) + date - 2 * c - 1
  local z = x % 7
  if (z <= 0) then z = z + 7 end

  return z
end

return M
