local M = {}
local api = vim.api
local lib = require("utility/lib")
local mlib = require("utility/mlib")


local function text_eval(f)
    local origin_pos = api.nvim_win_get_cursor(0)
    vim.cmd('normal! F`')
    local back = lib.get_context('b')
    local fore = lib.get_context('f')
    local expr = fore:match('^`(.-)`') or ''

    if pcall(f, expr) then
        local result = tostring(f(expr))
        local fore_new = fore:gsub('%b``', result, 1)
        api.nvim_set_current_line(back..fore_new)
    else
        api.nvim_win_set_cursor(0, origin_pos)
        print('No valid expression was found.')
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
    ['+'] = add,
    ['-'] = subtract,
    ['*'] = multiply,
    ['/'] = divide,
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

local function tree_insert(tree, var, level)
    local temp_node = tree
    for _ = 1, level, 1 do
        temp_node = temp_node[#temp_node]
    end
    table.insert(temp_node, var)
end

local function lisp_tree(str)
    local tree_level = 0
    local pre_parse  = str:gsub('[%(%)]', function(s) return ' '..s..' ' end)
    local elem_table = vim.split(pre_parse, '%s')
    local tree_table = {}

    for _, elem in ipairs(elem_table) do
        if elem == '(' then
            tree_insert(tree_table, {}, tree_level)
            tree_level = tree_level + 1
        elseif elem == ')' then
            tree_level = tree_level - 1
            if tree_level == 0 then break end
        elseif func_map[elem] then
            tree_insert(tree_table, elem, tree_level)
        elseif elem ~= '' then
            tree_insert(tree_table, tonumber(elem), tree_level)
        end
    end
    if tree_level ~= 0 then return end
    return tree_table[1]
end

local function lisp_tree_eval(arg)
    if type(arg) == 'number' then return arg end
    local func = func_map[arg[1]]
    table.remove(arg, 1)
    return func(lib.map(arg, lisp_tree_eval))
end

local function lisp_str_eval(str)
    return lisp_tree_eval(lisp_tree(str))
end

-- Evaluate Lua chunk surrounded by `.
function M.lua_eval()
    text_eval(vim.fn.luaeval)
end

-- Evaluate Lisp chunk(math) surrounded by `.
function M.lisp_eval()
    text_eval(lisp_str_eval)
end


return M
