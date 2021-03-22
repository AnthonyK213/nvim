-- Evaluate formula surrounded by backquote.
local M = {}
local lib = require("/utility/lib")


local function text_eval(f)
    local origin_pos = vim.fn.getpos('.')
    vim.fn.execute('normal! F`')
    local back = lib.get_context('b')
    local fore = lib.get_context('f')
    local expr = fore:match('^`(.-)`') or ''

    if pcall(f, expr) then
        local result = tostring(f(expr))
        local fore_new = fore:gsub('%b``', result, 1)
        vim.fn.setline('.', back..fore_new)
    else
        vim.fn.setpos('.', origin_pos)
        print('No valid expression found.')
    end
end


-------------------- Lisp --------------------

local add = function(args)
    local result = 0
    for _,arg in ipairs(args) do
        result = result + arg
    end
    return result
end

local subtract = function(args)
    if #args == 2 then
        return args[1] - args[2]
    else
        error("Fick, fick, fick! Mathematik!")
    end
end

local multiply = function(args)
    local result = 1
    for _,arg in ipairs(args) do
        result = result * arg
    end
    return result
end

local divide = function(args)
    if #args == 2 and args[2] ~= 0 then
        return args[1] / args[2]
    else
        error("Fick, fick, fick! Mathematik!")
    end
end

local func_map = {
    ['+'] = add,
    ['-'] = subtract,
    ['*'] = multiply,
    ['/'] = divide,
    sqrt  = function(args) return math.sqrt(args[1]) end,
    sin   = function(args) return math.sin(args[1]) end,
    cos   = function(args) return math.cos(args[1]) end,
    tan   = function(args) return math.tan(args[1]) end,
}

local function tree_insert(tree, var, level)
    local temp_node = tree
    for _=1,level,1 do
        temp_node = temp_node[#temp_node]
    end
    table.insert(temp_node, var)
end

local function lisp_tree(str)
    local tree_level = 0
    local pre_parse  = str:gsub('[%(%)]', function(s) return ' '..s..' ' end)
    local elem_table = vim.fn.split(pre_parse, '\\s')
    local tree_table = {}

    for _,elem in ipairs(elem_table) do
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
    return func(lib.map(lisp_tree_eval, arg))
end

local function lisp_str_eval(str)
    return lisp_tree_eval(lisp_tree(str))
end

-------------------- Lisp --------------------


-- Evaluate Lua chunk surrounded by `.
function M.lua_eval()
    text_eval(vim.fn.luaeval)
end

-- Evaluate Lisp chunk(math) surrounded by `.
function M.lisp_eval()
    text_eval(lisp_str_eval)
end


return M
