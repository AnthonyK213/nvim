local date = require("utility.date")

local M = {}

---Append the day of week after a time stamp (yyyy-mm-dd).
function M.append_day_from_date()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local y, m, d, insert_pos
  for pos_s, date_, year, month, day, pos_e in line:gmatch("()((%d%d%d%d)%-(%d%d)%-(%d%d))()") do
    if pos_s <= col + 1
        and pos_e >= col + 1
        and date_ then
      y = tonumber(year)
      m = tonumber(month)
      d = tonumber(day)
      insert_pos = pos_e - 1
      break
    end
  end

  if not insert_pos then return end
  local day_of_week = date.get_day_of_week_from_date(y, m, d)
  if not day_of_week then return end
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], insert_pos - 1 })
  local day_of_week_list = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
  vim.paste({ " " .. day_of_week_list[day_of_week] }, -1)
end

---Count down to a timestamp.
---@param date_ string Timestamp(<YYYY-MM-DD A hh:mm>).
---@return string? result Countdown information.
local function countdown(date_)
  local now = os.time()
  local ts, year, month, day, hour, minute =
      date_:match("(<(%d+)%-(%d+)%-(%d+)%s.-(%d+):(%d+)>)")

  if not ts then return end

  local date_info = {
    year  = tonumber(year),
    month = tonumber(month),
    day   = tonumber(day),
    hour  = tonumber(hour or 0),
    min   = tonumber(minute or 0),
    sec   = 0
  }

  local ddl = os.time(date_info)
  local sub = (ddl - now) / 86400

  if sub > 0 then
    local days = math.floor(sub + 0.2)
    return days .. " day" .. (days > 1 and "s" or "") .. " left."
  else
    local days = math.ceil(-sub)
    return "Overdue " .. days .. " day" .. (days > 1 and "s" or "") .. "."
  end
end

---Print TODO list.
function M.print_todo_list()
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(content) do
    local todo, date_, item = line:match("(TODO(%b<>):%s+(.+))$")
    if todo and not line:match("%[X%]") then
      print(date_ == "<>" and item or item .. " -> " .. countdown(date_))
    end
  end
end

return M
