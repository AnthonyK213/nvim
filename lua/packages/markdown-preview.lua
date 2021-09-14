vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_preview_options = {
    mkit                = {},
    katex               = {},
    uml                 = {},
    maid                = {},
    disable_sync_scroll = 0,
    sync_scroll_type    = 'middle',
    hide_yaml_meta      = 1,
    sequence_diagrams   = {},
    flowchart_diagrams  = {},
    content_editable    = false
}


local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>mt',
'exists(":MarkdownPreviewToggle") ? ":MarkdownPreviewToggle<CR>" : "<ESC>"',
{ expr = true, noremap = true, silent = true })
