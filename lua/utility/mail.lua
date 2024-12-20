local lib = require("utility.lib")
local util = require("utility.util")
local futures = require("futures")
local dylib_name = "nmail"
local code_send = {
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
}

---Send e-mail via SMTP server.
---Wrapped from `nmail_send`.
---@param from string
---@param to string
---@param reply_to string
---@param subject string
---@param body string
---@param user_name string
---@param password string
---@param server string
---@param path string Path to dynamic linked library `nmail`.
---@return integer code
local function nmail_send(from, to, reply_to, subject, body,
                          user_name, password, server, path)
  local ffi = require("ffi")
  ffi.cdef [[
int nmail_send(const char *from,
               const char *to,
               const char *reply_to,
               const char *subject,
               const char *body,
               const char *user_name,
               const char *password,
               const char *server);
]]
  local nmail = ffi.load(path)
  return nmail.nmail_send(from, to, reply_to, subject, body,
    user_name, password, server)
end

---Fetch e-mail from IMAP server.
---Wrapped from `nmail_fetch`.
---@param server string
---@param port integer
---@param user_name string
---@param password string
---@param path string Path to dynamic linked library `nmail`.
---@return string? Body of fetched e-mails.
local function nmail_fetch(server, port, user_name, password, path)
  local ffi = require("ffi")
  ffi.cdef [[
char *nmail_fetch(const char *server, int port, const char *user_name, const char *password);
void str_free(char *s);
]]
  local nmail = ffi.load(path)
  local c_str = nmail.nmail_fetch(server, port, user_name, password)
  if c_str == nil then return end
  local body = ffi.string(c_str)
  nmail.str_free(c_str)
  return body
end

---@class MailConfig
---@field archive string
---@field providers table[]
---@field inbox_dir string
---@field outbox_dir string
local MailConfig = {}

MailConfig.__index = MailConfig

---Get the configuration of mail (from `mail.json`).
---@return MailConfig?
function MailConfig.get()
  local mailConfig = {}
  local has_config, config_path = lib.get_dotfile("mail.json")
  if has_config and config_path then
    local code, result = lib.json_decode(config_path)
    if code == 0 and result then
      if type(result.archive) == "string" then
        if not lib.path_exists(result.archive) then
          vim.uv.fs_mkdir(result.archive, 448)
        end
        local inbox = lib.path_append(result.archive, "INBOX/")
        local outbox = lib.path_append(result.archive, "OUTBOX/")
        if not lib.path_exists(inbox) then
          vim.uv.fs_mkdir(inbox, 448)
        end
        if not lib.path_exists(outbox) then
          vim.uv.fs_mkdir(outbox, 448)
        end
        mailConfig.archive = result.archive
        mailConfig.inbox_dir = inbox
        mailConfig.outbox_dir = outbox
      else
        lib.warn("Invalid `archive`.")
        return
      end

      if vim.islist(result.providers) then
        local providers = {}
        for _, item in ipairs(result.providers) do
          if type(item.label) == "string"
              and type(item.smtp) == "string"
              and type(item.imap) == "string"
              and type(item.port) == "number"
              and type(item.user_name) == "string"
              and type(item.password) == "string"
              and item.port > 0
              and item.port <= 65535 then
            table.insert(providers, item)
          end
        end
        if vim.tbl_isempty(providers) then
          lib.warn("No valid `providers`.")
          return
        end
        mailConfig.providers = providers
      else
        lib.warn("Invalid `providers`.")
        return
      end
    else
      util.edit_file(config_path, false)
      lib.warn("Invalid `mail.json`")
      return
    end
  else
    if not config_path then
      lib.warn("Cannot create `mail.json`.")
      return
    end
    vim.cmd.edit(config_path)
    vim.api.nvim_paste([[
{
  "archive": "",
  "providers": [
    {
      "label": "",
      "smtp": "",
      "imap": "",
      "port": 993,
      "user_name": "",
      "password": ""
    }
  ]
}]], true, -1)
    return
  end
  setmetatable(mailConfig, MailConfig)
  return mailConfig
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
  local config = MailConfig.get()
  if not config then return end
  local mail_name = os.date("OUT%Y%m%d%H%M%S.eml") --[[@as string]]

  futures.spawn(function()
    local provider = futures.ui.select(config.providers, {
      prompt = "Select mailbox provider: ",
      format_item = function(item)
        return item.label
      end
    })
    if not provider then return end
    vim.cmd.edit(lib.path_append(config.outbox_dir, mail_name))
    local from = "<" .. provider.user_name .. ">"
    vim.api.nvim_paste(os.date([[
From: ]] .. from .. [[

Subject:
To:
Reply-To:
Date: %c

------------------------------------------------------------------------

------------------------------------------------------------------------]]), true, -1)
    lib.feedkeys("gg05l", "n", true)
    vim.bo.fileformat = "dos"
  end)
