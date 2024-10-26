local lib = require("utility.lib")
local futures = require("futures")

---@class template.Template
---@field private name string
---@field private args string[]
---@field private dirs string[]
---@field private files table<string, string>
local Template = {}

---@private
Template.__index = Template

---Constructor.
---@param temp_json_path string
---@return template.Template?
function Template.new(temp_json_path)
  local code, temp_json = lib.json_decode(temp_json_path, true)

  if code ~= 0 or not temp_json then
    return nil
  end

  if not temp_json.name then
    return nil
  end

  local t = {
    name = temp_json.name,
    args = temp_json.args or {},
    dirs = temp_json.dirs or {},
    files = {},
  }

  if temp_json.files then
    local dir = vim.fs.dirname(temp_json_path)

    for k, v in pairs(temp_json.files) do
      local fname = lib.path_append(dir, v)
      local f = io.open(fname, "rb")
      if not f then
        return nil
      end
      t.files[k] = f:read("*a")
      f:close()
    end
  end

  setmetatable(t, Template)
  return t
end

function Template:get_name()
  return self.name
end

function Template:get_args()
  return self.args
end

---comment
---@param str string
---@param args table<string, string>
---@return string
function Template:apply_args(str, args)
  local result = str

  for _, arg in ipairs(self.args) do
    result = result:gsub(vim.pesc("#{" .. arg .. "}"), args[arg])
  end

  return result
end

---
---@param args table<string, string>
---@return boolean
function Template:create_project(args)
  for _, dir in ipairs(self.dirs) do
    local dir_esc = self:apply_args(dir, args)
    if lib.path_exists(dir_esc) then
      lib.warn("Directory already exists")
      return false
    end
    vim.uv.fs_mkdir(dir_esc, 448)
  end

  for fname, content in pairs(self.files) do
    local fname_esc = self:apply_args(fname, args)

    if lib.path_exists(fname_esc) then
      lib.warn("File already exists")
      return false
    end

    local f = io.open(fname_esc, "w")
    if f then
      local content_esc = self:apply_args(content, args)
      f:write(content_esc)
      f:close()
    end
  end

  return true
end

local M = {}

---@type table<string, template.Template>
M.templates = {}

---
---@param reset? boolean
---@return boolean
function M:init(reset)
  if not reset and #self.templates ~= 0 then return true end

  self.templates = {}

  local dir = vim.fn.stdpath("config") .. "/template/"

  for fname, type_ in vim.fs.dir(dir) do
    if type_ == "file" and vim.endswith(fname, ".json") then
      local T = Template.new(lib.path_append(dir, fname))
      if T then
        self.templates[T:get_name()] = T
      end
    end
  end

  return true
end

---
---@param name string
function M:create_project(name)
  if not self:init() then
    lib.warn("No project template found.")
    return
  end

  local T = self.templates[name]
  if not T then
    lib.warn("Project template " .. tostring(name) .. " is not found.")
    return
  end

  futures.spawn(function()
    local args = {}

    for _, arg in ipairs(T:get_args()) do
      local val = futures.ui.input { prompt = arg }
      if not val then
        return
      end
      args[arg] = val
    end

    if T:create_project(args) then
      vim.notify("Project created.")
    end
  end)
end

return M
