local path = require('plenary.path')
require('telescope').load_extension('sessions')

require('session_manager').setup {
    -- The directory where the session files will be saved.
    sessions_dir = path:new(vim.fn.stdpath('data'), 'sessions'),
    -- The character to which the path separator will be replaced for session files.
    path_replacer = '__',
    -- The character to which the colon symbol will be replaced for session files.
    colon_replacer = '++',
    -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    -- Automatically save last session on exit.
    autosave_last_session = true,
    -- Plugin will not save a session when no writable and listed buffers are opened.
    autosave_ignore_not_normal = true,
}
