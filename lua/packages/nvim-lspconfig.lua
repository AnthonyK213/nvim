local lsp_option = _my_core_opt.lsp or {}
local lspconfig = require("lspconfig")
local kbd = vim.keymap.set

-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Attach: Keymaps, aerial.
local custom_attach = function(client, bufnr)
    local _o = { noremap = true, silent = true, buffer = bufnr }
    kbd("n", "<F12>", function() vim.lsp.buf.definition() end, _o)
    kbd("n", "K", function() vim.lsp.buf.hover() end, _o)
    kbd("n", "<leader>l0", function() vim.lsp.buf.document_symbol() end, _o)
    kbd("n", "<leader>la", function() vim.lsp.buf.code_action() end, _o)
    kbd("n", "<leader>ld", function() vim.lsp.buf.declaration() end, _o)
    kbd("n", "<leader>lf", function() vim.lsp.buf.definition() end, _o)
    kbd("n", "<leader>lh", function() vim.lsp.buf.signature_help() end, _o)
    kbd("n", "<leader>li", function() vim.lsp.buf.implementation() end, _o)
    kbd("n", "<leader>lk", function()
        vim.diagnostic.open_float { border = _my_core_opt.tui.border }
    end, _o)
    kbd("n", "<leader>lm", function()
        vim.lsp.buf.format { async = false }
    end, _o)
    kbd("n", "<leader>ln", function() vim.lsp.buf.rename() end, _o)
    kbd("n", "<leader>lr", function() vim.lsp.buf.references() end, _o)
    kbd("n", "<leader>lt", function() vim.lsp.buf.type_definition() end, _o)
    kbd("n", "<leader>lw", function() vim.lsp.buf.workspace_symbol() end, _o)
    kbd("n", "<leader>l[", function()
        vim.diagnostic.goto_prev {
            float = {
                border = _my_core_opt.tui.border
            }
        }
    end, _o)
    kbd("n", "<leader>l]", function()
        vim.diagnostic.goto_next {
            float = {
                border = _my_core_opt.tui.border
            }
        }
    end, _o)
    -- aerial.nvim
    require("aerial").on_attach(client, bufnr)
end

-- Load mason.nvim
require("mason").setup { ui = { border = _my_core_opt.tui.border } }
require("mason-lspconfig").setup()

---LSP options.
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

---Setup servers.
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
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = _my_core_opt.tui.border,
})
