local lspconfig = require('lspconfig')
local lsp_option = _my_core_opt.lsp or {}
local kbd = vim.keymap.set
local ntst = { noremap = true, silent = true, buffer = true }
-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
local custom_attach = function (client)
    kbd('n', '<leader>l0', function () vim.lsp.buf.document_symbol() end,  ntst)
    kbd('n', '<leader>la', function () vim.lsp.buf.code_action() end,      ntst)
    kbd('n', '<leader>ld', function () vim.lsp.buf.declaration() end,      ntst)
    kbd('n', '<leader>lf', function () vim.lsp.buf.definition() end,       ntst)
    kbd('n', '<F12>',      function () vim.lsp.buf.definition() end,       ntst)
    kbd('n', '<leader>lh', function () vim.lsp.buf.signature_help() end,   ntst)
    kbd('n', '<leader>li', function () vim.lsp.buf.implementation() end,   ntst)
    kbd('n', '<leader>lm', function () vim.lsp.buf.formatting_sync() end,  ntst)
    kbd('n', '<leader>ln', function () vim.lsp.buf.rename() end,           ntst)
    kbd('n', '<leader>lr', function () vim.lsp.buf.references() end,       ntst)
    kbd('n', '<leader>lt', function () vim.lsp.buf.type_definition() end,  ntst)
    kbd('n', '<leader>lw', function () vim.lsp.buf.workspace_symbol() end, ntst)
    kbd('n', '<leader>l[', function () vim.diagnostic.goto_prev() end,     ntst)
    kbd('n', '<leader>l]', function () vim.diagnostic.goto_next() end,     ntst)
    kbd('n', '<M-K>',      function () vim.diagnostic.open_float() end,    ntst)
    -- aerial.nvim
    require('aerial').on_attach(client)
end
--- clangd
if lsp_option.clangd then
    lspconfig.clangd.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- jedi_language_server
if lsp_option.jedi_language_server then
    lspconfig.jedi_language_server.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- powershell_es
if lsp_option.powershell_es and lsp_option.powershell_es.enable then
    if vim.fn.has("win32") ~= 1 then return end
    local pses_bundle_path = vim.fn.expand(
    lsp_option.powershell_es.path
    or vim.g._my_path_bin.."/LSP/PowerShellEditorServices")
    lspconfig.powershell_es.setup {
        bundle_path = pses_bundle_path,
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- pyright
if lsp_option.pyright then
    lspconfig.pyright.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- rls
if lsp_option.rls then
    lspconfig.rls.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- rust_analyzer
if lsp_option.rust_analyzer then
    lspconfig.rust_analyzer.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- texlab
if lsp_option.texlab then
    lspconfig.texlab.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- omnisharp
if lsp_option.omnisharp then
    local pid = vim.loop.getpid()
    lspconfig.omnisharp.setup {
        cmd = { "OmniSharp", "--languageserver" , "--hostPID", tostring(pid) };
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- sumneko_lua
if lsp_option.sumneko_lua then
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    lspconfig.sumneko_lua.setup {
        capabilities = capabilities,
        on_attach = custom_attach,
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = runtime_path,
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = {
                    enable = false,
                }
            },
        },
    }
end
--- vim script
if lsp_option.vimls then
    lspconfig.vimls.setup {
        capabilities = capabilities,
        on_attach = custom_attach
    }
end
--- Diagnostics
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
}
