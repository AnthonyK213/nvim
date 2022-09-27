local M = {}
local ffi = require("ffi")
local lib = require("utility.lib")
local dylib_dir = vim.fn.stdpath("config").."/dylib/"


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
    ffi.cdef([[int nmail_send(const char *from,
                              const char *reply_to,
                              const char *to,
                              const char *subject,
                              const char *body,
                              const char *user_name,
                              const char *password,
                              const char *server)]])
    local lib_path = dylib_dir.."nmail.dll"
    if not lib.path_exists(lib_path) then
        lib.notify_err("libnmail is not found.")
        return -1
    end
    local nmail = ffi.load(lib_path)
    -- ffi.new("char[?]", _, _)
    return nmail.nmail_send(from, reply_to, to, subject, body, user_name, password, server);
end



return M
