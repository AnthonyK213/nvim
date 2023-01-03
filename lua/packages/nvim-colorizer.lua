vim.cmd.packadd("nvim-colorizer.lua")

require("colorizer").setup({
    "html",
    "javascript",
    "json",
    "typescript",
    css = { names = true, rgb_fn = true },
    vue = { names = true, rgb_fn = true },
}, {
    RGB      = true,
    RRGGBB   = true,
    names    = false,
    RRGGBBAA = false,
    rgb_fn   = false,
    hsl_fn   = false,
    css      = false,
    css_fn   = false,
    mode     = "background"
})
