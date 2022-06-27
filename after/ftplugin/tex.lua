require("cmp").setup.buffer {
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end,
    },
    sources = {
        { name = "vsnip" },
        { name = "omni" },
        { name = "buffer" },
        { name = "path" },
    },
}

vim.keymap.set("n", "<leader>mv", "<Cmd>VimtexTocToggle<CR>", {
    noremap = true,
    silent = true,
    buffer = true
})
