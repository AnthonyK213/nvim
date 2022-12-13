vim.cmd.packadd("onenord.nvim")
local colors = require("onenord.colors").load()

---Cast configured hightlight override table to onenord format.
---@param hl table<string, table<string, string>>
local function hl_cast(hl)
    ---@type table<string, table<string, string>>
    local result = vim.deepcopy(hl)
    local map = {
        ["$bg3"] = "light_gray",
    }
    for _, attr in pairs(result) do
        local style
        for k, v in pairs(attr) do
            if k == "fmt" then
                style = v
            elseif map[v] then
                attr[k] = colors[map[v]]
            else
                attr[k] = colors[v:gsub("^%$", "")]
            end
        end
        if style then
            attr.fmt = nil
            attr.style = style
        end
    end
    return result
end

require("onenord").setup({
    borders = true,
    fade_nc = _my_core_opt.tui.auto_dim,
    styles = {
        comments = "NONE",
        strings = "NONE",
        keywords = "NONE",
        functions = "NONE",
        variables = "NONE",
        diagnostics = "underline",
    },
    disable = {
        background = _my_core_opt.tui.transparent,
        cursorline = false,
        eob_lines = true,
    },
    inverse = {
        match_paren = false,
    },
    custom_highlights = hl_cast(_my_core_opt.hl),
    custom_colors = {},
})

vim.g._my_theme_switchable = true
vim.cmd.colorscheme("onenord")
