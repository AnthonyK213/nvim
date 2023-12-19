local lib = require("utility.lib")
local futures = require("futures")
local spawn, Process, Task = futures.spawn, futures.Process, futures.Task
local dylib_path = lib.get_dylib_path("nstardict")
local stardict_path = vim.uv.os_homedir() .. "/.stardict/dic/"

local M = {}

local _bufnr, _winnr = -1, -1

---Look up `word` among dictionaries.
---@param dict_dir string
---@param word string
---@param path string Path to dynamic linked library `nstardict`.
---@return string?
local function nstardict(dict_dir, word, path)
  local ffi = require("ffi")
  if word:match("^%s*$") then
    return "[]"
  end
  ffi.cdef [[
char *nstardict(const char *dict_dir, const char *word);
void str_free(char *s);
]]
  local nstartdict = ffi.load(path)
  local c_str = nstartdict.nstardict(dict_dir, word)
  if c_str == nil then return end
  local result = ffi.string(c_str)
  nstartdict.str_free(c_str)
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

local function preview(result)
  local def = result.definition:gsub("^[\n\r]?%*", "\r")
  def = string.format("# %s\r\n__%s__\n%s", result.dict, result.word, def)
  local contents = vim.split(def, "[\r\n]")
  _bufnr, _winnr = vim.lsp.util.open_floating_preview(contents, "markdown", {
    max_height = 20,
    max_width = 50,
    wrap = true,
    border = _my_core_opt.tui.border,
  })
end

local function on_stdout(data)
  local ok, results = pcall(vim.json.decode, data)
  if not ok then
    lib.notify_err(results)
    return
  end
  if #results == 0 then
    print("No information available")
  elseif #results == 1 then
    preview(results[1])
  else
    spawn(function()
      local choice, indice = futures.ui.select(results, {
        prompt = "Select one result:",
        format_item = function(item)
          return item.word
        end
      })
      if not choice then return end
      preview(results[indice])
    end)
  end
end

local function check_dict()
  if not lib.executable("sdcv") then return end
  local p = Process.new("sdcv", { args = { "-n", "-j", "-l" } })
  p.on_stdout = function(data)
    local ok, results = pcall(vim.json.decode, data)
    if not ok or #results == 0 then
      spawn(function()
        if futures.ui.input {
              prompt = "Local dictinary not found, get one?",
            } == "y" then
          require("utility.util").sys_open("http://download.huzheng.org/")
        end
      end)
    end
  end
  p:start()
end

check_dict()

function M.stardict_sdcv(word)
  if not lib.executable("sdcv") then return end
  if try_focus() then return end
  local p = Process.new("sdcv", { args = { "-n", "-j", word } })
  p.on_stdout = on_stdout
  p:start()
end

function M.stardict(word)
  if not dylib_path then
    lib.notify_err("Dynamic library is not found")
    return
  end
  if try_focus() then return end
  spawn(function()
    on_stdout(Task.new(nstardict, stardict_path, word, dylib_path):await())
  end)
end

return M
