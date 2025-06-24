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

local tui_ = require("internal.tui")
local load_3rd_ui = tui_.load_3rd_ui()
tui_.set_color_scheme { "gruvbox", "nightfox" }

-- Setup lazy.nvim.
require("lazy").setup({
  -- UI
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 2000,
    cond = function() return _G._my_core_opt.tui.scheme == "gruvbox" end,
    config = function() require("packages.gruvbox-conf") end
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 2000,
    cond = function() return _G._my_core_opt.tui.scheme == "nightfox" end,
    config = function() require("packages.nightfox-conf") end
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    priority = 1500,
    cond = load_3rd_ui,
    opts = {
      options = {
        theme                = "auto",
        section_separators   = "",
        component_separators = "",
        icons_enabled        = _G._my_core_opt.tui.devicons,
        globalstatus         = _G._my_core_opt.tui.global_statusline
      },
      sections = {
        lualine_a = {
          { "mode", fmt = function(str) return str:sub(1, 1) end }
        },
        lualine_b = { { "b:gitsigns_head", icon = "" }, },
        lualine_c = {
          { "filename", path = 2 },
          -- { "aerial",   sep = "::" },
          {
            "diff",
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added    = gitsigns.added,
                  modified = gitsigns.changed,
                  removed  = gitsigns.removed
                }
              end
            end
          }
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
      extensions = {
        "aerial",
        "lazy",
        "mason",
        "nvim-dap-ui",
        "nvim-tree",
        "overseer",
        "quickfix",
        "toggleterm",
      }
    }
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    priority = 1500,
    cond = load_3rd_ui,
    init = function() vim.o.showtabline = 2 end,
    opts = {
      options = {
        themable = true,
        right_mouse_command = "",
        middle_mouse_command = "bdelete! %d",
        indicator = {
          icon  = "▍",
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
            filetype   = "NvimTree",
            text       = "File Explorer",
            text_align = "left",
            separator  = true,
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
        -- groups = {
        -- options = {
        -- toggle_hidden_on_enter = true
        -- },
        -- items = {
        -- {
        -- name       = "Docs",
        -- highlight  = { sp = "cyan" },
        -- auto_close = false,
        -- matcher    = function(buf)
        -- return buf.name:match("%.md")
        -- or buf.name:match("%.txt")
        -- end,
        -- }
        -- }
        -- }
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
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        input = {
          border = _G._my_core_opt.tui.border,
        },
      },
      bigfile = { enabled = true },
      dashboard = load_3rd_ui and require("packages.snacks-dashboard-conf") or nil,
      input = require("packages.snacks-input-conf"),
      picker = require("packages.snacks-picker-conf"),
    },
    keys = {
      { "<leader>fb", function() require("snacks").picker.buffers() end },
      { "<leader>ff", function() require("snacks").picker.files() end },
      { "<leader>fg", function() require("snacks").picker.grep() end },
      { "<leader>fu", function() require("snacks").picker.undo() end },
    }
  },
  {
    "norcalli/nvim-colorizer.lua",
    cmd = {
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
      "ColorizerToggle",
    },
    ft = { "html", "css", "vue" },
    cond = load_3rd_ui,
    config = function()
      require("colorizer").setup({
        "html",
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
    event = { "BufReadPre", "BufNewFile" },
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
        enabled            = true,
        show_start         = false,
        show_end           = false,
        injected_languages = false,
        priority           = 500,
      },
      exclude = {
        filetypes = {
          "aerial", "snacks_dashboard", "lazy",
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
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    cond = _G._my_core_opt.tui.devicons,
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
        local o = { buffer = bufnr, noremap = true, silent = true, nowait = true }
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
        k("n", "bD", n.marks.bulk.delete, o)
        k("n", "bdd", n.marks.bulk.trash, o)
        k("n", "bm", n.marks.bulk.move, o)
        k("n", "c", n.fs.copy.node, o)
        k("n", "dd", n.fs.trash, o)
        k("n", "gj", n.node.navigate.git.next, o)
        k("n", "gk", n.node.navigate.git.prev, o)
        k("n", "i", n.node.open.horizontal, o)
        k("n", "m", n.marks.toggle, o)
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
            edge   = "│ ",
            none   = "  ",
          },
        },
        icons = {
          show = {
            file         = true,
            folder       = true,
            folder_arrow = false,
            git          = true,
          },
          glyphs = {
            default = "▪ ",
            symlink = "▫ ",
            folder = {
              default      = "+",
              open         = "-",
              empty        = "*",
              empty_open   = "*",
              symlink      = "@",
              symlink_open = "@",
            },
            git = {
              unstaged  = "✗",
              staged    = "✓",
              unmerged  = "U",
              renamed   = "➜",
              untracked = "★",
              deleted   = "D",
              ignored   = "◌"
            },
          }
        },
      },
      update_focused_file = {
        enable = false,
        update_root = {
          enable      = false,
          ignore_list = {},
        },
        exclude = false,
      },
      system_open = require("utility.util").sys_open_config(),
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = {
          hint    = "!",
          info    = "I",
          warning = "W",
          error   = "E"
        }
      },
      filters = {
        dotfiles = true,
        custom   = { ".cache" }
      },
      git = {
        enable  = true,
        ignore  = false,
        timeout = 400
      },
      filesystem_watchers = {
        enable         = false,
        debounce_delay = 50,
        ignore_dirs    = {},
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
  -- VCS
  {
    "NeogitOrg/neogit",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
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
    event = "BufRead",
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
      { "<C-A>",  "<Plug>(dial-increment)",                                mode = { "n", "x" } },
      { "<C-X>",  "<Plug>(dial-decrement)",                                mode = { "n", "x" } },
      { "g<C-A>", function() return require("dial.map").inc_gvisual() end, mode = "x",         expr = true },
      { "g<C-X>", function() return require("dial.map").dec_gvisual() end, mode = "x",         expr = true },
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
      extend = {
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
        filetype = { "snacks_input" },
      },
    }
  },
  {
    "andymass/vim-matchup",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_deferred_show_delay = 100
      vim.g.matchup_matchparen_deferred_hide_delay = 700
      -- NOTE: Look forward to the [new vim-matchup integration](https://github.com/andymass/vim-matchup/pull/330)
    end,
  },
  {
    "Shatur/neovim-session-manager",
    cmd = "SessionManager",
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
    "saecki/crates.nvim",
    tag = "stable",
    event = "BufRead Cargo.toml",
    config = function()
      local crates = require("crates")
      local option = {
        popup = {
          border = _G._my_core_opt.tui.border,
        },
        lsp = {
          enabled = true,
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "K", crates.show_popup, {
              noremap = true,
              silent = true,
              buffer = bufnr
            })
          end,
          actions = true,
          completion = true,
          hover = true,
        }
      }

      if not _G._my_core_opt.tui.devicons then
        option.text = {
          loading    = "  Loading...",
          version    = "  %s",
          prerelease = "  %s",
          yanked     = "  %s yanked",
          nomatch    = "  Not found",
          upgrade    = "  %s",
          error      = "  Error fetching crate",
        }
        option.popup.text = {
          title                     = "# %s",
          pill_left                 = "",
          pill_right                = "",
          created_label             = "created        ",
          updated_label             = "updated        ",
          downloads_label           = "downloads      ",
          homepage_label            = "homepage       ",
          repository_label          = "repository     ",
          documentation_label       = "documentation  ",
          crates_io_label           = "crates.io      ",
          lib_rs_label              = "lib.rs         ",
          categories_label          = "categories     ",
          keywords_label            = "keywords       ",
          version                   = "%s",
          prerelease                = "%s pre-release",
          yanked                    = "%s yanked",
          enabled                   = "* s",
          transitive                = "~ s",
          normal_dependencies_title = "  Dependencies",
          build_dependencies_title  = "  Build dependencies",
          dev_dependencies_title    = "  Dev dependencies",
          optional                  = "? %s",
          loading                   = " ...",
        }
        option.completion = {
          text = {
            prerelease = " pre-release ",
            yanked     = " yanked ",
          }
        }
      end

      crates.setup(option)
    end
  },
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache",
    },
    opts = {
      dap = false,
    },
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
    config = function() require("packages.cmake-tools-conf") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/overseer.nvim",
      "akinsho/toggleterm.nvim",
      "mfussenegger/nvim-dap",
    }
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
    cmd = { "VimwikiIndex", "VimwikiDiaryIndex", },
    ft = "vimwiki.markdown",
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
      keep_separator = false,
      separator = {
        markdown             = "^%-%-%-",
        ["vimwiki.markdown"] = "^%-%-%-",
      }
    },
  },
  -- Completion; LSP; DAP; Treesitter
  {
    "hrsh7th/nvim-cmp",
    event = { "BufReadPre", "BufNewFile", "CmdlineEnter" },
    config = function() require("packages.nvim-cmp-conf") end,
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-path",
      {
        "saadparwaiz1/cmp_luasnip",
        dependencies = {
          {
            "L3MON4D3/LuaSnip",
            opts = {
              region_check_events = { "CursorMoved", "InsertEnter" },
              delete_check_events = { "TextChanged" },
            }
          },
        }
      },
    }
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
    "neovim/nvim-lspconfig",
    -- NO VeryLazy!
    config = function() require("packages.nvim-lspconfig-conf") end,
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        config = function()
          require("mason-lspconfig").setup {
            ensure_installed = vim.tbl_keys(_G._my_core_opt.lsp),
            automatic_enable = false,
          }
        end,
        dependencies = {
          "mason-org/mason.nvim",
        }
      },
    }
  },
  {
    "mfussenegger/nvim-dap",
    cmd = {
      "DapContinue",
      "DapDisconnect",
      "DapNew",
      "DapTerminate",
      "DapRestartFrame",
      "DapStepInto",
      "DapStepOut",
      "DapStepOver",
      "DapPause",
      "DapEval",
      "DapToggleRepl",
      "DapClearBreakpoints",
      "DapToggleBreakpoint",
      "DapSetLogLevel",
      "DapShowLog",
    },
    config = function() require("packages.nvim-dap-conf") end,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
          require("mason-nvim-dap").setup {
            ensure_installed = vim.tbl_keys(_G._my_core_opt.dap),
            automatic_installation = false,
          }
        end,
        dependencies = {
          "mason-org/mason.nvim",
        }
      },
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
    keys = {
      { "<F5>",       function() require("dap").continue() end },
      { "<F10>",      function() require("dap").step_over() end },
      { "<F23>",      function() require("dap").step_into() end },
      { "<S-F11>",    function() require("dap").step_into() end },
      { "<F47>",      function() require("dap").step_out() end },
      { "<S-C-F11>",  function() require("dap").step_out() end },
      { "<leader>db", function() require("dap").toggle_breakpoint() end },
      { "<leader>dc", function() require("dap").clear_breakpoints() end },
      { "<leader>dl", function() require("dap").run_last() end },
      { "<leader>dr", function() require("dap").repl.toggle() end },
      { "<leader>dt", function() require("dap").terminate() end },
      { "<leader>dn", function() require("dapui").toggle() end },
      { "<leader>df", function() require("dapui").float_element() end },
      { "<leader>dv", function() require("dapui").eval() end,           mode = "x" },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "master",
    config = function()
      local ts_option = _G._my_core_opt.ts or {}
      require("nvim-treesitter.configs").setup {
        ensure_installed = ts_option.ensure_installed or {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        matchup = {
          enable = true,
        }
      }
    end
    -- branch = "main",
    -- config = function() require("packages.nvim-treesitter-conf") end
  },
  {
    "stevearc/aerial.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      backends = {
        ["_"]    = { "lsp", "treesitter" },
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
        local opt = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "{", require("aerial").prev, opt)
        vim.keymap.set("n", "}", require("aerial").next, opt)
        vim.keymap.set("n", "[[", require("aerial").prev_up, opt)
        vim.keymap.set("n", "]]", require("aerial").next_up, opt)
        vim.keymap.set("n", "<leader>mv", require("aerial").toggle, opt)
        vim.keymap.set("n", "<leader>fa", require("aerial").snacks_picker, opt)
      end,
      float = {
        border     = _G._my_core_opt.tui.border,
        relative   = "win",
        min_height = { 8, 0.1 },
        max_height = 0.9,
        height     = nil,
        override   = function(conf, _) return conf end,
      },
    },
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
      cmd     = "⌘",
      config  = "🛠",
      event   = "📅",
      ft      = "📂",
      init    = "⚙",
      keys    = "🗝",
      plugin  = "🔌",
      runtime = "💻",
      source  = "📄",
      start   = "🚀",
      task    = "📌",
      lazy    = "💤 ",
    },
  },
  performance = {
    rtp = {
      reset = false,
      disabled_plugins = _G._my_core_opt.disable,
    }
  }
})
