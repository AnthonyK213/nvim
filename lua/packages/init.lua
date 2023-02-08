local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy_path) then
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

vim.o.tgc = true
vim.o.bg = _my_core_opt.tui.theme or "dark"
vim.g._my_theme_switchable = false
local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC
local load_optional = nvim_init_src ~= "neatUI" and nvim_init_src ~= "nano"
if nvim_init_src == "nano" then
    vim.g._my_theme_switchable = true
    vim.cmd.colorscheme("nanovim")
    _my_core_opt.tui.scheme = "nanovim"
else
    if not vim.tbl_contains({
            "onedark", "tokyonight", "gruvbox", "nightfox", "onenord"
        }, _my_core_opt.tui.scheme) then
        if not pcall(vim.cmd.colorscheme, _my_core_opt.tui.scheme) then
            vim.notify("Color scheme was not found.", vim.log.levels.WARN)
        end
    end
end

-- Setup lazy.nvim.
require("lazy").setup({
    -- Color scheme
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        enabled = function() return _my_core_opt.tui.scheme == "onedark" end,
        config = function() require("packages.onedark") end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        enabled = function() return _my_core_opt.tui.scheme == "tokyonight" end,
        config = function() require("packages.tokyonight") end
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        enabled = function() return _my_core_opt.tui.scheme == "gruvbox" end,
        config = function() require("packages.gruvbox") end
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        enabled = function() return _my_core_opt.tui.scheme == "nightfox" end,
        config = function() require("packages.nightfox") end
    },
    {
        "rmehri01/onenord.nvim",
        lazy = false,
        priority = 1000,
        enabled = function() return _my_core_opt.tui.scheme == "onenord" end,
        config = function() require("packages.onenord") end
    },
    -- Optional
    {
        "goolord/alpha-nvim",
        enabled = load_optional,
        config = function()
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
        enabled = load_optional,
        opts = {
            options = {
                theme = "auto",
                section_separators = "",
                component_separators = "",
                icons_enabled = false,
                globalstatus = _my_core_opt.tui.global_statusline
            },
            sections = {
                lualine_a = {
                    function()
                        return ({
                                i = "I", ic = "I", ix = "I",
                                v = "v", V = "V",[""] = "B",
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
        "akinsho/bufferline.nvim",
        lazy = false,
        enabled = load_optional,
        init = function() vim.o.showtabline = 2 end,
        opts = {
            options = {
                right_mouse_command = "",
                middle_mouse_command = "bdelete! %d",
                buffer_close_icon = "×",
                modified_icon = "+",
                close_icon = "×",
                left_trunc_marker = "<",
                right_trunc_marker = ">",
                max_name_length = 18,
                max_prefix_length = 15,
                tab_size = 18,
                ---@type string|boolean
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, _, _, _)
                    return "(" .. count .. ")"
                end,
                custom_filter = function(bufnr, _)
                    local bt = vim.bo[bufnr].bt
                    if not vim.tbl_contains({ "terminal", "quickfix" }, bt) then
                        return true
                    end
                    return false
                end,
                show_buffer_icons = false,
                show_buffer_close_icons = true,
                show_close_icon = false,
                persist_buffer_sort = true,
                separator_style = "thin",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                sort_by = "id"
            }
        },
        keys = {
            { "<leader>bb", "<Cmd>BufferLinePick<CR>" }
        }
    },
    {
        "norcalli/nvim-colorizer.lua",
        ft = { "html", "javascript", "json", "typescript", "css", "vue" },
        enabled = load_optional,
        config = function()
            require("colorizer").setup({
                "html",
                "javascript",
                "json",
                "typescript",
                css = { names = true, rgb_fn = true },
                vue = { names = true, rgb_fn = true },
            }, {
                RGB = true,
                RRGGBB = true,
                names = false,
                RRGGBBAA = false,
                rgb_fn = false,
                hsl_fn = false,
                css = false,
                css_fn = false,
                mode = "background"
            })
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        enabled = load_optional,
        opts = {
            char = "▏",
            context_char = "▏",
            use_treesitter = true,
            space_char_blankline = " ",
            show_current_context = true,
            context_patterns = {
                "class",
                "function",
                "method",
                "^if",
                "^while",
                "^for",
                "^object",
                "^table",
                "block",
                "arguments",
            },
            buftype_exclude = { "help", "quickfix", "terminal" },
            filetype_exclude = {
                "aerial", "alpha", "packer", "lazy",
                "markdown", "presenting_markdown",
                "vimwiki", "NvimTree", "mason", "lspinfo",
                "NeogitCommitView", "DiffviewFiles",
            }
        }
    },
    -- File system
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            disable_netrw = true,
            hijack_cursor = true,
            view = {
                mappings = {
                    custom_only = true,
                    list = {
                        { key = { "<CR>", "<2-LeftMouse>" }, action = "edit" },
                        { key = { "C", "<2-RightMouse>" },   action = "cd" },
                        { key = "<C-J>",                     action = "next_sibling" },
                        { key = "<C-K>",                     action = "prev_sibling" },
                        { key = "<C-R>",                     action = "full_rename" },
                        { key = "<M-Y>",                     action = "copy_absolute_path" },
                        { key = "<M-y>",                     action = "copy_path" },
                        { key = "<S-CR>",                    action = "close_node" },
                        { key = "<Tab>",                     action = "preview" },
                        { key = "D",                         action = "remove" },
                        { key = "H",                         action = "toggle_dotfiles" },
                        { key = "I",                         action = "toggle_ignored" },
                        { key = "R",                         action = "refresh" },
                        { key = "a",                         action = "create" },
                        { key = "c",                         action = "copy" },
                        { key = "gj",                        action = "next_git_item" },
                        { key = "gk",                        action = "prev_git_item" },
                        { key = "i",                         action = "split" },
                        { key = "o",                         action = "system_open" },
                        { key = "p",                         action = "paste" },
                        { key = "q",                         action = "close" },
                        { key = "r",                         action = "rename" },
                        { key = "s",                         action = "vsplit" },
                        { key = "t",                         action = "tabnew" },
                        { key = "u",                         action = "dir_up" },
                        { key = "x",                         action = "cut" },
                        { key = "y",                         action = "copy_name" },
                    }
                }
            },
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
                update_cwd = false,
                ignore_list = {},
            },
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
                open_file = {
                    quit_on_open = false,
                    resize_window = false,
                    window_picker = {
                        enable = true,
                        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                        exclude = {
                            filetype = {
                                "notify", "qf", "help",
                                "packer", "aerial"
                            },
                            buftype = {
                                "terminal"
                            }
                        }
                    }
                }
            }
        },
        keys = {
            { "<leader>op", "<Cmd>NvimTreeToggle<CR>" },
            { "<M-e>",      "<Cmd>NvimTreeFindFile<CR>" },
            { "<M-e>",      "<Cmd>NvimTreeFindFile<CR>", mode = "i" },
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        config = function()
            local border_style = _my_core_opt.tui.border
            local border_styles = {
                single = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                double = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
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
                    borderchars = border_styles[border_style] or border_styles["rounded"]
                },
                extensions = {
                    aerial = {
                        show_nesting = {
                            ["_"] = false,
                            json = true,
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
    -- VCS
    {
        "TimUntersberger/neogit",
        opts = {
            integrations = {
                diffview = true
            }
        },
        commit = "05386ff1e9da447d4688525d64f7611c863f05ca",
        enabled = function() return _my_core_opt.vcs.client == "neogit" end,
        keys = {
            { "<leader>gn", "<Cmd>Neogit<CR>" }
        }
    },
    {
        "sindrets/diffview.nvim",
        config = function()
            local actions = require("diffview.actions")
            require("diffview").setup {
                use_icons = false,
                icons = {
                    folder_closed = ">",
                    folder_open = "v",
                },
                signs = {
                    fold_closed = ">",
                    fold_open = "v",
                    done = "✓",
                },
                keymaps = {
                    disable_defaults = true,
                    view = {
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["gf"] = actions.goto_file,
                        ["<C-W><C-F>"] = actions.goto_file_split,
                        ["<C-W>gf"] = actions.goto_file_tab,
                        ["<localleader>e"] = actions.focus_files,
                        ["<localleader>b"] = actions.toggle_files,
                        ["g<C-X>"] = actions.cycle_layout,
                        ["[x"] = actions.prev_conflict,
                        ["]x"] = actions.next_conflict,
                        ["<localleader>co"] = actions.conflict_choose("ours"),
                        ["<localleader>ct"] = actions.conflict_choose("theirs"),
                        ["<localleader>cb"] = actions.conflict_choose("base"),
                        ["<localleader>ca"] = actions.conflict_choose("all"),
                        ["dx"] = actions.conflict_choose("none"),
                        ["q"] = "<Cmd>DiffviewClose<CR>",
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
                        ["j"] = actions.next_entry,
                        ["<Down>"] = actions.next_entry,
                        ["k"] = actions.prev_entry,
                        ["<Up>"] = actions.prev_entry,
                        ["<Cr>"] = actions.select_entry,
                        ["o"] = actions.select_entry,
                        ["<2-LeftMouse>"] = actions.select_entry,
                        ["-"] = actions.toggle_stage_entry,
                        ["S"] = actions.stage_all,
                        ["U"] = actions.unstage_all,
                        ["X"] = actions.restore_entry,
                        ["L"] = actions.open_commit_log,
                        ["<C-B>"] = actions.scroll_view( -0.25),
                        ["<C-F>"] = actions.scroll_view(0.25),
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["gf"] = actions.goto_file,
                        ["<C-W><C-F>"] = actions.goto_file_split,
                        ["<C-W>gf"] = actions.goto_file_tab,
                        ["i"] = actions.listing_style,
                        ["f"] = actions.toggle_flatten_dirs,
                        ["R"] = actions.refresh_files,
                        ["<localleader>e"] = actions.focus_files,
                        ["<localleader>b"] = actions.toggle_files,
                        ["g<C-X>"] = actions.cycle_layout,
                        ["[x"] = actions.prev_conflict,
                        ["]x"] = actions.next_conflict,
                        ["q"] = "<Cmd>DiffviewClose<CR>",
                    },
                    file_history_panel = {
                        ["g!"] = actions.options,
                        ["<C-M-d>"] = actions.open_in_diffview,
                        ["y"] = actions.copy_hash,
                        ["L"] = actions.open_commit_log,
                        ["zR"] = actions.open_all_folds,
                        ["zM"] = actions.close_all_folds,
                        ["j"] = actions.next_entry,
                        ["<Down>"] = actions.next_entry,
                        ["k"] = actions.prev_entry,
                        ["<Up>"] = actions.prev_entry,
                        ["<Cr>"] = actions.select_entry,
                        ["o"] = actions.select_entry,
                        ["<2-LeftMouse>"] = actions.select_entry,
                        ["<C-B>"] = actions.scroll_view( -0.25),
                        ["<C-F>"] = actions.scroll_view(0.25),
                        ["<Tab>"] = actions.select_next_entry,
                        ["<S-Tab>"] = actions.select_prev_entry,
                        ["gf"] = actions.goto_file,
                        ["<C-W><C-F>"] = actions.goto_file_split,
                        ["<C-W>gf"] = actions.goto_file_tab,
                        ["<localleader>e"] = actions.focus_files,
                        ["<localleader>b"] = actions.toggle_files,
                        ["g<C-X>"] = actions.cycle_layout,
                        ["q"] = "<Cmd>DiffviewClose<CR>",
                    },
                    option_panel = {
                        ["<Tab>"] = actions.select_entry,
                        ["q"] = actions.close,
                    },
                },
            }
        end,
        keys = {
            { "<leader>gd", "<Cmd>DiffviewOpen<CR>" },
            { "<leader>gh", "<Cmd>DiffviewFileHistory<CR>" },
        }
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            signs = {
                add = {
                    hl = "GitSignsAdd",
                    text = "│",
                    numhl = "GitSignsAddNr",
                    linehl = "GitSignsAddLn"
                },
                change = {
                    hl = "GitSignsChange",
                    text = "│",
                    numhl = "GitSignsChangeNr",
                    linehl = "GitSignsChangeLn"
                },
                delete = {
                    hl = "GitSignsDelete",
                    text = "_",
                    numhl = "GitSignsDeleteNr",
                    linehl = "GitSignsDeleteLn"
                },
                topdelete = {
                    hl = "GitSignsDelete",
                    text = "‾",
                    numhl = "GitSignsDeleteNr",
                    linehl = "GitSignsDeleteLn"
                },
                changedelete = {
                    hl = "GitSignsChange",
                    text = "~",
                    numhl = "GitSignsChangeNr",
                    linehl = "GitSignsChangeLn"
                },
            },
            numhl = false,
            linehl = false,
            watch_gitdir = {
                interval = 1000
            },
            current_line_blame = false,
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil,
            preview_config = {
                border = _my_core_opt.tui.border,
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1
            },
            on_attach = function(bufnr)
                local _o = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "<leader>gj", require("gitsigns").next_hunk, _o)
                vim.keymap.set("n", "<leader>gk", require("gitsigns").prev_hunk, _o)
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
        }
    },
    {
        "AnthonyK213/lua-pairs",
        event = "InsertEnter",
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
                            return not require("utility.syn").new(0, row, col):match {
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
            local border_style = _my_core_opt.tui.border
            local border_styles = {
                single = {
                    prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                    results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
                    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                },
                double = {
                    prompt = { "═", "║", " ", "║", "╔", "╗", "║", "║" },
                    results = { "═", "║", "═", "║", "╠", "╣", "╝", "╚" },
                    preview = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" },
                },
                rounded = {
                    prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                    results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                },
            }

            require("dressing").setup {
                input = {
                    default_prompt = "> ",
                    insert_only = true,
                    anchor = "SW",
                    relative = "cursor",
                    border = _my_core_opt.tui.border,
                    win_options = {
                        winblend = 10,
                    },
                    get_config = nil,
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
        event = "VeryLazy",
        version = "*",
        config = function()
            if _my_core_opt.vcs.client == "lazygit" then
                vim.keymap.set("n", "<leader>gn", function()
                    if not require("utility.lib").executable("lazygit") then return end
                    require("toggleterm.terminal").Terminal:new {
                        cmd = "lazygit",
                        hidden = true,
                        direction = "float",
                        float_opts = {
                            border = _my_core_opt.tui.border,
                        },
                    }:toggle()
                end, { noremap = true, silent = true })
            end
        end
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
                border = _my_core_opt.tui.border,
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
    -- File type support
    {
        "lervag/vimtex",
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
            end
        end
    },
    {
        "vimwiki/vimwiki",
        branch = "dev",
        init = function()
            vim.g.vimwiki_list = {
                {
                    path = require("utility.lib").path_append(_my_core_opt.path.cloud, "/Notes/"),
                    path_html = require("utility.lib").path_append(_my_core_opt.path.cloud, "/Notes/html/"),
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
        build = function() vim.fn["mkdp#util#install"]() end,
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
                "vimwiki",
                "vimwiki.markdown"
            }
        end
    },
    "sotte/presenting.vim",
    {
        "gpanders/editorconfig.nvim",
        event = "VeryLazy",
    },
    "PhilT/vim-fsharp",
    -- Completion; Snippet; LSP; Treesitter; DAP
    {
        "hrsh7th/nvim-cmp",
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-omni",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function() require("packages.nvim-cmp") end
    },
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        config = function() require("packages.nvim-lspconfig") end,
        dependencies = {
            {
                "williamboman/mason.nvim",
                cmd = "Mason",
                config = function()
                    require("mason").setup { ui = { border = _my_core_opt.tui.border } }
                    local mapping = require("mason-lspconfig.mappings.server").lspconfig_to_package
                    for name, conf in pairs(_my_core_opt.lsp) do
                        if (type(conf) == "boolean" and conf)
                            or (type(conf) == "table" and conf.load) then
                            local p = require("mason-registry").get_package(mapping[name])
                            if not p:is_installed() then
                                p:install()
                            end
                        end
                    end
                end,
            },
            {
                "williamboman/mason-lspconfig.nvim",
                config = true,
            },
            "Hoffs/omnisharp-extended-lsp.nvim",
        }
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        config = function()
            local ts_option = _my_core_opt.ts or {}
            require("nvim-treesitter.configs").setup {
                ensure_installed = ts_option.ensure or {},
                highlight = {
                    enable = true,
                    disable = ts_option.hi_disable or {},
                    additional_vim_regex_highlighting = false,
                },
                matchup = {
                    enable = true,
                    disable = {}
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
                markdown = { "markdown" }
            },
            close_automatic_events = {},
            close_on_select = true,
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
                border = _my_core_opt.tui.border,
                relative = "win",
                min_height = { 8, 0.1 },
                max_height = 0.9,
                height = nil,
                override = function(conf, _) return conf end,
            },
        }
    },
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        config = function() require("packages.nvim-dap") end
    },
    -- Games
    {
        "alec-gibson/nvim-tetris",
        event = "VeryLazy",
    },
}, {
    ui = {
        border = _my_core_opt.tui.border,
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
            disabled_plugins = _my_core_opt.disable
        }
    }
})
