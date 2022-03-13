vim.cmd('packadd tokyonight.nvim')

vim.g.tokyonight_style = core_opt.tui.style or 'storm'
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_sidebars = {
    "help", "qf", "terminal",
    "aerial", "packer",
}

vim.cmd[[colorscheme tokyonight]]
