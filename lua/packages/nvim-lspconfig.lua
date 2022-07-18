local lsp_option = _my_core_opt.lsp or {}
local lspconfig = require("lspconfig")

-- nvim-cmp
-- Enable LSP snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- Attach: Keymaps, aerial.
local kbd = vim.keymap.set
local custom_attach = function (client, bufnr)
    local ntst = { noremap = true, silent = true, buffer = bufnr }
    kbd("n", "<F12>",      function () vim.lsp.buf.definition() end,       ntst)
    kbd("n", "K",          function () vim.lsp.buf.hover() end,            ntst)
    kbd("n", "<leader>l0", function () vim.lsp.buf.document_symbol() end,  ntst)
    kbd("n", "<leader>la", function () vim.lsp.buf.code_action() end,      ntst)
    kbd("n", "<leader>ld", function () vim.lsp.buf.declaration() end,      ntst)
    kbd("n", "<leader>lf", function () vim.lsp.buf.definition() end,       ntst)
    kbd("n", "<leader>lh", function () vim.lsp.buf.signature_help() end,   ntst)
    kbd("n", "<leader>li", function () vim.lsp.buf.implementation() end,   ntst)
    kbd("n", "<leader>lk", function ()
        vim.diagnostic.open_float { border = "rounded" }
    end, ntst)
    kbd("n", "<leader>lm", function ()
        vim.lsp.buf.format { async = false }
    end, ntst)
    kbd("n", "<leader>ln", function () vim.lsp.buf.rename() end,           ntst)
    kbd("n", "<leader>lr", function () vim.lsp.buf.references() end,       ntst)
    kbd("n", "<leader>lt", function () vim.lsp.buf.type_definition() end,  ntst)
    kbd("n", "<leader>lw", function () vim.lsp.buf.workspace_symbol() end, ntst)
    kbd("n", "<leader>l[", function () vim.diagnostic.goto_prev() end,     ntst)
    kbd("n", "<leader>l]", function () vim.diagnostic.goto_next() end,     ntst)
    -- aerial.nvim
    require("aerial").on_attach(client, bufnr)
end

-- Load nvim-lsp-installer
require("nvim-lsp-installer").setup {}

-- LSP options.
local server_settings = {
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
    },
}

---Setup servers via nvim-lspconfig.
---@param server string Name of the language server.
---@param option boolean|table<string, any> Options.
local function setup_server(server, option)
    option = option or false

    if (type(option) == "boolean" and option)
        or (type(option) == "table" and option.load == true) then

        local opts = {
            capabilities = capabilities,
            on_attach = custom_attach
        }

        local option_settings
        if type(option) == "table" and type(option.settings) == "table" then
            option_settings = option.settings
        end

        opts.settings = option_settings or server_settings[server]

        lspconfig[server].setup(opts)
    end
end

for server, option in pairs(lsp_option) do
    setup_server(server, option)
end

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
