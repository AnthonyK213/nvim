vim.cmd [[packadd lualine.nvim]]

local mode_alias = {
    i = "I", ic  = "I", ix     = "I",
    v = "v", V   = "V", [""] = "B",
    n = "N", niI = "Ĩ", no = "N", nt = "N",
    R = "R", Rv = "R",
    s = "s", S  = "S",
    c = "C", t  = "T",
    multi = "M",
}

require("lualine").setup {
    options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        icons_enabled = false,
        globalstatus = _my_core_opt.tui.global_statusline
    },
    sections = {
        lualine_a = {
            function ()
                return mode_alias[vim.api.nvim_get_mode().mode] or "_"
            end
        },
        lualine_b = { "branch" },
        lualine_c = {
            { "filename", path = 2 },
            { "aerial", sep = " >> " },
            "diff"
        },
        lualine_x = {
            { "diagnostics", sources = { "nvim_diagnostic" } },
            "filetype"
        },
        lualine_y = { "encoding", "fileformat" },
        lualine_z = { "progress", "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    extensions = { "nvim-tree", "quickfix" }
}
