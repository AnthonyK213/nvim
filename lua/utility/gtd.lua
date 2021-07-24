local M = {}


-- Calculate the day of week from a date(yyyy-mm-dd).
local function zeller(year, month, date)
    if (month < 1 or month > 12) then
        print("Not a valid month.")
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
        if ((month <= 7 and month % 2 == 1) or
            (month >= 8 and month % 2 == 0)) then
            month_days_count = month_days_count + 1
        end
    end

    if (date < 1 or date > month_days_count) then
        print("Not a valid date.")
        return
    end

    if (month == 1 or month == 2) then
        year = year - 1
        month = month + 12
    end

    local c = math.floor(year / 100)
    local y = year - c * 100
    local x = math.floor(c / 4) + y + math.floor(y / 4) +
              math.floor(26 * (month + 1) / 10) + date - 2 * c - 1
    local z = x % 7
    if (z <= 0) then z = z + 7 end
    local days_list = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}

    return days_list[z]
end

function M.append_day_from_date()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col('.')

    local y, m, d, insert_pos
    for pos_s, date, year, month, day, pos_e
        in line:gmatch('()((%d%d%d%d)%-(%d%d)%-(%d%d))()') do
        if (pos_s <= col + 1 and
            pos_e >= col + 1 and
            date) then
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
    vim.fn.setpos('.', {0, vim.fn.line('.'), insert_pos})
    vim.cmd('normal! a '..day_of_week)
end

-- Count down to a timestamp(<%Y-%m-%d %a %H:%M>).
local function countdown(date)
    local now = os.time()
    local ts, year, month, day, hour, minute =
    date:match('(<(%d+)%-(%d+)%-(%d+)%s.-(%d+):(%d+)>)')

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
        return days.." day"..(days > 1 and 's' or '').." left."
    else
        local days = math.ceil(-sub)
        return "Overdue "..days.." day"..(days > 1 and 's' or '').."."
    end
end

-- Print TODO list.
function M.print_todo_list()
    local content = vim.fn.getline(1, '$')
    for _, line in ipairs(content) do
        local todo, date, item = line:match('(TODO(%b<>):%s+(.+))$')
        if todo and not line:match('%[X%]') then
            print(date == '<>' and item or item.." -> "..countdown(date))
        end
    end
end


return M
