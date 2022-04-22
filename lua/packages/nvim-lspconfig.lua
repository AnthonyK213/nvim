local lsp 
local lsp_installer = require('nvim-lsp-installer')
local lsp_option = _my_core_opt.lsp or {}

-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Attach: Keymaps, aerial.
local kbd = vim.keymap.set
local ntst = { noremap = true, silent = true, buffer = true }
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
    kbd('n', '<M-K>',      function ()
        vim.diagnostic.open_float { border = "rounded" }
    end, ntst)
    -- aerial.nvim
    require('aerial').on_attach(client)
end

-- LSP options.
local server_opts = {
    sumneko_lua = function (opts)
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")
        opts.settings = {
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
        }
    end
}

-- Setup servers.
lsp_installer.on_server_ready(function (server)
    local opts = {
        capabilities = capabilities,
        on_attach = custom_attach
    }

    if server_opts[server.name] then
        server_opts[server.name](opts)
    end

    local opt = lsp_option[server.name]
    if (type(opt) == "boolean" and opt)
        or (type(opt) == "table" and opt["enable"]) then
        server:setup(opts)
    end
end)

-- Diagnostics
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
}

-- Hover window border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
