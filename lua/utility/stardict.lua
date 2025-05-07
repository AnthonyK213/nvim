local ffi = require("ffi")
local lib = require("utility.lib")
local crates = require("utility.crates")
local futures = require("futures")
local spawn, Process = futures.spawn, futures.Process
local stardict_path = vim.uv.os_homedir() .. "/.stardict/dic/"

local function check_dict()
  local exists, dic_path = lib.path_exists(stardict_path)
  local n_dics = 0
  if exists and dic_path then
    for _, type_ in vim.fs.dir(dic_path) do
      if type_ == "directory" then
        n_dics = n_dics + 1
      end
    end
    if n_dics > 0 then
      vim.notify("Found " .. n_dics .. " dictionar" .. (n_dics == 1 and "y" or "ies") .. ".", vim.log.levels.INFO)
      return true
    end
  end
  spawn(function()
    local yes_no = futures.ui.input {
      prompt = "No local dictionary found, get one? [Y/n] "
    }
    if yes_no and yes_no:lower() == "y" then
      require("utility.util").sys_open("https://github.com/AnthonyK213/.stardict")
    end
  end)
  return false
end

local M = {}

local _bufnr, _winnr = -1, -1

---@private
---FFI module.
M.nstardict = nil

---@private
---Dictionaries.
M.library = nil

---@private
---@return boolean
function M:init()
  if not self.nstardict then
    local dylib_path = crates.get_dylib_path("nstardict")
    if not dylib_path then
      lib.warn("Dynamic library is not found")
      return false
    end

    ffi.cdef [[
void *nstardict_new_library(const char *dict_dir);
char *nstardict_consult(void *library, const char *word);
void nstardict_drop_library(void *library);
void ffi_util_str_util_str_free(char *s);
]]

    self.nstardict = ffi.load(dylib_path)
  end

  if not self.library then
    if not stardict_path or not check_dict() then
      return false
    end
    self.library = self.nstardict.nstardict_new_library(stardict_path)

    if not self.library then
      lib.warn("Failed to load dictionaries")
      return false
    end

    ffi.gc(self.library, self.nstardict.nstardict_drop_library)
  end

  return true
end

---@private
---@param word string
---@return string
function M:search(word)
  if not self:init() then
    return "[]"
  end

  if word:match("^%s*$") then
    return "[]"
  end

  local c_str = self.nstardict.nstardict_consult(self.library, word)
  if not c_str then
    return "[]"
  end

  local result = ffi.string(c_str)
  self.nstardict.ffi_util_str_util_str_free(c_str)

  return result
end

local function try_focus()
  if vim.api.nvim_buf_is_valid(_bufnr)
      and vim.api.nvim_win_is_valid(_winnr) then
    vim.api.nvim_set_current_win(_winnr)
    return true
  end
  return false
end

local function show(result)
  local def = result.definition:gsub("^[\n\r]?%*", "\r")
  def = string.format("# %s\r\n__%s__\n%s", result.dict, result.word, def)
  local contents = vim.split(def, "[\r\n]")

  if vim.g.vscode then
    vim.notify(table.concat(contents, "\n"), vim.log.levels.INFO)
  else
    _bufnr, _winnr = vim.lsp.util.open_floating_preview(contents, "markdown", {
      max_height = 20,
      max_width = 50,
      wrap = true,
      border = _G._my_core_opt.tui.border,
    })
  end
end

---@param data string
local function on_stdout(data)
  local ok, results = pcall(vim.json.decode, data)
  if not ok then
    lib.warn(results)
    return
  end
  if #results == 0 then
    lib.warn("No information available")
  elseif #results == 1 then
    show(results[1])
  else
    spawn(function()
      local choice, indice = futures.ui.select(results, {
        prompt = "Select one result:",
        format_item = function(item)
          return item.word
        end
      })
      if not choice then return end
      show(results[indice])
    end)
  end
end

---
---@param word string
function M.stardict_sdcv(word)
  if not lib.executable("sdcv", true) then
    return
  end

  if try_focus() then
    return
  end

  local p = Process.new("sdcv", { args = { "-n", "-j", word } })
  p.on_stdout = on_stdout
  p:start()
end

---
---@param word string
function M.stardict(word)
  if try_focus() then
    return
  end

  local result = M:search(word)
  vim.schedule_wrap(on_stdout)(result)
end

return M
