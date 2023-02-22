local M = {}

---Gets a human-readable representation of the given iterable collection.
---@param iterable any
---@param meta table
---@param name string
---@return string
function M.iter_inspect(iterable, meta, name)
    local count = 0
    local visited = {}
    local function str(obj)
        if getmetatable(obj) == meta then
            local index = visited[obj]
            if index then
                return string.format("%s<%d>", name, index)
            else
                visited[obj] = count
                local result = string.format("%s<%d>{ ", name, count)
                count = count + 1
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

return M
