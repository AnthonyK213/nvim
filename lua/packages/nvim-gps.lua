require('nvim-gps').setup({
    icons = {
        ["class-name"] = '[C]',
        ["function-name"] = '[F]',
        ["method-name"] = '[M]',
        ["container-name"] = '[L]',
        ["tag-name"] = '<tag> '
    },
    separator = ' >> ',
    depth = 0,
    depth_limit_indicator = ".."
})
