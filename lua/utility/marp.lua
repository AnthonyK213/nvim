local lib = require("utility.lib")

local M = {}

---@private
---@type table<integer, futures.Process>
M.tbl = {}

---@private
---@param bufnr integer
---@return boolean
function M.is_alive(bufnr)
  if M.tbl[bufnr] and not M.tbl[bufnr]:has_exited() then
    return true
  end
  return false
end

---Check if current file can use marp.
---@param bufnr? integer
---@return boolean
function M.is_marp(bufnr)
  bufnr = lib.bufnr(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  if line_count < 3
      or not lib.has_filetype("markdown", vim.bo[bufnr].filetype)
      or vim.trim(vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]) ~= "---" then
    return false
  end

  local sep = vim.regex [[\v^\-{3,}\s*$]]
  local m = vim.regex [[\v^marp:\s*true\s*$]]

  for i = 1, line_count - 1, 1 do
    if m:match_line(bufnr, i) then
      return true
    elseif sep:match_line(bufnr, i) then
      return false
    end
  end

  return false
end

---@private
function M.start(bufnr)
  bufnr = lib.bufnr(bufnr)

  if M.is_alive(bufnr) then
    vim.notify("marp is already running")
    return
  end

  local buf_dir = lib.get_buf_dir(bufnr)
  local marp = require("futures").Process.new("marp", {
    args = { "--html", "--server", buf_dir, },
    cwd = buf_dir,
  }):continue_with(function() print("Marp: Exit") end)

  marp.on_stderr = function(data)
    local m = data:match("Start server listened at (http://localhost:%d+/)")
    if not m then return end
    if require("utility.util").sys_open(m) then
      print("Marp: Connected")
    else
      print("Marp: Failed to connect")
    end
  end

  if marp:start() then
    M.tbl[bufnr] = marp
    vim.api.nvim_buf_attach(bufnr, false, {
      on_detach = function(_, h) M.stop(h) end
    })
    print("Marp: Started")
  else
    print("Marp: Failed to start")
  end
end

---@private
function M.stop(bufnr)
  bufnr = lib.bufnr(bufnr)
  if M.tbl[bufnr] then
    M.tbl[bufnr]:kill()
    M.tbl[bufnr] = nil
  end
end

---Toggle marp server.
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.is_alive(bufnr) then
    M.stop(bufnr)
  else
    M.start(bufnr)
  end
end

return M
