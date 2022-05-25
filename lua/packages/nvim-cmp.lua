vim.g.vsnip_snippet_dir = vim.fn.stdpath('config')..'/snippet'

local cmp = require('cmp')
local lib = require('utility.lib')
local feedkeys = function (key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key,
    true, true, true), mode, true)
end

local cmp_setup = {
    completion = {
        keyword_length = 2,
    },
    snippet = {
        expand = function (args) vim.fn['vsnip#anonymous'](args.body) end
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i'}),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i'}),
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
                local context = lib.get_context()
                if cmp.visible() then
                    cmp.select_next_item {
                        behavior = cmp.SelectBehavior.Insert
                    }
                elseif lib.has_filetype('markdown')
                    and vim.regex([[\v^\s*(\+|-|\*|\d+\.|\w\))\s$]]):
                    match_str(context.b) then
                    feedkeys('<C-\\><C-O>>>', 'n')
                    vim.api.nvim_feedkeys(
                    string.rep(vim.g._const_dir_r, vim.bo.ts), 'n', true)
                elseif vim.fn['vsnip#jumpable'](1) == 1 then
                    feedkeys('<Plug>(vsnip-jump-next)', '')
                elseif context.b:match('[%w._:]$')
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
                    cmp.select_next_item {
                        behavior = cmp.SelectBehavior.Insert
                    }
                else
                    cmp.complete()
                end
            end
        }),
        ['<S-Tab>'] = cmp.mapping({
            i = function (fallback)
                if cmp.visible() then
                    cmp.select_prev_item {
                        behavior = cmp.SelectBehavior.Insert
                    }
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
        { name = 'path' },
    }, {
        { name = 'buffer', keyword_length = 5 },
        { name = 'omni' },
    }),
    experimental = {}
}

if _my_core_opt.tui.cmp_border then
    cmp_setup.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    }
end

if _my_core_opt.tui.cmp_ghost then
    cmp_setup.experimental.ghost_text = true
end

cmp.setup(cmp_setup)

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
