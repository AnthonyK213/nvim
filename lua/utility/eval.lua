local M = {}
local api = vim.api
local lib = require("utility.lib")
local mlib = require("utility.mlib")

---Evaluate text.
---@param f function Method to evaluate the text.
local function text_eval(f)
    local origin_pos = api.nvim_win_get_cursor(0)
    vim.cmd.normal("F`")
    local context = lib.get_context()
    local back = context.b
    local fore = context.f
    local s, expr, e = fore:match("^()`(.-)()`")

    local ok, result = pcall(f, expr)

    if ok then
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        api.nvim_buf_set_text(0, row, s + #back - 1, row, e + #back, { tostring(result) })
    else
        api.nvim_win_set_cursor(0, origin_pos)
        lib.notify_err(result)
    end
end

local add = function(args)
    local result = 0
    for _, arg in ipairs(args) do
        result = result + arg
    end
    return result
end

local subtract = function(args)
    local result = args[1]
    if #args == 0 then
        error("Wrong number of arguments.")
    elseif #args == 1 then
        return -result
    else
        for i = 2, #args, 1 do
            result = result - args[i]
        end
        return result
    end
end

local multiply = function(args)
    local result = 1
    for _, arg in ipairs(args) do
        result = result * arg
    end
    return result
end

local divide = function(args)
    local result = args[1]
    if #args == 0 then
        error("Wrong number of arguments.")
    elseif #args == 1 then
        return 1 / result
    else
        for i = 2, #args, 1 do
            result = result / args[i]
        end
        return result
    end
end

local power = function(args)
    local pow_res = 1
    for i = 2, #args, 1 do
        pow_res = pow_res * args[i]
    end
    return math.pow(args[1], pow_res)
end

local expow = function(args)
    if #args == 0 then
        return math.exp(1)
    elseif #args == 1 then
        return math.exp(args[1])
    else
        error("Wrong number of arguments.")
    end
end

local func_map = {
    ["+"] = add,
    ["-"] = subtract,
    ["*"] = multiply,
    ["/"] = divide,
    abs   = function(args) return math.abs(args[1]) end,
    acos  = function(args) return math.acos(args[1]) end,
    asin  = function(args) return math.asin(args[1]) end,
    atan  = function(args) return math.atan(args[1]) end,
    atan2 = function(args) return math.atan2(args[1], args[2]) end,
    ceil  = function(args) return math.ceil(args[1]) end,
    cos   = function(args) return math.cos(args[1]) end,
    deg   = function(args) return math.deg(args[1]) end,
    exp   = expow,
    fact  = function(args) return mlib.factorial(args[1]) end,
    fib   = function(args) return mlib.fibonacci(args[1]) end,
    floor = function(args) return math.floor(args[1]) end,
    gamma = function(args) return mlib.gamma(args[1]) end,
    log   = function(args) return math.log(args[1]) end,
    log10 = function(args) return math.log10(args[1]) end,
    pow   = power,
    pi    = function(args) return math.pi * multiply(args) end,
    rad   = function(args) return math.rad(args[1]) end,
    sin   = function(args) return math.sin(args[1]) end,
    sqrt  = function(args) return math.sqrt(args[1]) end,
    tan   = function(args) return math.tan(args[1]) end,
}

---Insert a node to a tree.
---@param tree table A tree.
---@param var any A node to insert.
---@param level integer Insert level.
local function tree_insert(tree, var, level)
    local temp_node = tree
    for _ = 1, level, 1 do
        temp_node = temp_node[#temp_node]
    end
    table.insert(temp_node, var)
end

---Parse a lisp chunk to a tree.
---@param str string Lisp chunk.
---@return table? Parsed tree.
local function lisp_tree(str)
    local tree_level = 0
    local pre_parse  = str:gsub("[%(%)]", function(s) return " " .. s .. " " end)
    local elem_table = vim.split(vim.trim(pre_parse), "%s+")
    local tree_table = {}

    for _, elem in ipairs(elem_table) do
        if elem == "(" then
            tree_insert(tree_table, {}, tree_level)
            tree_level = tree_level + 1
        elseif elem == ")" then
            tree_level = tree_level - 1
            if tree_level == 0 then break end
        elseif func_map[elem] then
            tree_insert(tree_table, elem, tree_level)
        elseif elem ~= "" then
            tree_insert(tree_table, tonumber(elem), tree_level)
        end
    end
    if tree_level ~= 0 then return end
    return tree_table[1]
end

---Evaluate tree recursively.
---@param arg any
---@return any
local function lisp_tree_eval(arg)
    if type(arg) == "number" then return arg end
    local func = func_map[arg[1]]
    if not func then
        error("Invalid expression `" .. arg[1] .. "`.")
    end
    table.remove(arg, 1)
    return func(vim.tbl_map(lisp_tree_eval, arg))
end

---Evaluate lisp chunk.
---@param str string Lisp chunk.
---@return number result Calculation result.
local function lisp_str_eval(str)
    return lisp_tree_eval(lisp_tree(str))
end

---Evaluate Lua chunk surrounded by **backquote**.
function M.lua_eval()
    text_eval(vim.fn.luaeval)
end

---Evaluate Lisp chunk(math) surrounded by **backquote**.
function M.lisp_eval()
    text_eval(lisp_str_eval)
end

return M
