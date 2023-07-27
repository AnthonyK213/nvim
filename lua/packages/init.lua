local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

vim.o.tgc = true
vim.o.bg = _my_core_opt.tui.theme or "dark"
vim.g._my_theme_switchable = false
local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC
local load_optional = nvim_init_src ~= "neatUI" and nvim_init_src ~= "nano"
if nvim_init_src == "nano" then
    vim.g._my_theme_switchable = true
    vim.g.nano_transparent = _my_core_opt.tui.transparent and 1 or 0
    vim.cmd.colorscheme("nanovim")
    _my_core_opt.tui.scheme = "nanovim"
else
    if not vim.list_contains({
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
        cond = function() return _my_core_opt.tui.scheme == "onedark" end,
        config = function() require("packages.onedark") end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        cond = function() return _my_core_opt.tui.scheme == "tokyonight" end,
        config = function() require("packages.tokyonight") end
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        cond = function() return _my_core_opt.tui.scheme == "gruvbox" end,
        config = function() require("packages.gruvbox") end
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        cond = function() return _my_core_opt.tui.scheme == "nightfox" end,
        config = function() require("packages.nightfox") end
    },
    {
        "rmehri01/onenord.nvim",
        lazy = false,
        priority = 1000,
        cond = function() return _my_core_opt.tui.scheme == "onenord" end,
        config = function() require("packages.onenord") end
    },
    -- Optional
    {
        "goolord/alpha-nvim",
        cond = load_optional,
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.header.val = _my_core_opt.tui.welcome_header
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
        cond = load_optional,
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
        "nvim-tree/nvim-web-devicons",
        lazy = false,
        cond = _my_core_opt.tui.devicons,
    },
    {
        "romgrk/barbar.nvim",
        lazy = false,
        cond = load_optional,
        init = function()
            vim.g.barbar_auto_setup = false
            if load_optional then
                vim.o.showtabline = 2
            end
        end,
        opts = {
            animation = _my_core_opt.tui.animation,
            icons = {
                button = "×",
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "E" },
                    [vim.diagnostic.severity.WARN] = { enabled = false },
                    [vim.diagnostic.severity.INFO] = { enabled = false },
                    [vim.diagnostic.severity.HINT] = { enabled = false },
                },
                modified = { button = "●" },
                inactive = { button = "×" },
                filetype = {
                    custom_colors = false,
                    enabled = _my_core_opt.tui.devicons,
                },
            },
            sidebar_filetypes = {
                NvimTree = true,
            },
            maximum_length = 13,
        },
        keys = {
            { "<leader>bb", "<Cmd>BufferPick<CR>" },
            { "<leader>bP", "<Cmd>BufferMovePrevious<CR>" },
            { "<leader>bN", "<Cmd>BufferMoveNext<CR>" },
        }
    },
    {
        "norcalli/nvim-colorizer.lua",
        ft = { "html", "javascript", "json", "typescript", "css", "vue" },
        cond = load_optional,
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
        event = { "VeryLazy", "BufReadPre" },
        cond = load_optional,
        opts = {
            char = "▏",
            context_char = "▏",
            use_treesitter = false,
            space_char_blankline = " ",
            show_current_context = _my_core_opt.tui.show_context,
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
            buftype_exclude = { "help", "quickfix", "terminal", "nofile" },
            filetype_exclude = {
                "aerial", "alpha", "packer", "lazy",
                "markdown", "presenting_markdown",
                "vimwiki", "NvimTree", "mason", "lspinfo",
                "NeogitStatus", "NeogitCommitView", "DiffviewFiles",
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
                file_popup = {
                    open_win_config = {
                        border = _my_core_opt.tui.border,
                    }
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
    -- Git
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
                        ["<C-B>"] = actions.scroll_view(-0.25),
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
                        ["c"] = function()
                            local futures = require("futures")
                            futures.spawn(function()
                                local msg = futures.ui.input { prompt = "Commit" }
                                if not msg or #msg == 0 then return end
                                if futures.ui.input { prompt = "Commit?" } == "y" then
                                    if require("logit").commit(msg):start() then
                                        print("Commiting...")
                                    end
                                end
                            end)
                        end,
                        ["p"] = function()
                            if require("logit").pull():start() then
                                print("Pulling from remote...")
                            end
                        end,
                        ["P"] = function()
                            if require("logit").push():start() then
                                print("Pushing...")
                            end
                        end,
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
                        ["<C-B>"] = actions.scroll_view(-0.25),
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
            { "<leader>gn", "<Cmd>DiffviewOpen<CR>" },
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
        init = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
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
                    title_pos = "center",
                    insert_only = true,
                    anchor = "SW",
                    relative = "cursor",
                    border = _my_core_opt.tui.border,
                    win_options = { winblend = 10, },
                    get_config = function(opts)
                        if opts.kind == "editor" then
                            return { relative = "editor" }
                        end
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
        event = "VeryLazy",
        version = "*",
        keys = {
            { "<leader>gl", function()
                if not require("utility.lib").executable("lazygit") then return end
                require("toggleterm.terminal").Terminal:new {
                    cmd = "lazygit",
                    hidden = true,
                    direction = "float",
                    float_opts = {
                        border = _my_core_opt.tui.border,
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
    "PhilT/vim-fsharp",
    "tikhomirov/vim-glsl",
    -- Completion; Snippet; LSP; Treesitter; DAP
    {
        "hrsh7th/nvim-cmp",
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            -- "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-omni",
            "hrsh7th/cmp-path",
            {
                "L3MON4D3/LuaSnip",
                opts = {
                    region_check_events = { "CursorMoved", "InsertEnter" },
                    delete_check_events = { "TextChanged" },
                }
            },
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
                    -- LSP
                    for name, conf in pairs(_my_core_opt.lsp) do
                        if (type(conf) == "boolean" and conf)
                            or (type(conf) == "table" and conf.load) then
                            local p = require("mason-registry").get_package(mapping[name])
                            if not p:is_installed() then
                                p:install()
                            end
                        end
                    end
                    -- DAP
                    for name, conf in pairs(_my_core_opt.dap) do
                        if conf and name ~= "lldb" then
                            local p = require("mason-registry").get_package(name)
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
                    {
                        "mfussenegger/nvim-dap",
                        config = function() require("packages.nvim-dap") end,
                    },
                }
            }
        }
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        config = function()
            local ts_option = _my_core_opt.ts or {}
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
            reset = false,
            disabled_plugins = _my_core_opt.disable,
        }
    }
})
