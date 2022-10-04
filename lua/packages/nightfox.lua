vim.cmd.packadd("nightfox.nvim")

---Check if `style` is dark theme.
---@param style string
---@return boolean
local function is_dark(style)
    return vim.tbl_contains({ "night", "dusk", "nord", "tera", "carbon" }, style)
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

---Cast onedark hightlight override table to nightfox.
---@param hl table<string, table<string, string>>
local function hl_cast(hl)
    ---@type table<string, table<string, string>>
    local result = vim.deepcopy(hl)
    local map = {
        ["$bg3"] = "bg3",
        ["$light_grey"] = "fg3",
        ["$purple"] = "palette.magenta",
    }
    for _, attr in pairs(result) do
        local fmt
        for k, v in pairs(attr) do
            if k == "style" then
                fmt = v
            elseif map[v] then
                attr[k] = map[v]
            else
                attr[k] = v:gsub("^%$", "palette.")
            end
        end
        if fmt then
            attr.fmt = fmt
            attr.style = nil
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
        }
    },
    groups = {
        all = hl_cast(_my_core_opt.hl)
    }
}

---Background switching interface.
---@param bg string?
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
