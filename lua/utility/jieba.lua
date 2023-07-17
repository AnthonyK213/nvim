local ffi = require("ffi")
local lib = require("utility.lib")

local M = {}

---@private
---FFI module.
M.njieba = nil

---@private
---Jieba instance.
M.jieba = nil

---@private
M.enabled = false

---@private
function M:init()
    if self.jieba then return true end
    local dylib_path = lib.get_dylib_path("njieba")
    if not dylib_path then
        lib.notify_err("Dynamic library is not found")
        return false
    end
    ffi.cdef [[void *njieba_new();
               int njieba_pos(void *jieba, const char *line, int pos,
                              int *start, int *end);
               void njieba_drop(void *jieba);]]
    self.njieba = ffi.load(dylib_path)
    self.jieba = self.njieba.njieba_new()
    return true
end

function M.is_enabled()
    return M.enabled
end

---Get start and end position of the word at `position` (in unicode).
---@param sentence string The sentence.
---@param position integer Unicode postion in `sentence`.
---@return integer? start_pos Start position (0-based, included).
---@return integer? end_pos End position (0-based, included).
function M.get_pos(sentence, position)
    local s, e = ffi.new("int[1]", 0), ffi.new("int[1]", 0)
    if M.jieba
        and M.njieba.njieba_pos(M.jieba, sentence, position, s, e) == 0 then
        return s[0], e[0] - 1
    end
end

local function goto_word_begin()
    local line
    local lnum, pos_byte = unpack(vim.api.nvim_win_get_cursor(0))
    if pos_byte == 0 and lnum ~= 1 then
        lnum = lnum - 1
        line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
        pos_byte = #line - #lib.str_sub(line, -1, -1)
        vim.api.nvim_win_set_cursor(0, { lnum, pos_byte })
        return
    else
        line = vim.api.nvim_get_current_line()
    end
    local pos_utf = vim.str_utfindex(line, pos_byte)
    local s_utf, _ = M.get_pos(line, pos_utf)
    if not s_utf then return end
    if s_utf == pos_utf then
        s_utf, _ = M.get_pos(line, pos_utf - 1)
        if not s_utf then return end
    end
    local s_byte = vim.str_byteindex(line, s_utf)
    vim.api.nvim_win_set_cursor(0, { lnum, s_byte })
end

local function goto_word_end()
    local line = vim.api.nvim_get_current_line()
    local lnum, pos_byte = unpack(vim.api.nvim_win_get_cursor(0))
    if pos_byte >= #line - #lib.str_sub(line, -1, -1)
        and lnum ~= vim.api.nvim_buf_line_count(0) then
        vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
        return
    end
    local pos_utf = vim.str_utfindex(line, pos_byte)
    local _, e_utf = M.get_pos(line, pos_utf)
    if not e_utf then return end
    if e_utf == pos_utf then
        _, e_utf = M.get_pos(line, pos_utf + 1)
        if not e_utf then return end
    end
    local e_byte = vim.str_byteindex(line, e_utf)
    vim.api.nvim_win_set_cursor(0, { lnum, e_byte })
end

local function inner_word()
    local line = vim.api.nvim_get_current_line()
    if #line == 0 then return end
    local lnum, pos_byte = unpack(vim.api.nvim_win_get_cursor(0))
    local pos_utf = vim.str_utfindex(line, pos_byte)
    local s_utf, e_utf = M.get_pos(line, pos_utf)
    if not s_utf or not e_utf then return end
    local s_byte = vim.str_byteindex(line, s_utf)
    local e_byte = vim.str_byteindex(line, e_utf)
    vim.api.nvim_buf_set_mark(0, "<", lnum, s_byte, {})
    vim.api.nvim_buf_set_mark(0, ">", lnum, e_byte, {})
    vim.cmd.normal { bang = true, args = { "gv" }, mods = { silent = true } }
end

function M:enable()
    if self:init() and not self.enabled then
        vim.keymap.set({ "n", "v" }, "b", goto_word_begin, {})
        vim.keymap.set({ "n", "v" }, "e", goto_word_end, {})
        vim.keymap.set({ "v", "o" }, "iw", inner_word, {})
        self.enabled = true
    end
end

function M:disable()
    if self.enabled then
        pcall(vim.keymap.del, { "n", "v" }, "b", {})
        pcall(vim.keymap.del, { "n", "v" }, "e", {})
        pcall(vim.keymap.del, { "v", "o" }, "iw", {})
        self.enabled = false
    end
end

---@private
function M.drop()
    if not M.jieba then return end
    M.njieba.njieba_drop(M.jieba)
    M.jieba = nil
end

vim.api.nvim_create_autocmd("VimLeavePre", { callback = M.drop })

return M
