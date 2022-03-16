vim.cmd('packadd tokyonight.nvim')


vim.g.tokyonight_style = _my_core_opt.tui.style or 'storm'
vim.g.tokyonight_transparent = _my_core_opt.tui.transparent
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_sidebars = {
    "help", "qf", "terminal",
    "aerial", "packer",
}
vim.g.tokyonight_colors = {}


vim.cmd[[colorscheme tokyonight]]
