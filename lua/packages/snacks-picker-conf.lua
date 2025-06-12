local M = {
  enabled = true,
  layouts = {
    default = {
      layout = {
        box       = "horizontal",
        width     = 0.8,
        min_width = 100,
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
    dropdown = {
      layout = {
        backdrop  = false,
        row       = 1,
        width     = 0.4,
        min_width = 80,
        height    = 0.8,
        border    = "none",
        box       = "vertical",
        {
          win    = "preview",
          title  = "{preview}",
          height = 0.4,
          border = _G._my_core_opt.tui.border
        },
        {
          box       = "vertical",
          border    = _G._my_core_opt.tui.border,
          title     = "{title} {live} {flags}",
          title_pos = "center",
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
      },
    },
    select = {
      layout = {
        border = _G._my_core_opt.tui.border,
      },
    },
    sidebar = {
      preview = "main",
      layout = {
        backdrop  = false,
        width     = 40,
        min_width = 40,
        height    = 0,
        position  = "left",
        border    = "none",
        box       = "vertical",
        {
          win       = "input",
          height    = 1,
          border    = _G._my_core_opt.tui.border,
          title     = "{title} {live} {flags}",
          title_pos = "center",
        },
        {
          win    = "list",
          border = "none"
        },
        {
          win    = "preview",
          title  = "{preview}",
          height = 0.4,
          border = "top"
        },
      },
    },
    telescope = {
      reverse = true,
      layout = {
        box      = "horizontal",
        backdrop = true,
        width    = 0.8,
        height   = 0.8,
        border   = "none",
        {
          box = "vertical",
          {
            win       = "list",
            title     = " Results ",
            title_pos = "center",
            border    = _G._my_core_opt.tui.border
          },
          {
            win       = "input",
            height    = 1,
            border    = _G._my_core_opt.tui.border,
            title     = "{title} {live} {flags}",
            title_pos = "center"
          },
        },
        {
          win       = "preview",
          title     = "{preview:Preview}",
          width     = 0.5,
          border    = _G._my_core_opt.tui.border,
          title_pos = "center",
        },
      },
    },
    vertical = {
      layout = {
        backdrop = true,
        border   = _G._my_core_opt.tui.border,
      },
    },
    vscode = {
      preview = false,
      layout = {
        backdrop  = false,
        row       = 1,
        width     = 0.4,
        min_width = 80,
        height    = 0.4,
        border    = "none",
        box       = "vertical",
        {
          win       = "input",
          height    = 1,
          border    = _G._my_core_opt.tui.border,
          title     = "{title} {live} {flags}",
          title_pos = "center"
        },
        {
          win    = "list",
          border = "hpad"
        },
        {
          win    = "preview",
          title  = "{preview}",
          border = _G._my_core_opt.tui.border,
        },
      },
    }
  },
  prompt = "> ",
  icons = {
    files = {
      enabled = _G._my_core_opt.tui.devicons,
    },
    undo = {
      saved = _G._my_core_opt.tui.devicons and "󰆓 " or "s",
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
