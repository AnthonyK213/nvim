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

---Get `contains` method of `iterable`.
---@param iterable any
---@return (fun(iterable: any, item: any):boolean)|nil
function M.get_contains(iterable)
    if vim.tbl_islist(iterable) then
        return vim.tbl_contains
    elseif vim.is_callable(iterable.contains) then
        return iterable.contains
    else
        return
    end
end

---Get `count` method of `iterable`.
---@param iterable any
---@return (fun(iterable: any):integer)|nil
function M.get_count(iterable)
    if vim.tbl_islist(iterable) then
        return function(x)
            return #x
        end
    elseif vim.is_callable(iterable.count) then
        return iterable.count
    else
        return
    end
end

return M
