local lib = require("utility.lib")
local futures = require("futures")

local M = {}

---Open terminal and launch shell.
function M.terminal()
  local exec
  local my_sh = _G._my_core_opt.general.shell
  if type(my_sh) == "table" and #my_sh > 0 then
    exec = my_sh[1]
  elseif type(my_sh) == "string" then
    exec = my_sh
  else
    lib.warn("The shell is invalid, please check `nvimrc`.")
    return false
  end

  if vim.fn.executable(exec) ~= 1 then
    lib.warn(exec .. " is not a valid shell.")
    return false
  end

  return futures.Terminal.new(vim.iter({ my_sh }):flatten():totable()):start()
end

---Open and edit text file in vim.
---@param file_path string File path.
---@param chdir boolean True to change cwd automatically.
function M.edit_file(file_path, chdir)
  local path = vim.fs.normalize(file_path)
  if vim.api.nvim_buf_get_name(0) == "" then
    vim.cmd.edit {
      args = { path },
      mods = {
        silent = true
      }
    }
  else
    vim.cmd.tabnew {
      args = { path },
      mods = {
        silent = true
      }
    }
  end
  if chdir then
    vim.api.nvim_set_current_dir(lib.get_buf_dir())
  end
end

---Match path or URL under the cursor.
---@return string? match_result
function M.match_path_or_url_at_point()
  local _, url = lib.url_match(vim.fn.expand("<cWORD>"))
  if url then return url end

  local path = vim.fn.expand("<cfile>")
  local exists, full_path = lib.path_exists(path, lib.get_buf_dir())
  if exists and full_path then
    return vim.fs.normalize(full_path)
  end

  return nil
end

---Get the system open config.
---@return {cmd:string, args?:string[]}?
function M.sys_open_config()
  local os_type = lib.get_os_type()
  if os_type == lib.OS.Linux then
    return { cmd = "xdg-open" }
  elseif os_type == lib.OS.Windows then
    return { cmd = "cmd", args = { "/c", "start", '""' } }
  elseif os_type == lib.OS.MacOS then
    return { cmd = "open" }
  else
    return nil
  end
end

---Open path or URL with system default application.
---The environment variables should be expanded already.
---@param obj string? Path or URL to open.
---@param use_local? boolean Use current file directory as cwd.
---@return boolean ok True if open `obj` successfully.
function M.sys_open(obj, use_local)
  local cwd = use_local and lib.get_buf_dir() or vim.uv.cwd()
  if type(obj) ~= "string"
      or not (lib.path_exists(obj, cwd) or lib.url_match(obj)) then
    lib.warn("Nothing found.")
    return false
  end
  local my_config = M.sys_open_config()
  if not my_config then
    lib.warn("Invalid definition of `start`.")
    return false
  end
  local cmd = my_config.cmd
  local args = my_config.args or {}
  table.insert(args, obj)
  local handle
  handle = vim.uv.spawn(cmd, {
    args = args,
    cwd = cwd,
  }, vim.schedule_wrap(function()
    handle:close()
  end))
  return true
end

---Auto-update the color scheme highlight groups.
---@param scheme string Name of color scheme.
---@param hl_table? table<string, table<string, string>> See _G._my_core_opt.hl
---@param hl_link_table? table<string, string> _G._my_core_opt.hl_link
---@param palette fun():table<string, string> Returns a color map (table).
function M.auto_hl(scheme, hl_table, hl_link_table, palette)
  ---Get color value from a color table.
  ---@param color_map table<string, string>
  ---@param name string Name of the color.
  ---@return string? corlor_value
  local c = function(color_map, name)
    if not name then return nil end
    if vim.startswith(name, "#") then
      return name
    elseif vim.startswith(name, "$") then
      local key = name:sub(2)
      return color_map[key]
    else
      return nil
    end
  end

  if not (hl_table or hl_link_table) then
    return
  end

  local augroup = vim.api.nvim_create_augroup("my.utility.util." .. scheme .. ".extd", {
    clear = true
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    pattern = scheme,
    callback = function()
      local map = palette()
      if hl_table then
        for k, v in pairs(hl_table) do
          ---Highlighting definition map.
          ---@type table<string, any>
          local val = {
            fg = c(map, v["fg"]),
            bg = c(map, v["bg"]),
            sp = c(map, v["sp"]),
          }
          if v["fmt"] then
            for _, attr in ipairs(vim.split(v["fmt"], ",", {
              plain = false,
              trimempty = true
            })) do
              val[vim.trim(attr)] = true
            end
          end
          vim.api.nvim_set_hl(0, k, val)
        end
      end
      if hl_link_table then
        for k, v in pairs(hl_link_table) do
          vim.api.nvim_set_hl(0, k, { link = v })
        end
      end
    end
  })
end

---Create new mapping with fallback.
---@param mode string Mode short-name.
---@param lhs string Left-hand-side of the mapping.
---@param new_rhs fun(fallback: function) New `rhs`.
---@param opts? vim.keymap.set.Opts Optional parameters map.
function M.new_keymap(mode, lhs, new_rhs, opts)
  opts = opts or {}

  local kbd_table
  local buf = opts.buffer
  if type(buf) == "number" then
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    kbd_table = vim.api.nvim_buf_get_keymap(buf, mode)
  elseif type(buf) == "boolean" and buf then
    error("Should provide buffer number for a buffer specific keymap.")
  else
    kbd_table = vim.api.nvim_get_keymap(mode)
  end

  local fallback

  for _, val in ipairs(kbd_table) do
    if val.lhs == lhs then
      if val.rhs then
        fallback = function()
          lib.feedkeys(val.rhs, "n", true)
        end
      elseif val.callback then
        fallback = val.callback
      end
      break
    end
  end

  if fallback == nil then
    fallback = function()
      lib.feedkeys(lhs, "n", true)
    end
  end

  vim.keymap.set(mode, lhs, function() new_rhs(fallback) end, opts)
end

---Set surrounding keybindings.
---@param srd_table table<string, table>
---@param opts? table A table of *:map-arguments*
function M.set_srd_shortcuts(srd_table, opts)
  for key, val in pairs(srd_table) do
    vim.keymap.set({ "n", "x" }, key, function()
      local m = vim.api.nvim_get_mode().mode
      local mode
      if m == "n" then
        mode = "n"
      elseif vim.list_contains({ "v", "V", "" }, m)
      then
        mode = "v"
      else
        return
      end
      local _esc = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
      vim.api.nvim_feedkeys(_esc, "nx", false)
      if require("utility.syn").Syntax.new():match(val[2]) then
        require("utility.srd").srd_sub("", val[1])
      else
        require("utility.srd").srd_add(mode, val[1])
      end
    end, opts)
  end
end

---Get the word and its position under the cursor.
---This function will use jieba to get chinese word if jieba is enabled.
---@return string word Word under the cursor.
---@return integer start_column Start index of the line (0-based, included).
---@return integer end_column End index of the line (0-based, not included).
function M.get_word()
  ---@module "jieba"
  local jieba = package.loaded["utility.jieba"]
  if jieba and jieba.is_enabled() then
    return jieba.get_word()
  else
    return lib.get_word()
  end
end

return M
