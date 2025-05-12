local ffi = require("ffi")
local lib = require("utility.lib")
local rsmod = require("utility.rsmod")

---FFI module.
---@type ffi.namespace*
local _njieba = nil

local M = {}

---@private
---Jieba instance.
M.jieba = nil

---@private
M.enabled = false

---@private
function M:init()
  if _njieba then return true end
  local dylib_path = rsmod.get_dylib_path("njieba")
  if not dylib_path then
    lib.warn("Dynamic library is not found")
    return false
  end
  ffi.cdef [[
void *njieba_new();
int njieba_pos(void *jieba, const char *line, int pos, int *start, int *end);
void njieba_drop(void *jieba);
]]
  _njieba = ffi.load(dylib_path)
  return true
end

function M.is_enabled()
  return M.enabled
end

---Get start and end position of the word at `position`.
---@param sentence string The sentence.
---@param position integer Char index in `sentence` (0-based).
---@return integer? start_pos Start position (0-based, included).
---@return integer? end_pos End position (0-based, included).
function M.get_pos(sentence, position)
  local s, e = ffi.new("int[1]", 0), ffi.new("int[1]", 0)
  if M.jieba
      and _njieba.njieba_pos(M.jieba, sentence, position, s, e) == 0 then
    return s[0], e[0] - 1
  end
end

---Get the word and its position at the cursor.
---@return string word Word at the cursor.
---@return integer start_column Start index of the line (0-based, included).
---@return integer end_column End index of the line (0-based, not included).
function M.get_word()
  local encoding = lib.str_encoding()
  local line = vim.api.nvim_get_current_line()
  local _, pos_byte = unpack(vim.api.nvim_win_get_cursor(0))
  -- NOTE: In fact, `vim.str_utfindex` is 1-based, while `pos_byte` is 0-based.
  -- But the values of `pos_char` are the same at the begin position of the char
  -- despite of the base, thus we can treat `pos_char` as a 0-based index here.
  -- Anyway, `vim.str_utfindex` was implemented incorrectly, it should be fixed.
  local pos_char = vim.str_utfindex(line, encoding, pos_byte)
  local s_char, e_char = M.get_pos(line, pos_char)
  if not s_char or not e_char then
    error("No word found")
  end
  local word = lib.str_sub(line, s_char + 1, e_char + 1)
  -- `vim.str_byteindex` is 0-based.
  local s_byte = vim.str_byteindex(line, encoding, s_char)
  local e_byte = vim.str_byteindex(line, encoding, e_char + 1)
  return word, s_byte, e_byte
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
  local encoding = lib.str_encoding()
  local pos_char = vim.str_utfindex(line, encoding, pos_byte)
  local s_char, _ = M.get_pos(line, pos_char)
  if not s_char then return end
  if s_char == pos_char then
    s_char, _ = M.get_pos(line, pos_char - 1)
    if not s_char then return end
  end
  local s_byte = vim.str_byteindex(line, encoding, s_char)
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
  local encoding = lib.str_encoding()
  local pos_char = vim.str_utfindex(line, encoding, pos_byte)
  local _, e_char = M.get_pos(line, pos_char)
  if not e_char then return end
  if e_char == pos_char then
    _, e_char = M.get_pos(line, pos_char + 1)
    if not e_char then return end
  end
  local e_byte = vim.str_byteindex(line, encoding, e_char)
  vim.api.nvim_win_set_cursor(0, { lnum, e_byte })
end

local function inner_word()
  local line = vim.api.nvim_get_current_line()
  if #line == 0 then return end
  local encoding = lib.str_encoding()
  local lnum, pos_byte = unpack(vim.api.nvim_win_get_cursor(0))
  local pos_char = vim.str_utfindex(line, encoding, pos_byte)
  local s_char, e_char = M.get_pos(line, pos_char)
  if not s_char or not e_char then return end
  local s_byte = vim.str_byteindex(line, encoding, s_char)
  local e_byte = vim.str_byteindex(line, encoding, e_char)
  vim.api.nvim_buf_set_mark(0, "<", lnum, s_byte, {})
  vim.api.nvim_buf_set_mark(0, ">", lnum, e_byte, {})
  vim.cmd.normal { bang = true, args = { "gv" }, mods = { silent = true } }
end

---Enable jieba.
---@return boolean
function M:enable()
  if not self:init() then
    return false
  end

  if self.enabled then
    return true
  end

  if not self.jieba then
    self.jieba = _njieba.njieba_new()
    ffi.gc(self.jieba, _njieba.njieba_drop)
  end

  vim.keymap.set({ "n", "v" }, "b", goto_word_begin, {})
  vim.keymap.set({ "n", "v" }, "e", goto_word_end, {})
  vim.keymap.set({ "v", "o" }, "iw", inner_word, {})
  self.enabled = true

  return true
end

---Disable jieba.
function M:disable()
  if self.enabled then
    pcall(vim.keymap.del, { "n", "v" }, "b", {})
    pcall(vim.keymap.del, { "n", "v" }, "e", {})
    pcall(vim.keymap.del, { "v", "o" }, "iw", {})
    self.enabled = false
  end
end

return M
