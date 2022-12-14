local lsp_option = _my_core_opt.lsp or {}
local lspconfig = require("lspconfig")
local kbd = vim.keymap.set
local float_opts = {
    border = _my_core_opt.tui.border,
    max_width = 80,
}

-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Attaches.
local custom_attach = function(_, bufnr)
    local _o = { noremap = true, silent = true, buffer = bufnr }
    kbd("n", "<F12>", vim.lsp.buf.definition, _o)
    kbd("n", "K", vim.lsp.buf.hover, _o)
    kbd("n", "<leader>l0", vim.lsp.buf.document_symbol, _o)
    kbd("n", "<leader>la", vim.lsp.buf.code_action, _o)
    kbd("n", "<leader>ld", vim.lsp.buf.declaration, _o)
    kbd("n", "<leader>lf", vim.lsp.buf.definition, _o)
    kbd("n", "<leader>lh", vim.lsp.buf.signature_help, _o)
    kbd("n", "<leader>li", vim.lsp.buf.implementation, _o)
    kbd("n", "<leader>lk", function() vim.diagnostic.open_float(float_opts) end, _o)
    kbd("n", "<leader>lm", function() vim.lsp.buf.format { async = false } end, _o)
    kbd("n", "<leader>ln", vim.lsp.buf.rename, _o)
    kbd("n", "<leader>lr", vim.lsp.buf.references, _o)
    kbd("n", "<leader>lt", vim.lsp.buf.type_definition, _o)
    kbd("n", "<leader>lw", vim.lsp.buf.workspace_symbol, _o)
    kbd("n", "<leader>l[", function() vim.diagnostic.goto_prev { float = float_opts } end, _o)
    kbd("n", "<leader>l]", function() vim.diagnostic.goto_next { float = float_opts } end, _o)
end

-- Load mason.nvim
require("mason").setup { ui = { border = _my_core_opt.tui.border } }
require("mason-lspconfig").setup()

-- LSP options.
local server_settings = {
    omnisharp = function(o, s)
        if type(s) == "table" then
            for k, v in pairs(s) do
                if k ~= "cmd" then
                    o[k] = v
                end
            end
        end
    end,
    sumneko_lua = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            }
        },
    }
}

---Setup servers via nvim-lspconfig.
---@param server string Name of the language server.
---@param config boolean|table<string, any> Server configuration from `nvimrc`.
local function setup_server(server, config)
    config = config or false
    if (type(config) == "boolean" and config)
        or (type(config) == "table" and config.load == true) then
        local opts = {
            capabilities = capabilities,
            on_attach = custom_attach
        }
        -- Disable semantic tokens.
        if type(config) == "table" and config.disable_semantic_tokens then
            opts.on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
                custom_attach(client, bufnr)
            end
        end
        -- Merge custom LSP configurations.
        local option_settings
        if type(config) == "table" and type(config.settings) == "table" then
            option_settings = config.settings
        end
        local server_setting = server_settings[server]
        if type(server_setting) == "function" then
            server_setting(opts, option_settings)
        else
            local s = option_settings or server_setting
            if s then
                opts.settings = s
            end
        end
        lspconfig[server].setup(opts)
    end
end

-- Setup servers.
for server, option in pairs(lsp_option) do setup_server(server, option) end

-- Diagnostics
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
}

-- Hover window border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float_opts)
