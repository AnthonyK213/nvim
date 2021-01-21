-- Hanzi count.
function util_lua_hanzi_count(mode)
    if mode == "n" then
        content = vim.fn.getline(1, '$')
    elseif mode == "v" then
        content = vim.fn.split(vim.fn.Lib_Get_Visual_Selection(), "\n")
    else
        return
    end

    local h_count = 0
    for i, line in ipairs(content) do
        for j, char in ipairs(vim.fn.split(line, "\\zs")) do
            local code = vim.fn.char2nr(char)
            if code >= 0x4E00 and code <= 0x9FA5 then
                h_count = h_count + 1
            end
        end
    end

    return h_count
end
