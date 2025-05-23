local ffi = require("ffi")
local rsmod = require("utility.rsmod")

---FFI module.
---@type ffi.namespace*
local _ntheme = nil

local M = {}

---@enum my.theme.Theme
M.Theme = {
  Error       = -1,
  Dark        = 0,
  Light       = 1,
  Unspecified = 2,
}

function M.init()
  if _ntheme then
    return true
  end

  local dylib_path = rsmod.get_dylib_path("ntheme")
  if not dylib_path then
    return false;
  end

  ffi.cdef [[ int ntheme_detect(); ]]
  _ntheme = ffi.load(dylib_path)
  return true
end

---
---@return my.theme.Theme
function M.detect()
  if not M.init() then
    return M.Theme.Error
  end
  return _ntheme.ntheme_detect()
end

---
---@param theme? string
---@return "dark"|"light"
function M.normalize(theme)
  if not theme or theme == "auto" then
    if M.detect() == M.Theme.Light then
      return "light"
    else
      return "dark"
    end
  elseif theme == "dark" or theme == "light" then
    return theme
  else
    return "dark"
  end
end

---
---@param theme? string
function M.set_theme(theme)
  local bg = M.normalize(theme)
  if vim.g._my_theme_switchable == true then
    if vim.o.bg ~= bg then
      vim.o.bg = bg
    end
  elseif vim.is_callable(vim.g._my_theme_switchable) then
    vim.g._my_theme_switchable(bg)
  end
end

return M
