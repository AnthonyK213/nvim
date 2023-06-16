---Check if `style` is dark theme.
---@param style string
---@return boolean
local function is_dark(style)
    return vim.list_contains({ "night", "dusk", "nord", "tera", "carbon" }, style)
end

---Check if `style` is light theme.
---@param style string
---@return boolean
local function is_light(style)
    return style == "day" or style == "dawn"
end

---Set nightfox `style`.
---@param style string
local function set_style(style)
    vim.cmd.colorscheme(style .. "fox")
end

---Cast configured hightlight override table to nightfox format.
---@param hl table<string, table<string, string>>
local function hl_cast(hl)
    ---@type table<string, table<string, string>>
    local result = vim.tbl_extend("force", vim.deepcopy(hl), {
        BufferCurrent = { fg = "$fg0", bg = "none" },
        BufferCurrentERROR = { fg = "$red", bg = "none" },
        BufferCurrentWARN = { fg = "$yellow", bg = "none" },
        BufferCurrentHINT = { fg = "$green", bg = "none" },
        BufferCurrentINFO = { fg = "$blue", bg = "none" },
        BufferVisibleERROR = { fg = "$red", bg = "$bg0" },
        BufferVisibleWARN = { fg = "$yellow", bg = "bg0" },
        BufferVisibleHINT = { fg = "$green", bg = "bg0" },
        BufferVisibleINFO = { fg = "$blue", bg = "bg0" },
        BufferCurrentIndex = { fg = "$fg0", bg = "none" },
        BufferCurrentNumber = { fg = "$fg0", bg = "none" },
        BufferCurrentSign = { fg = "$cyan", bg = "none" },
        BufferCurrentTarget = { fg = "$red", bg = "none" },
        BufferCurrentMod = { fg = "$orange", bg = "none" },
    })
    local map = {
        ["$bg3"] = "palette.bg4",
        ["$light_grey"] = "palette.fg3",
        ["$purple"] = "palette.magenta",
    }
    for _, attr in pairs(result) do
        local style
        for k, v in pairs(attr) do
            if k == "fmt" then
                style = v
            elseif map[v] then
                attr[k] = map[v]
            else
                attr[k] = v:gsub("^%$", "palette.")
            end
        end
        if style then
            attr.fmt = nil
            attr.style = style
        end
    end
    return result
end

local style_table = {
    night = "day",
    day = "night",
    dawn = "dusk",
    dusk = "dawn",
    nord = "day",
    tera = "dawn",
    carbon = "dawn",
}
local opt_style = _my_core_opt.tui.style
local fox_style = style_table[opt_style] and opt_style or "night"

require("nightfox").setup {
    options = {
        compile_path = vim.fn.stdpath("data") .. "/nightfox",
        compile_file_suffix = "_compiled",
        transparent = _my_core_opt.tui.transparent,
        styles = {
            comments = "italic"
        },
        dim_inactive = _my_core_opt.tui.auto_dim,
    },
    groups = {
        all = hl_cast(_my_core_opt.hl)
    }
}

---Background switching interface.
---@param bg? string
vim.g._my_theme_switchable = function(bg)
    local colors_name = vim.g.colors_name:sub(1, vim.g.colors_name:len() - 3)
    if bg == "light" and is_light(colors_name)
        or bg == "dark" and is_dark(colors_name) then
        return
    end
    if is_light(colors_name) and is_dark(fox_style) then
        set_style(fox_style)
    else
        set_style(style_table[colors_name])
    end
end

set_style(fox_style)
