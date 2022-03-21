vim.g.vsnip_snippet_dir = vim.fn.stdpath('config')..'/snippet'

local cmp = require('cmp')
local lib = require('utility.lib')
local feedkeys = function (key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key,
    true, true, true), mode, true)
end

cmp.setup {
    completion = {
        keyword_length = 2,
    },

    snippet = {
        expand = function (args)
            vim.fn['vsnip#anonymous'](args.body)
        end
    },

    mapping = {
        ['<CR>'] = cmp.mapping({
            i = function (fallback)
                if cmp.visible() then
                    cmp.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }
                elseif vim.bo.bt ~= 'prompt' then
                    feedkeys('<Plug>(lua_pairs_enter)', '')
                else
                    fallback()
                end
            end,
        }),
        ['<Tab>'] = cmp.mapping({
            i = function (fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.tbl_contains({'vimwiki', 'markdown'}, vim.bo.ft)
                    and vim.regex([[\v^\s*(\+|-|\*|\d+\.|\w\))\s$]]):
                    match_str(lib.get_context('b')) then
                    feedkeys('<C-\\><C-O>>>', 'n')
                    vim.api.nvim_feedkeys(
                    string.rep(vim.g._const_dir_r, vim.bo.ts), 'n', true)
                elseif vim.fn['vsnip#jumpable'](1) == 1 then
                    feedkeys('<Plug>(vsnip-jump-next)', '')
                elseif lib.get_context('b'):match('[%w._:]$')
                    and vim.bo.bt ~= 'prompt' then
                    cmp.complete()
                else
                    fallback()
                end
            end,
            s = function (fallback)
                if vim.fn['vsnip#jumpable'](1) == 1 then
                    feedkeys('<Plug>(vsnip-jump-next)', '')
                else
                    fallback()
                end
            end,
            c = function ()
                if cmp.visible() then
                    cmp.select_next_item({
                        behavior = cmp.SelectBehavior.Insert
                    })
                else
                    cmp.complete()
                end
            end
        }),
        ['<S-Tab>'] = cmp.mapping({
            i = function (fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.fn['vsnip#jumpable'](-1) == 1 then
                    feedkeys('<Plug>(vsnip-jump-prev)', '')
                else
                    fallback()
                end
            end,
            s = function (fallback)
                if vim.fn['vsnip#jumpable'](-1) == 1 then
                    feedkeys('<Plug>(vsnip-jump-prev)', '')
                else
                    fallback()
                end
            end,
            c = function ()
                if cmp.visible() then
                    cmp.select_prev_item({
                        behavior = cmp.SelectBehavior.Insert
                    })
                else
                    cmp.complete()
                end
            end
        })
    },

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'nvim_lua' },
        { name = 'path' },
    }, {
        { name = 'buffer' },
        { name = 'omni' },
    })
}

cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
