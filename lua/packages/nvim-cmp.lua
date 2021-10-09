if vim.fn.has('win32') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$LOCALAPPDATA/nvim/snippet')
elseif vim.fn.has('unix') == 1 then
    vim.g.vsnip_snippet_dir = vim.fn.expand('$HOME/.config/nvim/snippet')
end

local cmp = require('cmp')
local types = require('cmp.types')
local lib = require('utility/lib')
local feedkeys = function (key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key,
    true, true, true), mode, true)
end

cmp.setup {
    completion = {
      autocomplete = {
        types.cmp.TriggerEvent.TextChanged,
      },
      completeopt = 'menu,menuone,noselect',
      keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
      keyword_length = 2,
    },

    snippet = {
        expand = function (args)
            vim.fn['vsnip#anonymous'](args.body)
        end
    },

    mapping = {
        ['<CR>'] = function (fallback)
            if cmp.visible() then
                cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                })()
            elseif vim.bo.bt ~= 'prompt' then
                feedkeys('<Plug>(lua_pairs_enter)', '')
            else
                fallback()
            end
        end,
        ['<ESC>'] = cmp.mapping.abort(),
        ['<TAB>'] = function (fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn.index({'vimwiki', 'markdown'}, vim.bo.ft) >= 0 and
                vim.regex([[\v^\s*(\+|-|\*|\d+\.|\w\))\s$]]):
                match_str(lib.get_context('b')) then
                feedkeys('<C-\\><C-O>>>', 'n')
                vim.api.nvim_feedkeys(
                string.rep(vim.g.const_dir_r, vim.bo.ts), 'n', true)
            elseif vim.fn['vsnip#jumpable'](1) == 1 then
                feedkeys('<Plug>(vsnip-jump-next)', '')
            elseif lib.get_context('b'):match('[%w._:]$') and
                vim.bo.bt ~= 'prompt' then
                cmp.mapping.complete()()
            else
                fallback()
            end
        end,
        ['<S-TAB>'] = function (fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn['vsnip#jumpable'](1) == 1 then
                feedkeys('<Plug>(vsnip-jump-prev)', '')
            else
                fallback()
            end
        end
    },

    sources = {
        { name = 'buffer' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'vsnip' }
    }
}

local keymap = vim.api.nvim_set_keymap
keymap('s', '<TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
keymap('s', '<S-TAB>',
[[vsnip#jumpable(1) ? "<Plug>(vsnip-jump-prev)" : "<Nul>"]],
{ noremap = false, silent = true, expr = true })