end

---Instantiate a mail object from current buffer.
---@return Mail
function Mail.from_buf()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local from, subject, to, reply_to
  local body_lines = {}
  local separator = string.rep("-", 72)
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

---Send e-mail via SMTP server.
function Mail:send()
  -- Load configuration.
  local config = MailConfig.get()
  if not config then return end

  -- Check dylib.
  local dylib_path = lib.get_dylib_path(dylib_name)
  if not dylib_path then return end

  -- Check fields.
  if not (self.from and self.to and self.reply_to
        and self.subject and self.body) then
    lib.warn("Invalid email.")
    return
  end

  -- Send.
  futures.spawn(function()
    local yes_no = futures.ui.input { prompt = "Send? [Y/n] " }
    if not yes_no or yes_no:lower() ~= "y" then return end

    local user_name = self.from:match("<(.+)>")

    if not user_name then
      lib.warn("Invalid user name.")
      return
    end

    local provider

    for _, p in ipairs(config.providers) do
      if p.user_name == user_name then
        provider = p
        break
      end
    end

    if not provider then
      lib.warn("Did not fide mailbox with user name: " .. user_name)
      return
    end

    vim.notify("Sending...")

    local code = futures.Task.new(nmail_send,
      self.from, self.to, self.reply_to, self.subject, self.body,
      provider.user_name, provider.password, provider.smtp,
      dylib_path
    ):await();

    (code == 0 and vim.notify or lib.warn)(code_send[code])
  end)
end

---@class Mailbox
---@field fetched string
local Mailbox = {}

Mailbox.__index = Mailbox

---Constructor
---@return Mailbox
function Mailbox.new()
  local mailbox = {}
  setmetatable(mailbox, Mailbox)
  return mailbox
end

---Fetch e-mail from imap server.
function Mailbox:fetch()
  -- Load configuration.
  local config = MailConfig.get()
  if not config then return end

  -- Check dylib.
  local dylib_path = lib.get_dylib_path(dylib_name)
  if not dylib_path then return end

  -- Fetch.
  futures.spawn(function()
    local provider = futures.ui.select(config.providers, {
      prompt = "Select IMAP server: ",
      format_item = function(item)
        return item.label
      end
    })

    if not provider then return end

    vim.notify("Fetching...")

    local body = futures.Task.new(nmail_fetch,
      provider.imap, provider.port,
      provider.user_name, provider.password,
      dylib_path
    ):await()

    if not body then
      vim.notify("No unseen mails.")
      return
    end

    local mail_name = os.date("IN%Y%m%d%H%M%S.eml") --[[@as string]]
    local mail_path = lib.path_append(config.inbox_dir, mail_name)

    local f = io.open(mail_path, "w")
    if f then
      f:write(body)
      f:close()
      vim.cmd.edit(mail_path)
      vim.notify("Mail fetched.")
    end
  end)
end

return {
  Mail = Mail,
  Mailbox = Mailbox,
}
