vim.cmd[[packadd alpha-nvim]]


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {
    [[                                                    ]],
    [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
    [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
    [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
    [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
    [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
    [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
    [[                                                    ]],
}
dashboard.section.buttons.val = {
    dashboard.button("e", "∅  Empty File" ,  ":enew<CR>"),
    dashboard.button("f", "⊕  Find File",    ":Telescope find_files<CR>"),
    dashboard.button("s", "↺  Load Session", ":SessionManager load_session<CR>"),
    dashboard.button(",", "⚙  Options",      ":call my#compat#open_nvimrc()<CR>"),
    dashboard.button("p", "⟲  Packer Sync",  ":PackerSync<CR>"),
    dashboard.button("q", "⊗  Quit Nvim",    ":qa<CR>"),
}


alpha.setup(dashboard.opts)
