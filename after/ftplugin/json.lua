local bufnr = vim.api.nvim_get_current_buf()

vim.defer_fn(function()
    require("utility.util").new_keymap("n", "<leader>lm", function()
        if vim.fn.executable("jq") > 0 then
            vim.cmd [[%!jq .]]
        elseif vim.fn.executable("python") > 0 then
            vim.cmd [[%!python -m json.tool]]
        else
            require("utility.lib")
                .notify_err("No available json formatter.")
        end
    end, { noremap = true, silent = true, buffer = bufnr })
end, 500)
