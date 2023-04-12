local lib = require("utility.lib")
local Process = require("futures.proc")
local augroup = vim.api.nvim_create_augroup("Terminal2", { clear = true })

---@class futures.Terminal2 Represents a neovim terminal which implemented with lua api.
---@field protected proc futures.Process
---@field protected chan? integer
---@field winnr integer
---@field bufnr integer
local Terminal = {}

---@private
Terminal.__index = Terminal

---Constructor.
---@param cmd string Command with arguments.
---@param option? table See `futures.Process.option`. Addtional:
---  - *split_pos*: "belowright"(default)|"aboveleft"|"topleft"|"botright"
---  - *split_size*: Split size;
---  - *ratio_max*: *real_split_size* <= `real_win_size` \* `ratio_max`;
---  - *vertical*: If true, split vertically.
---  - *hide_number*: If true, hide line number in split window(default `true`).
---@return futures.Terminal2
function Terminal.new(cmd, option)
    local terminal = {
        proc = Process.new(cmd, option),
        winnr = -1,
        bufnr = -1,
    }
    setmetatable(terminal, Terminal)
    return terminal
end

---Clone a terminal process.
---@return futures.Terminal
function Terminal:clone()
    local terminal = {
        proc = self.proc:clone(),
        winnr = -1,
        bufnr = -1,
    }
    setmetatable(terminal, Terminal)
    return terminal
end

---@private
---@return boolean ok True if terminal started successfully.
---@return integer winnr Window number of the terminal, -1 on failure.
---@return integer bufnr Buffer number of the terminal, -1 on failure.
function Terminal:_prelude()
    if self.proc.has_exited or not self.proc.is_valid then
        return false, -1, -1
    end
    local ok = false
    ok, self.winnr, self.bufnr = lib.new_split(self.proc.option.split_pos or "belowright", {
        split_size = self.proc.option.split_size,
        ratio_max = self.proc.option.ratio_max,
        vertical = self.proc.option.vertical,
        hide_number = true,
    })
    if not ok then
        return false, self.winnr, self.bufnr
    end
    vim.api.nvim_buf_set_name(self.bufnr,
        string.format("%s %s [%d]",
            self.proc.path,
            table.concat(self.proc.option.args or {}, " "),
            self.bufnr))
    vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
        group = augroup,
        buffer = self.bufnr,
        callback = function() self:close() end,
    })
    self.chan = vim.api.nvim_open_term(self.bufnr, {
        on_input = function(_, _, _, data)
            if data then
                if self.proc.has_exited then
                    self:close(true)
                else
                    data = data:gsub("\r", "\r\n")
                    vim.api.nvim_chan_send(self.chan, data)
                    self.proc:write(data)
                end
            end
        end
    })
    self.proc.on_stdout = function(data)
        data = data:gsub("\n", "\r\n")
        if vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_chan_send(self.chan, data)
        end
    end
    self.proc.on_stderr = function(data)
        data = data:gsub("\n", "\r\n")
        if vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_chan_send(self.chan, data)
        end
    end
    self.proc:continue_with(function(_, code, _)
        if vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_chan_send(self.chan,
                string.format("\r\n[Process exited %d]", code))
        end
    end)
    return ok, self.winnr, self.bufnr
end

---Run the terminal process.
---@return boolean ok True if terminal started successfully.
---@return integer winnr Window number of the terminal, -1 on failure.
---@return integer bufnr Buffer number of the terminal, -1 on failure.
function Terminal:start()
    local ok, winnr, bufnr = self:_prelude()
    if not ok then return false, winnr, bufnr end
    self.proc:start()
    return ok, winnr, bufnr
end

---Continue with a callback function `next`.
---The terminal process will not start automatically.
---@param next fun(proc: futures.Process, code: integer, signal: integer)
---@return futures.Terminal2 self
function Terminal:continue_with(next)
    self.proc:continue_with(next)
    return self
end

---Await the terminal process.
---@return integer? code
---@return integer? signal
function Terminal:await()
    if not self:_prelude() then
        self.proc.has_exited = true
        return
    end
    return self.proc:await()
end

---Close the terminal process.
---@param del_buf? boolean
function Terminal:close(del_buf)
    self.proc:kill()
    if (del_buf) then
        lib.feedkeys(string.format("<C-\\><C-N><Cmd>bd! %d<CR>", self.bufnr),
            "n", true)
    end
end

return Terminal
