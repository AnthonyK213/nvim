local lib = require("utility.lib")
local dylib_dir = vim.fn.stdpath("config").."/dylib/"
local dylib_ext = ({
    [lib.Os.Windows] = "dll",
    [lib.Os.Linux] = "so",
    [lib.Os.Macos] = "so",
})[lib.get_os_type()]

---Get the configuration of mail (from `mail.json`).
---@return table? configuration
local function get_config()
    local has_config, config_path = lib.get_dotfile("mail.json")
    local config
    if has_config and config_path then
        local code, result = lib.json_decode(config_path)
        if code == 0 then
            config = result
        else
            vim.notify("Invalid `mail.json`", vim.log.levels.WARN, nil)
        end
    else
        vim.notify("No `mail.json` found.", vim.log.levels.WARN, nil)
    end
    return config
end

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
    local config = get_config()
    if not config then return end
    if not (config.mailbox and lib.path_exists(config.mailbox)) then
        lib.notify_err("Invalid mailbox directory.")
        return
    end
    vim.cmd("e "..vim.fn.fnameescape(lib.path_append(config.mailbox, os.date("%Y%m%d%H%M%S.eml"))))
    vim.api.nvim_paste(os.date([[
From: 
Subject: 
To: 
Reply-To: 
Date: %c

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------]]), true, -1)
    lib.feedkeys("gg", "n", true)
end

---Instantiate a mail object from current buffer.
function Mail.from_buf()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local from, subject, to, reply_to
    local body_lines = {}
    local separator = string.rep("-", 80)
    local find_body = false
    for _, line in ipairs(lines) do
        if not find_body then
            local label, value = line:match("^([%w-]+):%s*(.+)%s*$")
            if label == "From" then
                from = value
            elseif label == "Subject" then
                subject = value
            elseif label == "To" then
                to = value
            elseif label == "Reply-To" then
                if #(vim.trim(value)) > 0 then
                    reply_to = value
                end
            end
            if line == separator then
                find_body = true
            end
        else
            if line == separator then break end
            table.insert(body_lines, line)
        end
    end
    local body = table.concat(body_lines, "\r\n")
    local mail = Mail.new(from, to, reply_to)
    mail.subject = subject
    mail.body = body
    return mail
end

---Send the e-mail.
function Mail:send()
    -- Check fields.
    if not (self.from and self.to and self.reply_to
        and self.subject and self.body) then
        lib.notify_err("Invalid email.")
        return
    end

    -- Check dylib.
    if not dylib_ext then
        lib.notify_err("Unsupported OS.")
        return
    end

    local lib_path = dylib_dir.."nmail."..dylib_ext
    if not lib.path_exists(lib_path) then
        lib.notify_err("nmail."..dylib_ext.." is not found.")
        return
    end

    -- Load configuration.
    local config = get_config()
    if not config
        or not config.smtp
        or not vim.tbl_islist(config.smtp)
        or vim.tbl_isempty(config.smtp) then
        lib.notify_err("SMTP server list is empty.")
        return
    end

    local index_table = {}
    for i, item in ipairs(config.smtp) do
        if type(item) == "table"
            and type(item.user_name) == "string"
            and type(item.server) == "string"
            and type(item.password) == "string" then
            table.insert(index_table, i)
        end
    end

    vim.ui.select(index_table, {
        prompt = "Select SMTP server:",
        format_item = function (item)
            return config.smtp[item].user_name
        end
    }, function (index)
        if not index then return end
        local smtp = config.smtp[index]
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
                [1] = "Invalid mailbox `From`.",
                [2] = "Invalid mailbox `To`.",
                [3] = "Invalid mailbox `Reply-To`.",
                [4] = "Failed to parse mail `Subject`.",
                [5] = "Failed to parse mail `Body`.",
                [6] = "Failed to parse SMTP server `user name`.",
                [7] = "Failed to parse SMTP server `password`.",
                [8] = "Failed to parse SMTP server `address`.",
                [9] = "Failed to parse mailbox `From`.",
                [10] = "Failed to parse mailbox `To`.",
                [11] = "Failed to parse mailbox `Reply-To`.",
                [12] = "Failed to create the email.",
                [13] = "Failed to connect to the SMTP server.",
                [14] = "Failed to send the email.",
            };
            (code == 0 and vim.notify or lib.notify_err)(code_map[code])
        end)):queue(self.from, self.to, self.reply_to, self.subject, self.body,
                    smtp.user_name, smtp.password, smtp.server, lib_path)
    end)
end


---@class Mailbox
local Mailbox = {}

Mailbox.__index = Mailbox


return {
    Mail = Mail,
    Mailbox = Mailbox,
}
