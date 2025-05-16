local lazy_path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy/lazy.nvim")
if not vim.uv.fs_stat(lazy_path) then
  if vim.fn.executable("git") > 0 then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazy_path,
    })
  else
    error("Executable git is not found.")
  end
end

vim.opt.rtp:prepend(lazy_path)

local load_3rd_ui = require("internal.cpt").set_color_scheme(function(cs)
  return vim.list_contains({
    "onedark", "tokyonight", "gruvbox", "nightfox", "onenord"
  }, cs)
end)

-- Setup lazy.nvim.
require("lazy").setup({
  -- Color scheme
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    cond = function() return _G._my_core_opt.tui.scheme == "onedark" end,
    config = function() require("packages.onedark") end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    cond = function() return _G._my_core_opt.tui.scheme == "tokyonight" end,
    config = function() require("packages.tokyonight") end
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    cond = function() return _G._my_core_opt.tui.scheme == "gruvbox" end,
    config = function() require("packages.gruvbox") end
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    cond = function() return _G._my_core_opt.tui.scheme == "nightfox" end,
    config = function() require("packages.nightfox") end
  },
  {
    "rmehri01/onenord.nvim",
    lazy = false,
    priority = 1000,
    cond = function() return _G._my_core_opt.tui.scheme == "onenord" end,
    config = function() require("packages.onenord") end
  },
  -- Optional
  {
    "goolord/alpha-nvim",
    cond = load_3rd_ui,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = _G._my_core_opt.tui.welcome_header
      dashboard.section.buttons.val = {
        dashboard.button("e", "∅  Empty File", ":enew<CR>"),
        dashboard.button("f", "⊕  Find File", ":Telescope find_files<CR>"),
        dashboard.button("s", "↺  Load Session", ":SessionManager load_session<CR>"),
        dashboard.button(",", "⚙  Options", ":call my#compat#open_nvimrc()<CR>"),
        dashboard.button("p", "⟲  Packages Sync", ":Lazy sync<CR>"),
        dashboard.button("q", "⊗  Quit Nvim", ":qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    cond = load_3rd_ui,
    opts = {
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        icons_enabled = false,
        globalstatus = _G._my_core_opt.tui.global_statusline
      },
      sections = {
        lualine_a = {
          function()
            return ({
              i = "I", ic = "I", ix = "I",
              v = "v", V = "V", [""] = "B",
              n = "N", niI = "Ĩ", no = "N", nt = "N",
              R = "R", Rv = "R",
              s = "s", S = "S",
              c = "C", t = "T",
              multi = "M",
            })[vim.api.nvim_get_mode().mode] or "_"
          end
        },
        lualine_b = { "branch" },
        lualine_c = {
          { "filename", path = 2 },
          { "aerial",   sep = "::" },
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
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    cond = _G._my_core_opt.tui.devicons,
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    cond = load_3rd_ui,
    init = function() vim.o.showtabline = 2 end,
    opts = {
      options = {
        themable = true,
        right_mouse_command = "",
        middle_mouse_command = "bdelete! %d",
        indicator = {
          icon = "▍",
          style = "icon",
        },
        buffer_close_icon = "×",
        modified_icon = "+",
        close_icon = "×",
        left_trunc_marker = "<",
        right_trunc_marker = ">",
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count)
          return "(" .. count .. ")"
        end,
        custom_filter = function(bufnr)
          return not vim.tbl_contains({
            "terminal", "quickfix", "prompt"
          }, vim.api.nvim_get_option_value("buftype", { buf = bufnr }))
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          }
        },
        show_buffer_icons = _G._my_core_opt.tui.devicons,
        show_buffer_close_icons = true,
        show_close_icon = false,
        persist_buffer_sort = true,
        separator_style = _G._my_core_opt.tui.bufferline_style,
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = "id",
        groups = {
          options = {
            toggle_hidden_on_enter = true
          },
          items = {
            {
              name = "Docs",
              highlight = { sp = "cyan" },
              auto_close = false,
              matcher = function(buf)
                return buf.name:match("%.md")
                    or buf.name:match("%.txt")
              end,
            }
          }
        }
      }
    },
    keys = {
      { "<leader>bb", "<Cmd>BufferLinePick<CR>" },
      { "<leader>bp", "<Cmd>BufferLineCyclePrev<CR>" },
      { "<leader>bn", "<Cmd>BufferLineCycleNext<CR>" },
      { "<leader>bP", "<Cmd>BufferLineMovePrev<CR>" },
      { "<leader>bN", "<Cmd>BufferLineMoveNext<CR>" },
    }
  },
  {
    "norcalli/nvim-colorizer.lua",
    ft = { "html", "javascript", "json", "typescript", "css", "vue" },
    cond = load_3rd_ui,
    config = function()
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
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "VeryLazy", "BufReadPre" },
    cond = load_3rd_ui,
    main = "ibl",
    opts = {
      enabled = _G._my_core_opt.tui.show_context,
      debounce = 1000,
      indent = {
        char = "▏",
      },
      viewport_buffer = {
        min = 30,
        max = 500
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        injected_languages = false,
        priority = 500,
      },
      exclude = {
        filetypes = {
          "aerial", "alpha", "lazy",
          "markdown", "presenting_markdown",
          "vimwiki", "NvimTree", "mason", "lspinfo",
          "NeogitStatus", "NeogitCommitView", "DiffviewFiles",
        },
        buftypes = {
          "help", "quickfix", "terminal", "nofile"
        },
      }
    }
  },
  -- File system
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      disable_netrw = true,
      hijack_cursor = true,
      on_attach = function(bufnr)
        local k = vim.keymap.set
        local n = require("nvim-tree.api")
        local o = { buffer = bufnr, noremap = true, silent = true }
        k("n", "<2-LeftMouse>", n.node.open.edit, o)
        k("n", "<2-RightMouse>", n.tree.change_root_to_node, o)
        k("n", "<C-J>", n.node.navigate.sibling.next, o)
        k("n", "<C-K>", n.node.navigate.sibling.prev, o)
        k("n", "<CR>", n.node.open.edit, o)
        k("n", "<F2>", n.fs.rename, o)
        k("n", "<M-Y>", n.fs.copy.absolute_path, o)
        k("n", "<M-y>", n.fs.copy.relative_path, o)
        k("n", "<Tab>", n.node.open.preview, o)
        k("n", "C", n.tree.change_root_to_node, o)
        k("n", "D", n.fs.remove, o)
        k("n", "H", n.tree.toggle_hidden_filter, o)
        k("n", "I", n.tree.toggle_gitignore_filter, o)
        k("n", "K", n.node.show_info_popup, o)
        k("n", "R", n.tree.reload, o)
        k("n", "U", n.tree.change_root_to_parent, o)
        k("n", "a", n.fs.create, o)
        k("n", "c", n.fs.copy.node, o)
        k("n", "gj", n.node.navigate.git.next, o)
        k("n", "gk", n.node.navigate.git.prev, o)
        k("n", "i", n.node.open.horizontal, o)
        k("n", "o", n.node.run.system, o)
        k("n", "p", n.fs.paste, o)
        k("n", "q", n.tree.close, o)
        k("n", "r", n.fs.rename, o)
        k("n", "s", n.node.open.vertical, o)
        k("n", "t", n.node.open.tab, o)
        k("n", "u", n.node.navigate.parent, o)
        k("n", "x", n.fs.cut, o)
        k("n", "y", n.fs.copy.filename, o)
      end,
      renderer = {
        highlight_git = true,
        indent_markers = {
          enable = false,
          icons = {
            corner = "└ ",
            edge = "│ ",
            none = "  ",
          },
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = false,
            git = true,
          },
          glyphs = {
            default = "▪ ",
            symlink = "▫ ",
            folder = {
              default = "+",
              open = "-",
              empty = "*",
              empty_open = "*",
              symlink = "@",
              symlink_open = "@",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "U",
              renamed = "➜",
              untracked = "★",
              deleted = "D",
              ignored = "◌"
            },
          }
        },
      },
      update_focused_file = {
        enable = false,
        update_root = {
          enable = false,
          ignore_list = {},
        },
        exclude = false,
      },
      system_open = require("utility.util").sys_open_config(),
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = {
          hint = "!",
          info = "I",
          warning = "W",
          error = "E"
        }
      },
      filters = {
        dotfiles = true,
        custom = { ".cache" }
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 400
      },
      filesystem_watchers = {
        enable = false,
        debounce_delay = 50,
        ignore_dirs = {},
      },
      actions = {
        change_dir = {
          enable = false,
          global = false,
        },
        file_popup = {
          open_win_config = {
            border = _G._my_core_opt.tui.border,
          }
        },
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "qf", "help", "aerial" },
              buftype  = { "terminal" }
            }
          }
        }
      }
    },
    keys = {
      { "<leader>op", "<Cmd>NvimTreeToggle<CR>" },
      { "<M-e>",      "<Cmd>NvimTreeFindFile<CR>" },
    }
  },
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    config = function()
      local border_style = _G._my_core_opt.tui.border
      local border_styles = {
        single  = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        double  = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
        rounded = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      }
      require("telescope").setup {
        defaults = {
          mappings = {
            i = {
              ["<C-Down>"] = require("telescope.actions").cycle_history_next,
              ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
            },
          },
          border = border_style ~= "none",
          borderchars = border_styles[border_style] or border_styles["rounded"],
          -- sorting_strategy = "ascending",
        },
        extensions = {
          aerial = {
            show_nesting = {
              ["_"]    = false,
              json     = true,
              markdown = true,
            }
          }
        }
      }
      -- Load extensions.
      require("telescope").load_extension("aerial")
    end,
    keys = {
      { "<leader>fb", function() require("telescope.builtin").buffers() end },
      { "<leader>ff", function() require("telescope.builtin").find_files() end },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end },
    }
  },
  -- Git
  {
    "NeogitOrg/neogit",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>gn", "<Cmd>Neogit<CR>" },
    }
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup {
        use_icons = _G._my_core_opt.tui.devicons,
        icons = {
          folder_closed = ">",
          folder_open   = "v",
        },
        signs = {
          fold_closed = ">",
          fold_open   = "v",
          done        = "✓",
        },
        keymaps = {
          disable_defaults = true,
          view = {
            ["<Tab>"]           = actions.select_next_entry,
            ["<S-Tab>"]         = actions.select_prev_entry,
            ["gf"]              = actions.goto_file,
            ["<C-W><C-F>"]      = actions.goto_file_split,
            ["<C-W>gf"]         = actions.goto_file_tab,
            ["<localleader>e"]  = actions.focus_files,
            ["<localleader>b"]  = actions.toggle_files,
            ["g<C-X>"]          = actions.cycle_layout,
            ["[x"]              = actions.prev_conflict,
            ["]x"]              = actions.next_conflict,
            ["<localleader>co"] = actions.conflict_choose("ours"),
            ["<localleader>ct"] = actions.conflict_choose("theirs"),
            ["<localleader>cb"] = actions.conflict_choose("base"),
            ["<localleader>ca"] = actions.conflict_choose("all"),
            ["dx"]              = actions.conflict_choose("none"),
            ["q"]               = "<Cmd>DiffviewClose<CR>",
          },
          diff1 = {},
          diff2 = {},
          diff3 = {
            { { "n", "x" }, "2do", actions.diffget("ours") },
            { { "n", "x" }, "3do", actions.diffget("theirs") },
          },
          diff4 = {
            { { "n", "x" }, "1do", actions.diffget("base") },
            { { "n", "x" }, "2do", actions.diffget("ours") },
            { { "n", "x" }, "3do", actions.diffget("theirs") },
          },
          file_panel = {
            ["j"]              = actions.next_entry,
            ["<Down>"]         = actions.next_entry,
            ["k"]              = actions.prev_entry,
            ["<Up>"]           = actions.prev_entry,
            ["<Cr>"]           = actions.select_entry,
            ["o"]              = actions.select_entry,
            ["<2-LeftMouse>"]  = actions.select_entry,
            ["-"]              = actions.toggle_stage_entry,
            ["S"]              = actions.stage_all,
            ["U"]              = actions.unstage_all,
            ["X"]              = actions.restore_entry,
            ["L"]              = actions.open_commit_log,
            ["<C-B>"]          = actions.scroll_view(-0.25),
            ["<C-F>"]          = actions.scroll_view(0.25),
            ["<Tab>"]          = actions.select_next_entry,
            ["<S-Tab>"]        = actions.select_prev_entry,
            ["gf"]             = actions.goto_file,
            ["<C-W><C-F>"]     = actions.goto_file_split,
            ["<C-W>gf"]        = actions.goto_file_tab,
            ["i"]              = actions.listing_style,
            ["f"]              = actions.toggle_flatten_dirs,
            ["R"]              = actions.refresh_files,
            ["<localleader>e"] = actions.focus_files,
            ["<localleader>b"] = actions.toggle_files,
            ["g<C-X>"]         = actions.cycle_layout,
            ["[x"]             = actions.prev_conflict,
            ["]x"]             = actions.next_conflict,
            ["q"]              = "<Cmd>DiffviewClose<CR>",
            ["c"]              = function()
              local futures = require("futures")
              futures.spawn(function()
                local msg = futures.ui.input { prompt = "Commit message: " }
                if not msg or #msg == 0 then return end
                local yes_no = futures.ui.input { prompt = "Commit? [Y/n] " }
                if yes_no and yes_no:lower() == "y" then
                  if require("logit").commit(msg):start() then
                    vim.notify("Commiting...")
                  end
                end
              end)
            end,
            ["p"]              = function()
              if require("logit").pull():start() then
                vim.notify("Pulling from remote...")
              end
            end,
            ["P"]              = function()
              if require("logit").push():start() then
                vim.notify("Pushing...")
              end
            end,
          },
          file_history_panel = {
            ["g!"]             = actions.options,
            ["<C-M-d>"]        = actions.open_in_diffview,
            ["y"]              = actions.copy_hash,
            ["L"]              = actions.open_commit_log,
            ["zR"]             = actions.open_all_folds,
            ["zM"]             = actions.close_all_folds,
            ["j"]              = actions.next_entry,
            ["<Down>"]         = actions.next_entry,
            ["k"]              = actions.prev_entry,
            ["<Up>"]           = actions.prev_entry,
            ["<Cr>"]           = actions.select_entry,
            ["o"]              = actions.select_entry,
            ["<2-LeftMouse>"]  = actions.select_entry,
            ["<C-B>"]          = actions.scroll_view(-0.25),
            ["<C-F>"]          = actions.scroll_view(0.25),
            ["<Tab>"]          = actions.select_next_entry,
            ["<S-Tab>"]        = actions.select_prev_entry,
            ["gf"]             = actions.goto_file,
            ["<C-W><C-F>"]     = actions.goto_file_split,
            ["<C-W>gf"]        = actions.goto_file_tab,
            ["<localleader>e"] = actions.focus_files,
            ["<localleader>b"] = actions.toggle_files,
            ["g<C-X>"]         = actions.cycle_layout,
            ["q"]              = "<Cmd>DiffviewClose<CR>",
          },
          option_panel = {
            ["<Tab>"] = actions.select_entry,
            ["q"]     = actions.close,
          },
        },
      }
    end,
    keys = {
      { "<leader>gh", "<Cmd>DiffviewFileHistory<CR>" },
    }
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text          = true,
        virt_text_pos      = "eol",
        delay              = 1000,
        ignore_whitespace  = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = _G._my_core_opt.tui.border,
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        local _o = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "<leader>gj", function() require("gitsigns").nav_hunk("next") end, _o)
        vim.keymap.set("n", "<leader>gk", function() require("gitsigns").nav_hunk("prev") end, _o)
        vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk, _o)
        vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, _o)
      end
    }
  },
  -- Utilities
  "nvim-lua/plenary.nvim",
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-A>",  "<Plug>(dial-increment)",                                mode = { "n", "v" } },
      { "<C-X>",  "<Plug>(dial-decrement)",                                mode = { "n", "v" } },
      { "g<C-A>", function() return require("dial.map").inc_gvisual() end, mode = "v",         expr = true },
      { "g<C-X>", function() return require("dial.map").dec_gvisual() end, mode = "v",         expr = true },
    }
  },
  {
    "dhruvasagar/vim-table-mode",
    init = function() vim.g.table_mode_corner = "+" end,
    keys = {
      { "<leader>ta", "<Cmd>TableAddFormula<CR>" },
      { "<leader>tc", "<Cmd>TableEvalFormulaLine<CR>" },
      { "<leader>tf", "<Cmd>TableModeRealign<CR>" },
      { "<leader>tm", "<Cmd>TableModeToggle<CR>" },
    }
  },
  {
    "AnthonyK213/lua-pairs",
    event = "VeryLazy",
    opts = {
      extd = {
        markdown = {
          { k = "<M-P>", l = "`",   r = "`" },
          { k = "<M-I>", l = "*",   r = "*" },
          { k = "<M-B>", l = "**",  r = "**" },
          { k = "<M-M>", l = "***", r = "***" },
          { k = "<M-U>", l = "<u>", r = "</u>" },
        },
        tex = {
          { k = "<M-B>", l = "\\textbf{", r = "}" },
          { k = "<M-I>", l = "\\textit{", r = "}" },
          { k = "<M-N>", l = "\\textrm{", r = "}" },
        },
        rust = {
          {
            l = "<",
            r = ">",
            d = function(context)
              local row, col = unpack(vim.api.nvim_win_get_cursor(0))
              col = col - #context.p
              if col == 0 then return true end
              return not require("utility.syn").Syntax.new(0, row, col):match {
                vs = [[\v^rust(Identifier|Keyword|FuncName)$]],
                ts = [[\v^(type|keyword|function)$]],
              }
            end
          },
        }
      },
      exclude = {
        buftype = { "prompt" },
        filetype = { "DressingInput" },
      },
    }
  },
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_deferred_show_delay = 100
      vim.g.matchup_matchparen_deferred_hide_delay = 700
    end,
  },
  {
    "Shatur/neovim-session-manager",
    event = "VeryLazy",
    config = function()
      require("session_manager").setup {
        sessions_dir = require("plenary.path"):new(vim.fn.stdpath("data"), "sessions"),
        path_replacer = "__",
        colon_replacer = "++",
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
        autosave_last_session = true,
        autosave_ignore_not_normal = true,
        autosave_only_in_session = false,
      }
    end
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      local border_style = _G._my_core_opt.tui.border
      local border_styles = {
        single = {
          prompt  = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        double = {
          prompt  = { "═", "║", " ", "║", "╔", "╗", "║", "║" },
          results = { "═", "║", "═", "║", "╠", "╣", "╝", "╚" },
          preview = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
        },
        rounded = {
          prompt  = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
          preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },
      }

      require("dressing").setup {
        input = {
          default_prompt = "> ",
          title_pos = "center",
          insert_only = true,
          relative = "editor",
          border = _G._my_core_opt.tui.border,
          win_options = { winblend = 10, },
          get_config = function(opts)
            if opts.kind == "at_cursor" then
              return { relative = "cursor" }
            end
          end,
          override = function(conf)
            conf.anchor = "SW"
            return conf
          end,
        },
        select = {
          backend = { "telescope" },
          format_item_override = {},
          telescope = require("telescope.themes").get_dropdown {
            border = border_style ~= "none",
            borderchars = border_styles[border_style] or border_styles["rounded"],
          },
          get_config = nil,
        },
      }
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>gl", function()
        if not require("utility.lib").executable("lazygit", true) then return end
        require("toggleterm.terminal").Terminal:new {
          cmd = "lazygit",
          hidden = true,
          direction = "float",
          float_opts = {
            border = _G._my_core_opt.tui.border,
          },
        }:toggle()
      end }
    }
  },
  {
    "saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    version = "0.3.0",
    opts = {
      text = {
        loading = "  Loading...",
        version = "  %s",
        prerelease = "  %s",
        yanked = "  %s yanked",
        nomatch = "  Not found",
        upgrade = "  %s",
        error = "  Error fetching crate",
      },
      popup = {
        border = _G._my_core_opt.tui.border,
        text = {
          title = "# %s",
          pill_left = "",
          pill_right = "",
          created_label = "created        ",
          updated_label = "updated        ",
          downloads_label = "downloads      ",
          homepage_label = "homepage       ",
          repository_label = "repository     ",
          documentation_label = "documentation  ",
          crates_io_label = "crates.io      ",
          categories_label = "categories     ",
          keywords_label = "keywords       ",
          version = "%s",
          prerelease = "%s pre-release",
          yanked = "%s yanked",
          enabled = "* s",
          transitive = "~ s",
          normal_dependencies_title = "  Dependencies",
          build_dependencies_title = "  Build dependencies",
          dev_dependencies_title = "  Dev dependencies",
          optional = "? %s",
          loading = " ...",
        },
      },
      src = {
        text = {
          prerelease = " pre-release ",
          yanked = " yanked ",
        },
      },
    }
  },
  {
    "stevearc/overseer.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "Civitasv/cmake-tools.nvim",
    cmd = {
      "CMakeGenerate",
      "CMakeBuild",
      "CMakeBuildCurrentFile",
      "CMakeRun",
      "CMakeRunCurrentFile",
      "CMakeDebug",
      "CMakeDebugCurrentFile",
      "CMakeRunTest",
      "CMakeLaunchArgs",
      "CMakeSelectBuildType",
      "CMakeSelectBuildTarget",
      "CMakeSelectLaunchTarget",
      "CMakeSelectKit",
      "CMakeSelectConfigurePreset",
      "CMakeSelectBuildPreset",
      "CMakeSelectCwd",
      "CMakeSelectBuildDir",
      "CMakeOpen",
      "CMakeOpenCache",
      "CMakeClose",
      "CMakeInstall",
      "CMakeClean",
      "CMakeStop",
      "CMakeQuickBuild",
      "CMakeQuickRun",
      "CMakeQuickDebug",
      "CMakeShowTargetFiles",
      "CMakeQuickStart",
      "CMakeSettings",
      "CMakeTargetSettings",
    },
    config = function() require("packages.cmake-tools") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/overseer.nvim",
    }
  },
  {
    "EthanJWright/vs-tasks.nvim",
    name = "vstask",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      telescope_keys = {
        split = "<CR>"
      },
    },
    keys = {
      { "<leader>tl", function() require("telescope").extensions.vstask.launch() end },
    },
  },
  -- File type support
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_toc_config = {
        split_pos = "vert rightbelow",
        split_width = 30,
        show_help = 0,
      }
      if jit.os == "Windows" then
        vim.g.vimtex_view_general_viewer = "SumatraPDF"
        vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      elseif jit.os == "Linux" then
        vim.g.vimtex_view_method = "zathura"
      elseif jit.os == "OSX" then
        vim.g.vimtex_view_method = "skim"
      end
    end
  },
  {
    "vimwiki/vimwiki",
    event = "VeryLazy",
    branch = "dev",
    init = function()
      vim.g.vimwiki_list = {
        {
          path = vim.fs.joinpath(_G._my_core_opt.path.vimwiki),
          path_html = vim.fs.joinpath(_G._my_core_opt.path.vimwiki, "html"),
          syntax = "markdown",
          ext = ".markdown"
        }
      }
      vim.g.vimwiki_folding = "syntax"
      vim.g.vimwiki_filetypes = { "markdown" }
      vim.g.vimwiki_ext2syntax = { [".markdown"] = "markdown" }
    end
  },
  {
    "iamcco/markdown-preview.nvim",
    build = ":call mkdp#util#install()",
    ft = { "markdown", "vimwiki.markdown" },
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "relative",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0
      }
      vim.g.mkdp_filetypes = {
        "markdown",
        "vimwiki.markdown"
      }
    end
  },
  {
    "sotte/presenting.nvim",
    ft = { "markdown", "vimwiki.markdown" },
    cmd = { "Presenting" },
    opts = {
      options = {
        width = 80,
      },
      separator = {
        markdown = "^#+%s",
        ["vimwiki.markdown"] = "^#+%s",
      }
    },
  },
  -- Completion; Snippet; LSP; Treesitter; DAP
  {
    "L3MON4D3/LuaSnip",
    event = "VeryLazy",
    opts = {
      region_check_events = { "CursorMoved", "InsertEnter" },
      delete_check_events = { "TextChanged" },
    }
  },
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    config = function() require("packages.nvim-cmp") end
  },
  {
    "hrsh7th/cmp-buffer",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "hrsh7th/cmp-cmdline",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "hrsh7th/cmp-omni",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "hrsh7th/cmp-path",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "saadparwaiz1/cmp_luasnip",
    event = "VeryLazy",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/nvim-cmp",
    }
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function() require("packages.nvim-lspconfig") end,
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    event = "VeryLazy",
  },
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup {
        ui = {
          border = _G._my_core_opt.tui.border
        }
      }
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = vim.tbl_keys(_G._my_core_opt.lsp),
        automatic_enable = false,
      }
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
    }
  },
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function() require("packages.nvim-dap") end,
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    end,
    keys = {
      { "<leader>dn", function() require("dapui").toggle() end },
      { "<leader>df", function() require("dapui").float_element() end },
      { "<leader>dv", function() require("dapui").eval() end,         mode = "v" },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    config = function()
      local ts_option = _G._my_core_opt.ts or {}
      require("nvim-treesitter.configs").setup {
        ensure_installed = ts_option.ensure_installed or {},
        highlight = {
          enable = true,
          disable = ts_option.highlight_disable or {},
          additional_vim_regex_highlighting = false,
        },
        matchup = {
          enable = true,
          disable = ts_option.matchup_disable or {},
        }
      }
    end
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    opts = {
      backends = {
        ["_"] = { "lsp", "treesitter" },
        markdown = { "markdown" },
      },
      close_automatic_events = {},
      close_on_select = false,
      manage_folds = false,
      filter_kind = {
        ["_"] = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
        },
        lua = {
          "Function",
          "Method",
        },
      },
      nerd_font = false,
      highlight_closest = false,
      on_attach = function(bufnr)
        local _o = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "{", require("aerial").prev, _o)
        vim.keymap.set("n", "}", require("aerial").next, _o)
        vim.keymap.set("n", "[[", require("aerial").prev_up, _o)
        vim.keymap.set("n", "]]", require("aerial").next_up, _o)
        vim.keymap.set("n", "<leader>mv", require("aerial").toggle, _o)
        vim.keymap.set("n", "<leader>fa", "<Cmd>Telescope aerial<CR>", _o)
      end,
      float = {
        border = _G._my_core_opt.tui.border,
        relative = "win",
        min_height = { 8, 0.1 },
        max_height = 0.9,
        height = nil,
        override = function(conf, _) return conf end,
      },
    }
  },
  -- Games
  {
    "alec-gibson/nvim-tetris",
    cmd = "Tetris",
  },
  {
    "seandewar/nvimesweeper",
    cmd = "Nvimesweeper",
  },
}, {
  ui = {
    border = _G._my_core_opt.tui.border,
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
  performance = {
    rtp = {
      reset = false,
      disabled_plugins = _G._my_core_opt.disable,
    }
  }
})

