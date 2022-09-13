local ts_option = _my_core_opt.ts or {}

---Check if `ts_option.ensure` contains a parser.
---@param parser_name string Name of the parser.
---@return boolean
local function has(parser_name)
    return vim.tbl_contains(ts_option.ensure or {}, parser_name)
end

-- Enable built-in parsers.
vim.g.ts_highlight_c = not has("c")
vim.g.ts_highlight_lua = not has("lua")
vim.g.ts_highlight_vim = not has("vim")

require("nvim-treesitter.configs").setup {
    ensure_installed = ts_option.ensure or {},
    highlight = {
        enable = true,
        disable = ts_option.hi_disable or {},
        additional_vim_regex_highlighting = false,
    },
    matchup = {
        enable = true,
        disable = {}
    }
}
