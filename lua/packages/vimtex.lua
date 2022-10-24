vim.g.tex_flavor = "latex"
vim.g.vimtex_toc_config = {
    split_pos = "vert rightbelow",
    show_help = 0,
}
if vim.fn.has("win32") == 1 then
    vim.g.vimtex_view_general_viewer = "SumatraPDF"
    vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
elseif vim.fn.has("unix") == 1 then
    vim.g.vimtex_view_method = "zathura"
end
