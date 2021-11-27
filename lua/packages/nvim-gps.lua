require('nvim-gps').setup({
    icons = {
        ["class-name"] = '[C]',
        ["function-name"] = '[F]',
        ["method-name"] = '[M]',
        ["container-name"] = '[T]',
        ["tag-name"] = '[tag]'
    },
    languages = {
        ["json"] = {
            icons = {
                ["array-name"] = '[a]',
                ["object-name"] = '[O]',
                ["null-name"] = '[×]',
                ["boolean-name"] = '[b]',
                ["number-name"] = '[n]',
                ["string-name"] = '[s]'
            }
        },
        ["toml"] = {
            icons = {
                ["table-name"] = '[T]',
                ["array-name"] = '[a]',
                ["boolean-name"] = '[b]',
                ["date-name"] = '[d]',
                ["date-time-name"] = '[dt]',
                ["float-name"] = '[f]',
                ["inline-table-name"] = '[Ti]',
                ["integer-name"] = '[i]',
                ["string-name"] = '[s]',
                ["time-name"] = '[t]'
            }
        },
        ["yaml"] = {
            icons = {
                ["mapping-name"] = '[m]',
                ["sequence-name"] = '[seq]',
                ["null-name"] = '[×]',
                ["boolean-name"] = '[b]',
                ["integer-name"] = '[i]',
                ["float-name"] = '[f]',
                ["string-name"] = '[s]'
            }
        },
    },
    separator = ' >> ',
    depth = 0,
    depth_limit_indicator = ".."
})
