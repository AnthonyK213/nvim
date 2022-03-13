vim.cmd('packadd nvim-colorizer.lua')


require('colorizer').setup()


vim.api.nvim_add_user_command('ColorizerReset', function (_)
    package.loaded["colorizer"] = nil
    require("colorizer").setup()
    require("colorizer").attach_to_buffer(0)
end, {})
