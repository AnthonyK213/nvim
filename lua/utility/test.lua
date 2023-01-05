local lib = require("utility.lib")

local M = {}

---Performance test for a function.
---@param label string Label of the test.
---@param f function Function to test.
---@param ... any Arguments for `f`.
function M.p(label, f, ...)
    local s = os.clock()
    local result_table = lib.tbl_pack(f(...))
    local e = os.clock()
    local result
    if result_table.n == 0 then
        result = "None"
    elseif result_table.n == 1 then
        result = vim.inspect(result_table[1])
    else
        result_table.n = nil
        result = vim.inspect(result_table)
        result = "[\n    " .. result:sub(2, #result - 1) .. "\n  ]"
    end
    vim.notify(string.format("test_%s: {\n  duration: %f,\n  result: %s\n}",
        label, e - s, result))
end

---Reload module.
---@param module string Module name.
---@return any module
function M.r(module)
    if package.loaded[module] then
        package.loaded[module] = nil
    end
    return require(module)
end

return M
