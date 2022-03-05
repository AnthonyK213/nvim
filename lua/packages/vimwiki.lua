vim.g.vimwiki_list = {{
    path = vim.fn.expand(vim.g.path_cloud.."/Notes/"),
    path_html = vim.fn.expand(vim.g.path_cloud.."/Notes/html/"),
    syntax = 'markdown',
    ext = '.wiki'
}}
vim.g.vimwiki_folding = 'syntax'
vim.g.vimwiki_ext2syntax = {
    ['.wikimd'] = 'markdown'
}
