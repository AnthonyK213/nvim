vim.g.vimwiki_list = {{
    path = vim.fn.expand(_my_core_opt.path.cloud.."/Notes/"),
    path_html = vim.fn.expand(_my_core_opt.path.cloud.."/Notes/html/"),
    syntax = 'markdown',
    ext = '.markdown'
}}
vim.g.vimwiki_folding = 'syntax'
vim.g.vimwiki_ext2syntax = {
    ['.markdown'] = 'markdown'
}
