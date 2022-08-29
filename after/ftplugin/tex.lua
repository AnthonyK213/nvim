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

local _opt = { noremap = true, silent = true, buffer = true }
local srd_table = {
    I = { { "\\textit{", "}" }, [[\vtexStyle(Ital|Both)]] },
    B = { { "\\textbf{", "}" }, [[\vtexStyleBo(ld|th)]] },
}

vim.keymap.set("n", "<leader>mv", "<Cmd>VimtexTocToggle<CR>", _opt)
vim.keymap.set("n", "<leader>mt", "<Cmd>Pdf<CR>", _opt)
for key, val in pairs(srd_table) do
    vim.keymap.set({ "n", "v" }, "<M-" .. key .. ">", function()
        local m = vim.api.nvim_get_mode().mode
        local mode
        if m == "n" then mode = "n"
        elseif vim.tbl_contains({ "v", "V", "" }, m) then mode = "v"
        else return end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
        if require("utility.syn").match_here(val[2]) then
            require("utility.srd").srd_sub("", val[1])
        else
            require("utility.srd").srd_add(mode, val[1])
        end
    end, _opt)
end
