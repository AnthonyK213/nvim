local lib = require("utility.lib")
local futures = require("futures")
local comp_list = {
  "void", "bool", "int", "float", "vec2", "vec3", "vec4", "bvec2", "bvec3",
  "bvec4", "ivec2", "ivec3", "ivec4", "mat2", "mat2x2", "mat3", "mat3x3",
  "mat4x4", "mat2x3", "mat2x4", "mat3x2", "mat3x4", "mat4x2", "mat4x3",
  "sampler1D", "sampler2D", "sampler3D", "samplerCube", "sampler1DShadow",
  "sampler2DShadow", "struct",
  "gl_Color", "gl_SecondaryColor", "gl_Normal", "gl_Vertex", "gl_MultiTexCoordn",
  "gl_FogCoord", "gl_Position", "gl_ClipVertex", "gl_PointSize", "gl_FrontColor",
  "gl_BackColor", "gl_FrontSecondaryColor", "gl_BackSecondaryColor", "gl_TexCoord",
  "gl_FogFragCoord", "gl_FragCoord", "gl_FrontFacing", "gl_PointCoord",
  "gl_FragData", "gl_FragColor", "gl_FragDepth",
  "const", "attribute", "uniform", "varying", "centroid varying", "invariant",
  "in", "out", "inout",
  "radians", "degrees", "sin", "cos", "tan", "asin", "atan",
  "pow", "exp", "log", "exp2", "log2", "sqrt", "inversesqrt", "step", "smoothstep",
  "abs", "sign", "floor", "ceil", "fract", "mod", "min", "max", "clamp", "mix",
  "length", "distance", "dot", "cross", "normalize", "faceforward", "reflect", "refract",
  "matrixCompMult", "lessThan", "lessThanEqual", "greaterThan", "greaterThanEqual",
  "equal", "notEqual", "any", "all", "not",
  "texture2D", "texture2DProj", "texture2DLod", "texture2DProjLod",
  "textureCube", "textureCubeLod",
}

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

---Start glslViewer.
---@param bufnr? integer
---@param fargs? string[]
function M.start(bufnr, fargs)
  bufnr = lib.bufnr(bufnr)
  fargs = fargs or {}

  if M.is_alive(bufnr) then
    vim.notify("glslViewer is already running")
    return
  end

  table.insert(fargs, "--noncurses")
  local viewer = futures.Process.new("glslViewer", {
    args = fargs,
    cwd = lib.get_buf_dir(bufnr),
  }):continue_with(function() print("glslViewer: Exit") end)

  viewer.on_stdout = function(data)
    local lines = vim.split(data, "[\n\r]", {
      plain = false,
      trimempty = true,
    })
    local output = vim.tbl_filter(function(v)
      return not (vim.startswith(v, "// >") or v:match("^%s*$"))
    end, lines)
    if #output > 0 then
      vim.notify(table.concat(output, "\n"))
    end
  end

  if viewer:start() then
    M.tbl[bufnr] = viewer
    vim.api.nvim_buf_attach(bufnr, false, {
      on_detach = function(_, h) M.stop(h) end
    })
    print("glslViewer: Started")
  else
    print("glslViewer: Failed to start")
  end
end

---Stop glslViewer attached to the buffer.
---@param bufnr? integer
function M.stop(bufnr)
  bufnr = lib.bufnr(bufnr)
  if M.tbl[bufnr] then
    M.tbl[bufnr]:kill()
    M.tbl[bufnr] = nil
  end
end

---@param bufnr? integer
function M.toggle(bufnr)
  bufnr = lib.bufnr(bufnr)
  if M.is_alive(bufnr) then
    M.stop(bufnr)
  else
    M.start(bufnr, { vim.api.nvim_buf_get_name(bufnr) })
  end
end

---@param bufnr? integer
function M.input(bufnr)
  bufnr = lib.bufnr(bufnr)
  if not M.is_alive(bufnr) then
    lib.warn("glslViewer is not running!")
    return
  end

  futures.spawn(function()
    local data = futures.ui.input { prompt = "glslViewer", kind = "editor" }
    if not data or #data == 0 then return end
    print("// > " .. data)
    M.tbl[bufnr]:write(data .. "\n")
  end)
end

---GLSL omnifunc.
---@param findstart integer
---@param base string
---@return integer|string[]
function M.omnifunc(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local start = vim.api.nvim_win_get_cursor(0)[2]
    while start > 0 and line:sub(start, start):match("[%a_]") do
      start = start - 1
    end
    return start
  else
    local base_ = base:lower()
    return vim.tbl_filter(function(item)
      return vim.startswith(item:lower(), base_)
    end, comp_list)
  end
end

return M
