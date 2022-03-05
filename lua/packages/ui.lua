-- colorscheme
vim.cmd('packadd onedark.nvim')
require('onedark').setup  {
    style = core_opt.tui.style,
    transparent = core_opt.tui.transparent,
    term_colors = true,
    ending_tildes = false,
    toggle_style_key = '<leader>bs',
    toggle_style_list = {
        'dark', 'darker', 'cool',
        'deep', 'warm', 'warmer',
        'light'
    },
    code_style = {
        comments = 'italic',
        keywords = 'none',
        functions = 'none',
        strings = 'none',
        variables = 'none'
    },
    colors = {},
    highlights = {
        FloatBorder = { fg = '$cyan' },
        SpellBad = { fg = '$red', fmt = 'underline' },
        SpellCap = { fg = '$yellow', fmt = 'underline' },
        markdownH1 =               { fg = '$red', fmt = 'bold' },
        markdownH2 =               { fg = '$red', fmt = 'bold' },
        markdownH3 =               { fg = '$red', fmt = 'bold' },
        markdownH4 =               { fg = '$red' },
        markdownH5 =               { fg = '$red' },
        markdownH6 =               { fg = '$red' },
        markdownHeadingDelimiter = { fg = '$red', fmt = 'bold' },
        markdownUrl =              { fg = '$blue' },
        markdownBold =             { fg = '$yellow', fmt = 'bold' },
        markdownCode =             { fg = '$green' },
        markdownItalic =           { fg = '$purple', fmt = 'italic' },
        markdownCodeDelimiter =    { fg = '$bg3' },
        markdownLinkText =         { fg = '$cyan', fmt = 'underline' },
        markdownTSEmphasis =       { fg = '$purple', fmt = 'italic' },
        markdownTSLiteral =        { fg = '$green' },
        markdownTSNone =           { fg = '$light_grey' },
        markdownTSPunctSpecial =   { fg = '$red' },
        markdownTSPunctDelimiter = { fg = '$bg3' },
        markdownTSStringEscape =   { fg = '$cyan', fmt = 'bold' },
        markdownTSStrong =         { fg = '$yellow', fmt = 'bold' },
        markdownTSTextReference =  { fg = '$cyan', fmt = 'underline' },
        markdownTSTitle =          { fg = '$red', fmt = 'bold' },
        markdownTSURI =            { fg = '$blue' },
    },
    diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
    },
}


-- lualine.nvim
vim.cmd('packadd lualine.nvim')
local mode_alias = {
    i = 'I', ic  = 'I', ix     = 'I',
    v = 'v', V   = 'V', [''] = 'B',
    n = 'N', niI = 'Ĩ', no = 'N', nt = 'N',
    R = 'R', Rv = 'R',
    s = 's', S  = 'S',
    c = 'C', t  = 'T',
    multi = 'M',
}
require('lualine').setup {
    options = {
        theme = 'onedark',
        section_separators = '',
        component_separators = '',
        icons_enabled = false
    },
    sections = {
        lualine_a = {function()
            return mode_alias[vim.api.nvim_get_mode().mode] or '_'
        end},
        lualine_b = {'branch'},
        lualine_c = {{'filename', path=2}, {'aerial', sep=' >> '}, 'diff'
        },
        lualine_x = {{'diagnostics', sources={'nvim_diagnostic'}}, 'filetype'},
        lualine_y = {'encoding', 'fileformat'},
        lualine_z = {'progress', 'location'},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {},
    },
    extensions = {'nvim-tree', 'quickfix'}
}


-- nvim-bufferline.lua
vim.o.showtabline = 2
vim.cmd('packadd bufferline.nvim')
require('bufferline').setup {
    options = {
        buffer_close_icon= '×',
        modified_icon = '+',
        close_icon = '×',
        left_trunc_marker = '<',
        right_trunc_marker = '>',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,

        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count) return "("..count..")" end,

        custom_filter = function(buf_number)
            local bt = vim.bo[buf_number].bt
            if not vim.tbl_contains({ 'terminal', 'quickfix' }, bt) then
                return true
            end
        end,

        show_buffer_icons = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = 'extension'
    }
}
vim.keymap.set('n', '<leader>bb', function ()
    vim.cmd('BufferLinePick')
end, { noremap = true, silent = true })


-- nvim-colorizer
vim.cmd('packadd nvim-colorizer.lua')
require('colorizer').setup()
vim.api.nvim_add_user_command('ColorizerReset', function (_)
    package.loaded["colorizer"] = nil
    require("colorizer").setup()
    require("colorizer").attach_to_buffer(0)
end, {})


-- alpha-nvim
vim.cmd('packadd alpha-nvim')
local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')
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
    dashboard.button("e", "  Empty File" ,  ":enew<CR>"),
    dashboard.button("f", "⊕  Find File",    ":Telescope find_files<CR>"),
    dashboard.button("s", "  Load Session", ":SessionManager load_session<CR>"),
    dashboard.button(",", "⚙  Options",      ":call usr#misc#open_opt()<CR>"),
    dashboard.button("p", "⟲  Packer Sync",  ":PackerSync<CR>"),
    dashboard.button("q", "⊗  Quit Nvim",    ":qa<CR>"),
}
alpha.setup(dashboard.opts)


-- Setting colorscheme.
require('onedark').load()
