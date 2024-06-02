local M = {}
local lib = require("utility.lib")
local futures = require("futures")
local Process = futures.Process
local Task = futures.Task
local _bg_timer

---Open terminal and launch shell.
function M.terminal()
  local exec
  local my_sh = _my_core_opt.dep.sh
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
  if exists then
    return vim.fs.normalize(full_path)
  end

  return nil
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
  local cmd
  local args = {}
  local my_start = _my_core_opt.dep.start
  if type(my_start) == "table" then
    cmd = my_start[1]
    if #my_start >= 2 then
      for i = 2, #my_start, 1 do
        table.insert(args, my_start[i])
      end
    end
  elseif type(my_start) == "string" then
    cmd = my_start
  else
    lib.warn("Invalid definition of `start`.")
    return false
  end
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
---@param hl_table? table<string, table<string, string>> See _my_core_opt.hl
---@param hl_link_table? table<string, string> _my_core_opt.hl_link
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

  local id = vim.api.nvim_create_augroup(scheme .. "Extd", {
    clear = true
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = id,
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
---@param opts? table<string, boolean|integer> Optional parameters map.
function M.new_keymap(mode, lhs, new_rhs, opts)
  opts = opts or {}
  local kbd_table = opts.buffer
      and vim.api.nvim_buf_get_keymap(opts.buffer, mode)
      or vim.api.nvim_get_keymap(mode)

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

---Upgrade neovim.
---Depends on `plenary.nvim`
---@param channel? string Upgrade channel, "stable" or "nightly".
function M.nvim_upgrade(channel)
  local proxy = _my_core_opt.dep.proxy or os.getenv("HTTP_PROXY")
  local version = vim.version()

  if not channel then
    channel = version.prerelease and "nightly" or "stable"
  elseif channel ~= "stable" and channel ~= "nightly" then
    lib.warn("Invalid neovim release channel.")
    return
  end

  local Path = require("plenary.path")
  local archive
  local os_type = lib.get_os_type()
  if os_type == lib.Os.Windows then
    archive = "nvim-win64.zip"
  elseif os_type == lib.Os.Linux then
    archive = "nvim-linux64.tar.gz"
  else
    return
  end

  local nvim_path = Path:new(vim.uv.exepath()):parent():parent()
  local bin_path = nvim_path:parent()
  local archive_path = bin_path:joinpath(archive)
  local backup_path = bin_path:joinpath("nvim_bak")
  local source = "https://github.com/neovim/neovim/releases/download/"
      .. channel .. "/" .. archive

  if not backup_path:exists() then backup_path:mkdir() end

  if nvim_path:exists() then
    local name = string.format("%s_%d.%d.%d%s", os.date("%y%m%d%H%M%S"),
      version.major, version.minor, version.patch,
      version.prerelease and "_dev" or "")
    nvim_path:copy {
      recursive = true,
      override = true,
      destination = backup_path:joinpath(name).filename
    }
  end

  local use_proxy = type(proxy) == "string"

  local dl_exec, dl_args, ex_exec, ex_args
  if os_type == lib.Os.Windows then
    local dl_cmd = "Invoke-WebRequest"
        .. " -Uri " .. source
        .. " -OutFile " .. archive_path.filename
    if use_proxy then dl_cmd = dl_cmd .. " -Proxy " .. proxy end
    local rm_cmd = "Remove-Item"
        .. " -Path " .. nvim_path.filename
        .. " -Recurse"
    local ex_cmd = "Expand-Archive"
        .. " -Path " .. archive_path.filename
        .. " -DestinationPath " .. bin_path.filename
    local rn_cmd = "Rename-Item"
        .. " -Path " .. bin_path:joinpath("nvim-win64").filename
        .. " -NewName " .. nvim_path.filename
    local cl_cmd = "Remove-Item"
        .. " -Path " .. archive_path.filename
    local pwsh_cmd = table.concat({
      dl_cmd, rm_cmd, ex_cmd, rn_cmd, cl_cmd
    }, ";")

    vim.fn.jobstart("powershell.exe -c " .. pwsh_cmd, { detach = true })
    vim.cmd.quitall { bang = true }
    return
  elseif os_type == lib.Os.Linux then
    if not lib.executable("curl", true) then return end
    dl_exec = "curl"
    dl_args = use_proxy and {
      "-L", source,
      "-o", archive_path.filename,
      "-x", proxy
    } or {
      "-L", source,
      "-o", archive_path.filename,
    }
    ex_exec = "tar"
    ex_args = {
      "-xf", archive_path.filename,
      "-C", bin_path.filename
    }
  else
    lib.warn("Unsupported operating system.")
    return
  end

  local download = Process.new(dl_exec, { args = dl_args })
  local extract = Process.new(ex_exec, { args = ex_args })

  futures.spawn(function()
    vim.notify("Downloading...")
    if download:await() ~= 0 then
      download:notify_err()
      return
    end
    vim.notify("Package downloaded. Installing...")
    if extract:await() ~= 0 then
      extract:notify_err()
      return
    end
    nvim_path:rm { recursive = true }
    bin_path:joinpath(archive:match("^(.-)%..+$")):rename {
      new_name = nvim_path.filename
    }
    archive_path:rm()
    Task.delay(1000):await()
    vim.notify("Neovim has been upgraded to " .. channel .. " channel.")
  end)
end

---Build crates in `$config/rust/` directory.
function M.build_dylibs()
  if not lib.executable("cargo", true) then return end

  local crates_dir = lib.path_append(vim.fn.stdpath("config"), "rust")
  local dylibs_dir = _my_core_opt.path.dylib
  local dylib_ext = lib.get_dylib_ext()
  local dylib_prefix = lib.has_windows() and "" or "lib"
  if not lib.path_exists(dylibs_dir) then
    if not vim.uv.fs_mkdir(dylibs_dir, 448) then
      lib.warn("Could not crate directory `dylib`.")
      return
    end
  end

  local build_tasks = {}

  for _name, _type in vim.fs.dir(crates_dir) do
    if _type == "directory" then
      local crate_dir = lib.path_append(crates_dir, _name)
      local task = futures.async(function()
        local code
        code = Process.new("cargo", {
          args = { "update" },
          cwd = crate_dir,
        }):await()
        if code ~= 0 then
          lib.warn(_name .. ": Could not update the dependencies")
          return
        end
        code = Process.new("cargo", {
          args = { "build", "--release" },
          cwd = crate_dir,
        }):await()
        if code ~= 0 then
          lib.warn(_name .. ": Built failed")
          return
        end
        local dylib_name = _name .. dylib_ext
        local path_from = lib.path_append(crate_dir, "target/release/" .. dylib_prefix .. dylib_name)
        local path_to = lib.path_append(dylibs_dir, dylib_name)
        local err, success = futures.uv.fs_copyfile(path_from, path_to)
        if success then
          print(_name .. ": Built successfully")
        else
          lib.warn(err)
        end
      end)
      table.insert(build_tasks, task)
    end
  end

  if vim.tbl_isempty(build_tasks) then
    vim.notify("No crate to build")
    return
  end

  futures.spawn(function()
    print("Building...")
    local handles = vim.tbl_map(function(task)
      return futures.spawn(task())
    end, build_tasks)
    for _, handle in ipairs(handles) do
      handle:await()
    end
    Task.delay(1000):await()
    print("Done")
  end)
end

---Determine if the background lock is active.
---@return boolean is_active
function M.bg_lock_is_active()
  return _bg_timer ~= nil and _bg_timer:is_active()
end

---Set background according to the time.
function M.bg_lock_toggle()
  if _bg_timer then
    if _bg_timer:is_active() then
      _bg_timer:stop()
      vim.notify("Background is unlocked.")
    else
      _bg_timer:again()
      vim.notify("Background is locked.")
    end
  else
    _bg_timer = vim.uv.new_timer()
    _bg_timer:start(0, 600, vim.schedule_wrap(function()
      local hour = os.date("*t").hour
      local bg = (hour > 6 and hour < 18) and "light" or "dark"
      if vim.g._my_theme_switchable == true then
        if vim.o.bg ~= bg then vim.o.bg = bg end
      elseif vim.is_callable(vim.g._my_theme_switchable) then
        vim.g._my_theme_switchable(bg)
      else
        _bg_timer:stop()
      end
    end))
  end
end

---Set surrounding keybindings.
---@param srd_table table<string, table>
---@param opts? table A table of *:map-arguments*
function M.set_srd_shortcuts(srd_table, opts)
  for key, val in pairs(srd_table) do
    vim.keymap.set({ "n", "v" }, key, function()
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

return M