---Filetype.
vim.filetype.add {
  filename = {
    ["Cargo.toml"] = function()
      return "toml", function(bufnr)
        require("cmp").setup.buffer { sources = { { name = "crates" } } }
        local crates = require("crates")
        local kbd = vim.keymap.set
        local _o = { noremap = true, silent = true, buffer = bufnr }
        kbd("n", "K", crates.show_popup, _o)
        kbd("n", "<leader>ct", crates.toggle, _o)
        kbd("n", "<leader>cr", crates.reload, _o)
        kbd("n", "<leader>cv", crates.show_versions_popup, _o)
        kbd("n", "<leader>cf", crates.show_features_popup, _o)
        kbd("n", "<leader>cd", crates.show_dependencies_popup, _o)
        kbd("n", "<leader>cu", crates.update_crate, _o)
        kbd("v", "<leader>cu", crates.update_crates, _o)
        kbd("n", "<leader>ca", crates.update_all_crates, _o)
        kbd("n", "<leader>cU", crates.upgrade_crate, _o)
        kbd("v", "<leader>cU", crates.upgrade_crates, _o)
        kbd("n", "<leader>cA", crates.upgrade_all_crates, _o)
        kbd("n", "<leader>cH", crates.open_homepage, _o)
        kbd("n", "<leader>cR", crates.open_repository, _o)
        kbd("n", "<leader>cD", crates.open_documentation, _o)
        kbd("n", "<leader>cC", crates.open_crates_io, _o)
        crates.show()
      end
    end
  },
}
