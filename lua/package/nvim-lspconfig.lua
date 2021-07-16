local lspconfig = require('lspconfig')
local lsp_option = require('core/opt').lsp or {}
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
    }
}
--- clangd
if lsp_option.clangd then
    lspconfig.clangd.setup {
        capabilities = capabilities
    }
end
--- jedi_language_server
if lsp_option.jedi_language_server then
    lspconfig.jedi_language_server.setup {
        capabilities = capabilities
    }
end
--- pyright
if lsp_option.pyright then
    lspconfig.pyright.setup {
        capabilities = capabilities
    }
end
--- rls
if lsp_option.rls then
    lspconfig.rls.setup {}
end
--- rust_analyzer
if lsp_option.rust_analyzer then
    lspconfig.rust_analyzer.setup {
        capabilities = capabilities
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
    }
end
--- sumneko_lua
if lsp_option.sumneko_lua and lsp_option.sumneko_lua.enable then
    local system_name, sumneko_root_path
    if vim.fn.has("mac") == 1 then
        system_name = "macOS"
        sumneko_root_path = "path"
    elseif vim.fn.has("unix") == 1 then
        system_name = "Linux"
        sumneko_root_path = vim.fn.expand(
        lsp_option.sumneko_lua.path or
        "$HOME/.local/bin/lua-language-server")
    elseif vim.fn.has('win32') == 1 then
        system_name = "Windows"
        sumneko_root_path = vim.fn.expand(
        lsp_option.sumneko_lua.path or
        "D:/Env/LSP/lua-language-server")
    else
        print("Unsupported system for sumneko.")
    end
    local sumneko_binary = sumneko_root_path..
    "/bin/"..system_name.."/lua-language-server"
    lspconfig.sumneko_lua.setup {
        cmd = { sumneko_binary, '-E', sumneko_root_path.."/main.lua" };
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = vim.split(package.path, ';'),
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = {
                        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                    },
                },
            },
        },
    }
end
--- vim script
if lsp_option.vimls then
    lspconfig.vimls.setup {
        capabilities = capabilities
    }
end
--- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics,
{ virtual_text = true, signs = true, update_in_insert = false })


local keymap = vim.api.nvim_set_keymap
keymap('n', 'K', '<cmd>lua require("utility/util").show_doc()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>ga', '<cmd>lua vim.lsp.buf.code_action()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>gd', '<cmd>lua vim.lsp.buf.declaration()<CR>',      { noremap = true, silent = true })
keymap('n', '<leader>gf', '<cmd>lua vim.lsp.buf.definition()<CR>',       { noremap = true, silent = true })
keymap('n', '<leader>gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',   { noremap = true, silent = true })
keymap('n', '<leader>gm', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>',       { noremap = true, silent = true })
keymap('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>',  { noremap = true, silent = true })
keymap('n', '<leader>gw', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
keymap('n', '<M-K>', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap = true, silent = true })
