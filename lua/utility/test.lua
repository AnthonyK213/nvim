local M = {}


---Performance test.
---@param label string Label of the test.
---@param f function Function to test.
---@param ... any Arguments for `f`.
function M.p(label, f, ...)
    local s = os.clock()
    local result = f(...)
    local e = os.clock()
    print(string.format("test_%s: { duration: %f, result: %s }",
    label, e - s, vim.inspect(result)))
end

---Reload module.
---@param module string Module name.
---@return tablelib module.
function M.r(module)
    if package.loaded[module] then
        package.loaded[module] = nil
    end
    return require(module)
end


return M
