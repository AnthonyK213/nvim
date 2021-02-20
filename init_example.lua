--vim.g.default_shell      = 'zsh'
--vim.g.default_c_compiler = 'clang'
--vim.g.python3_exec_path  = '/usr/bin/python3'
--vim.g.gui_font_size      = 10
--vim.g.gui_font_family    = 'Sarasa Mono SC'

-- LSP
vim.g.init_lsp_option = {
    -- C, C++
    clangd = false,
    -- C#
    omnisharp = false,
    -- LaTeX
    texlab = false,
    -- Lua
    sumneko_lua = false,
    -- Python
    jedi_language_server = false,
    -- Rust
    rls = false,
    rust_analyzer = false,
    -- Vim script
    vimls = false,
}


require('core')
