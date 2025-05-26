require("internal.opt")

local nvim_init_src = vim.g.nvim_init_src or vim.env.NVIM_INIT_SRC

local M = {}

function M.use_nano()
  return nvim_init_src == "nano" or _G._my_core_opt.tui.scheme == "nanovim"
end

function M.nano_setup()
  vim.g._my_theme_switchable = true
  vim.g.nano_transparent = _G._my_core_opt.tui.transparent and 1 or 0
  _G._my_core_opt.tui.scheme = "nanovim"
  require("utility.theme").set_theme(_G._my_core_opt.tui.theme)
  vim.cmd.colorscheme("nanovim")
end

function M.load_3rd_ui()
  return nvim_init_src ~= "neatUI" and not M.use_nano()
end

---
---@param exclude? string[]
function M.set_color_scheme(exclude)
  vim.g._my_theme_switchable = false
  if M.use_nano() then
    M.nano_setup()
  elseif exclude and vim.list_contains(exclude, _G._my_core_opt.tui.scheme) then
    return
  else
    if not pcall(vim.cmd.colorscheme, _G._my_core_opt.tui.scheme) then
      vim.notify("Color scheme " .. tostring(_G._my_core_opt.tui.scheme) .. " was not found", vim.log.levels.WARN)
    end
  end
end

return M
