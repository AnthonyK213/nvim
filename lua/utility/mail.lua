local lib = require("utility.lib")
local dylib_dir = vim.fn.stdpath("config").."/dylib/"
local dylib_ext = ({
    [lib.Os.Windows] = "dll",
    [lib.Os.Linux] = "so",
    [lib.Os.Macos] = "so",
})[lib.get_os_type()]

---@class Mail
---@field from string
---@field to string
---@field reply_to string
---@field subject string
---@field body string
local Mail = {}

Mail.__index = Mail

---Constructor.
---Mailbox: "Name <mailbox_address>"
---@param from string Mailbox `from`.
---@param to string Mailbox `to`.
---@param reply_to? string Mailbox `reply_to`.
---@return Mail
function Mail.new(from, to, reply_to)
    local mail = {
        from = from,
        to = to,
        reply_to = reply_to or to,
    }
    setmetatable(mail, Mail)
    return mail
end

---Create an EML file.
function Mail.new_file()
    vim.cmd("e "..vim.fn.fnameescape(_my_core_opt.path.desktop..os.date("/%Y%m%d.eml")))
    vim.api.nvim_paste(os.date([[
From: 
Subject: 
To: 
Reply-To: 
Date: %c

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------]]), true, -1)
    lib.feedkeys("<Up>", "n", true)
end

---Instantiate a mail object from buffer.
function Mail.from_buf()
end

---Send the e-mail.
---@param server string Address of the SMTP server.
---@param user_name string
---@param password string
function Mail:send(server, user_name, password)
    -- Check fields.
    if not (self.from and self.to and self.reply_to
        and self.subject and self.body) then
        lib.notify_err("Invalid email.")
        return
    end

    -- Check dylib.
    if not (server and user_name and password) then
        lib.notify_err("Invalid STMP server.")
        return
    end

    if not dylib_ext then
        lib.notify_err("Unsupported OS.")
        return
    end
    local lib_path = dylib_dir.."nmail."..dylib_ext
    if not lib.path_exists(lib_path) then
        lib.notify_err("nmail."..dylib_ext.." is not found.")
        return
    end

    vim.loop.new_work(function (_from, _to, _reply_to, _subject, _body,
                                _user_name, _password, _server, _path)
        local ffi = require("ffi")
        ffi.cdef([[int nmail_send(const char *from,
                                  const char *to,
                                  const char *reply_to,
                                  const char *subject,
                                  const char *body,
                                  const char *user_name,
                                  const char *password,
                                  const char *server);]])
        local nmail = ffi.load(_path)
        return nmail.nmail_send(_from, _to, _reply_to, _subject, _body,
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
            [6] = "Failed to parse SMTP server `user name`.",
            [7] = "Failed to parse SMTP server `password`.",
            [8] = "Failed to parse SMTP server `address`.",
            [9] = "Failed to parse `from` mailbox.",
            [10] = "Failed to parse `reply to` mailbox.",
            [11] = "Failed to parse `to` mailbox.",
            [12] = "Failed to create the email.",
            [13] = "Failed to connect to the SMTP server.",
            [14] = "Failed to send the email.",
        };
        (code == 0 and vim.notify or lib.notify_err)(code_map[code])
    end)):queue(self.from, self.to, self.reply_to, self.subject, self.body,
                user_name, password, server, lib_path)
end


---@class Mailbox
local Mailbox = {}

Mailbox.__index = Mailbox


return {
    Mail = Mail,
    Mailbox = Mailbox,
}
