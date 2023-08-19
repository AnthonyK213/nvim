local bufnr = vim.api.nvim_get_current_buf()

vim.defer_fn(function()
    require("utility.util").new_keymap("n", "<leader>lm", function(fallback)
        local lsps = vim.lsp.get_clients { bufnr = 0 }
        if lsps and #lsps > 0 then
            vim.lsp.buf.format { async = false }
        elseif vim.fn.executable("jq") > 0 then
            vim.cmd [[%!jq .]]
        elseif vim.fn.executable("python") > 0 then
            vim.cmd [[%!python -m json.tool]]
        else
            fallback()
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
