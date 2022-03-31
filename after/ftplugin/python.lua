vim.cmd[[setlocal tabstop=4 shiftwidth=4 softtabstop=4]]

local lib = require('utility.lib')
local buf_handle = vim.api.nvim_get_current_buf()

local function feedkeys(keys, mode, escape_ks)
    local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(k, mode, escape_ks)
end

vim.defer_fn(function ()
    local buf_kbd_list = vim.api.nvim_buf_get_keymap(buf_handle, "i")
    local fallback

    for _, val in ipairs(buf_kbd_list) do
        if val["lhs"] == '"' then
            if val["rhs"] then
                fallback = val["rhs"]
            elseif val["callback"] then
                fallback = val["callback"]
            end
        end
    end

    vim.keymap.set('i', '"', function ()
        if lib.get_context('b'):match('^%s*""$') then
            feedkeys('"\n"""<C-\\><C-O>O', 'n', true)
        elseif fallback then
            if type(fallback) == "string" then
                feedkeys(fallback, 'n', true)
            elseif type(fallback) == "function" then
                fallback()
            end
        else
            vim.api.nvim_feedkeys('"', 'n', true)
        end
    end, { noremap = true, silent = true, buffer = buf_handle })
end, 500)
