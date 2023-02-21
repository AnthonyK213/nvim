local Iterator = require("collections.iter")
local M = {}

---Gets a human-readable representation of the given iterable collection.
---@param iterable any
---@param meta table
---@param name string
---@return string
function M.iter_inspect(iterable, meta, name)
    local visited = {}
    local function str(obj)
        if getmetatable(obj) == meta then
            local index = require("utility.lib").tbl_find_first(visited, obj)
            if index > 0 then
                return string.format("%s<%d>", name, index - 1)
            else
                table.insert(visited, obj)
                local result = string.format("%s<%d>{ ", name, #visited - 1)
                for i, v in obj:iter() do
                    result = result .. str(v)
                    if i ~= obj:count() then
                        result = result .. ", "
                    end
                end
                return result .. " }"
            end
        elseif type(obj) == "string" then
            return vim.inspect(obj)
        else
            return tostring(obj)
        end
    end
    return str(iterable)
end

---Equality test.
---@param a any
---@param b any
---@return boolean
function M.is_equal(a, b)
    if not getmetatable(a) or getmetatable(a) ~= getmetatable(b) then
        return rawequal(a, b)
    end
    if a:count() ~= b:count() then
        return false
    end
    for _, tup in Iterator(a):zip(Iterator(b)):consume() do
        if not M.is_equal(tup[1], tup[2]) then
            return false
        end
    end
    return true
end

return M
