vim.cmd [[packadd nightfox.nvim]]

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

require("nightfox").setup {
    options = {
        compile_path = vim.fn.stdpath("data").."/nightfox",
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

local style_list = { "night", "day", "dawn", "dusk", "nord", "tera" }
local opt_style = _my_core_opt.tui.style
local style = vim.tbl_contains(style_list, opt_style) and opt_style or "night"
vim.cmd("colorscheme "..style.."fox")
