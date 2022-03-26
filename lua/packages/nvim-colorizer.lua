vim.cmd('packadd nvim-colorizer.lua')

require('colorizer').setup({
    css = { names = true, rgb_fn = true },
    'html',
    'javascript',
    'typescript',
    'json'
}, {
    RGB      = true,
    RRGGBB   = true,
    names    = false,
    RRGGBBAA = false,
    rgb_fn   = false,
    hsl_fn   = false,
    css      = false,
    css_fn   = false,
    mode     = 'background'
})
