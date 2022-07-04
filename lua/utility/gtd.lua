local M = {}
local api = vim.api
local lib = require("utility.lib")


-- Get the day of week from a date(yyyy-mm-dd).
---@param year integer Year.
---@param month integer Month.
---@param date integer Date.
---@return string|nil result The day of week.
local function zeller(year, month, date)
    if (month < 1 or month > 12) then
        lib.notify_err("Not a valid month.")
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
        lib.notify_err("Not a valid date.")
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
    local days_list = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}

    return days_list[z]
end

---Append the day of week after a time stamp(yyyy-mm-dd).
function M.append_day_from_date()
    local line = api.nvim_get_current_line()
    local col = api.nvim_win_get_cursor(0)[2]

    local y, m, d, insert_pos
    for pos_s, date, year, month, day, pos_e
        in line:gmatch("()((%d%d%d%d)%-(%d%d)%-(%d%d))()") do
        if pos_s <= col + 1
            and pos_e >= col + 1
            and date then
            y = tonumber(year)
            m = tonumber(month)
            d = tonumber(day)
            insert_pos = pos_e - 1
            break
        end
    end

    if not insert_pos then return end
    local day_of_week = zeller(y, m, d)
    if not day_of_week then return end
    api.nvim_win_set_cursor(0, {api.nvim_win_get_cursor(0)[1], insert_pos - 1})
    vim.paste({" "..day_of_week}, -1)
end

---Count down to a timestamp.
---@param date integer Timestamp(<YYYY-MM-DD A hh:mm>).
---@return string|nil result Countdown information.
local function countdown(date)
    local now = os.time()
    local ts, year, month, day, hour, minute =
    date:match("(<(%d+)%-(%d+)%-(%d+)%s.-(%d+):(%d+)>)")

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
        return days.." day"..(days > 1 and "s" or "").." left."
    else
        local days = math.ceil(-sub)
        return "Overdue "..days.." day"..(days > 1 and "s" or "").."."
    end
end

---Print TODO list.
function M.print_todo_list()
    local content = api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(content) do
        local todo, date, item = line:match("(TODO(%b<>):%s+(.+))$")
        if todo and not line:match("%[X%]") then
            print(date == "<>" and item or item.." -> "..countdown(date))
        end
    end
end


return M
