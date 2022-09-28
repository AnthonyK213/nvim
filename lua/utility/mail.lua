local M = {}
local lib = require("utility.lib")
local dylib_dir = vim.fn.stdpath("config").."/dylib/"
local dylib_ext = ({
    [lib.Os.Windows] = "dll",
    [lib.Os.Linux] = "so",
    [lib.Os.Macos] = "so",
})[lib.get_os_type()]


---Send the e-mail.
---@param from string
---@param reply_to string
---@param to string
---@param subject string
---@param body string
---@param user_name string
---@param password string
---@param server string
function M.send(from, reply_to, to, subject, body, user_name, password, server)
    if not dylib_ext then return end
    local lib_path = dylib_dir.."nmail."..dylib_ext
    if not lib.path_exists(lib_path) then
        lib.notify_err("nmail."..dylib_ext.." is not found.")
        return
    end
    vim.loop.new_work(function (_from, _reply_to, _to, _subject, _body,
                                _user_name, _password, _server, _path)
        local ffi = require("ffi")
        ffi.cdef([[int nmail_send(const char *from,
                                  const char *reply_to,
                                  const char *to,
                                  const char *subject,
                                  const char *body,
                                  const char *user_name,
                                  const char *password,
                                  const char *server);]])
        local nmail = ffi.load(_path)
        return nmail.nmail_send(_from, _reply_to, _to, _subject, _body,
                                _user_name, _password, _server)
    end,
    vim.schedule_wrap(function (code)
        local code_map = {
            [0] = "Email sent successfully!",
            [1] = "Invalid `from` mailbox.",
            [2] = "Invalid `reply to` mailbox.",
            [3] = "Invalid `to` mailbox.",
            [4] = "Failed to parse mail `subject`.",
            [5] = "Failed to parse mail `body`.",
            [6] = "Failed to parse smtp server `user name`.",
            [7] = "Failed to parse smtp server `password`.",
            [8] = "Failed to parse smtp server `address`.",
            [9] = "Failed to parse `from` mailbox.",
            [10] = "Failed to parse `reply to` mailbox.",
            [11] = "Failed to parse `to` mailbox.",
            [12] = "Failed to create the email.",
            [13] = "Failed to connect to the smtp server.",
            [14] = "Failed to send the email.",
        };
        (code == 0 and vim.notify or lib.notify_err)(code_map[code])
    end)):queue(from, reply_to, to, subject, body,
                user_name, password, server, lib_path)
end


return M
