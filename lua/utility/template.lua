local lib = require("utility.lib")
local futures = require("futures")

local template_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "template")

---@class template.Template
---@field private name string
---@field private args string[]
---@field private dirs string[]
---@field private files table<string, string>
local Template = {}

---@private
Template.__index = Template

---Constructor.
---@param temp_obj table
---@return template.Template?
function Template.new(temp_obj)
  if temp_obj.files then
    for k, v in pairs(temp_obj.files) do
      local fname = vim.fs.joinpath(template_dir, v)
      local file = io.open(fname, "rb")
      if not file then
        return nil
      end
      temp_obj.files[k] = file:read("*a")
      file:close()
    end
  end

  setmetatable(temp_obj, Template)
  return temp_obj
end

function Template:get_name()
  return self.name
end

function Template:get_args()
  return self.args
end

---Applies the arguments to the template.
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
      lib.warn(string.format("Directory %s already exists", dir_esc))
      return false
    end
    if not vim.uv.fs_mkdir(dir_esc, 448) then
      vim.notify("Failed to created directory " .. dir_esc)
    end
  end

  for fname, content in pairs(self.files) do
    local fname_esc = self:apply_args(fname, args)

    if lib.path_exists(fname_esc) then
      lib.warn(string.format("File %s already exists", fname_esc))
      return false
    end

    local file = io.open(fname_esc, "w")
    if file then
      local content_esc = self:apply_args(content, args)
      file:write(content_esc)
      file:close()
    end
  end

  return true
end

local M = {}

---@private
---@type table<string, template.Template>
M.templates = {}

---
---@param reset? boolean
---@return boolean
function M:init(reset)
  if not reset and #self.templates ~= 0 then
    return true
  end

  self.templates = {}

  local temp_path = vim.fs.joinpath(template_dir, "templates.json")
  local code, temp_json = lib.json_decode(temp_path, true)
  if code ~= 0 or not temp_json then
    return false
  end

  for _, temp_obj in ipairs(temp_json) do
    local temp = Template.new(temp_obj)
    if temp then
      self.templates[temp:get_name()] = temp
    end
  end

  return true
end

function M:create_project()
  if not self:init() then
    lib.warn("Did not find any project template.")
    return
  end

  futures.spawn(function()
    local name = futures.ui.select(vim.tbl_keys(self.templates), {
      prompt = "Select a template: "
    })

    if not name then
      return
    end

    local template = self.templates[name]
    local args = {}

    for _, arg in ipairs(template:get_args()) do
      local val = futures.ui.input { prompt = arg .. ": " }
      if not val then
        return
      end
      args[arg] = val
    end

    if template:create_project(args) then
      vim.notify("Project created.")
    end
  end)
end

return M
