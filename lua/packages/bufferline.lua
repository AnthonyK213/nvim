vim.o.showtabline = 2
vim.cmd.packadd("bufferline.nvim")

require("bufferline").setup {
    options = {
        buffer_close_icon = '×',
        modified_icon = '+',
        close_icon = '×',
        left_trunc_marker = '<',
        right_trunc_marker = '>',
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
        sort_by = "extension"
    }
}

vim.keymap.set("n", "<leader>bb", "<Cmd>BufferLinePick<CR>", {
    noremap = true,
    silent = true
})
