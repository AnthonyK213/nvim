local M = {
  enabled = true,
  layouts = {
    default = {
      layout = {
        box       = "horizontal",
        width     = 0.8,
        min_width = 120,
        height    = 0.8,
        {
          box    = "vertical",
          border = _G._my_core_opt.tui.border,
          title  = "{title} {live} {flags}",
          {
            win    = "input",
            height = 1,
            border = "bottom"
          },
          {
            win    = "list",
            border = "none"
          },
        },
        {
          win    = "preview",
          title  = "{preview}",
          border = _G._my_core_opt.tui.border,
          width  = 0.5
        },
      },
    },
    select = {
      layout = {
        border = _G._my_core_opt.tui.border,
      },
    }
  },
  prompt = "> ",
  icons = {
    files = {
      enabled = _G._my_core_opt.tui.devicons,
    },
    undo = {
      saved = _G._my_core_opt.tui.devicons and " " or "s",
    },
    ui = {
      live = "~",
    },
    git = {
      enabled = _G._my_core_opt.tui.devicons,
    },
  },
}

return M
