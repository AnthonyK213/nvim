local lspconfig = require('lspconfig')
local lsp_option = require('core.opt').lsp or {}
-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
-- aerial.nvim
local custom_attach = require('aerial').on_attach
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
    lsp_option.powershell_es.path or
    vim.g.path_bin.."/LSP/PowerShellEditorServices")
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
        capabilities = capabilities
    }
end
--- omnisharp
if lsp_option.omnisharp then
    local pid = vim.fn.getpid()
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
--- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics,
{ virtual_text = true, signs = true, update_in_insert = false })


local keymap = vim.api.nvim_set_keymap
local ntst = { noremap = true, silent = true }
keymap('n', 'K', '<cmd>lua require("utility.util").show_doc()<CR>',      ntst)
keymap('n', '<leader>l0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>',  ntst)
keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>',      ntst)
keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.declaration()<CR>',      ntst)
keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.definition()<CR>',       ntst)
keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.signature_help()<CR>',   ntst)
keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>',   ntst)
keymap('n', '<leader>lm', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>',  ntst)
keymap('n', '<leader>ln', '<cmd>lua vim.lsp.buf.rename()<CR>',           ntst)
keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>',       ntst)
keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>',  ntst)
keymap('n', '<leader>lw', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', ntst)
keymap('n', '<leader>l[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', ntst)
keymap('n', '<leader>l]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', ntst)
keymap('n', '<M-K>', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', ntst)
