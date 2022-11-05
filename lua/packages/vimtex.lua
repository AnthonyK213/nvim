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
