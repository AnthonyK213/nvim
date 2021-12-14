local M = {}


-- Performance.
function M.p(label, f, ...)
    local s = os.clock()
    local result = f(...)
    local e = os.clock()
    print(string.format("test_%s: { duration: %f, result: %s }",
    label, e - s, vim.inspect(result)))
end

-- Reload module.
function M.r(module)
    if package.loaded[module] then
        package.loaded[module] = nil
    end
    return require(module)
end


return M
