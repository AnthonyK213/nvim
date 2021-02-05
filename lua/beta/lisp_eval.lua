local lib = require("../utility/lib")

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
        error("Fuck!")
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
    if #args == 2 then
        if args[2] ~= 0 then
            return args[1] / args[2]
        end
    else
        error("Fuck!")
    end
end

local func_map = {
    ['+'] = add,
    ['-'] = subtract,
    ['*'] = multiply,
    ['/'] = divide,
}

local function tree_insert(tree, var, level)
    local temp_node = tree
    for i=1,level,1 do
        temp_node = temp_node[#temp_node]
    end
    table.insert(temp_node, var)
end

local function lisp_parser(str)
    local tree_level = 0
    local pre_parse  = str:gsub('[%(%)]', function(s) return ' '..s..' ' end)
    local elem_table = vim.fn.split(pre_parse, '\\s')
    local tree_table = {}

    for index,elem in ipairs(elem_table) do
        if elem == '(' then
            tree_insert(tree_table, {}, tree_level)
            tree_level = tree_level + 1
        elseif elem == ')' then
            tree_level = tree_level - 1
            if tree_level == 0 then break end
        elseif elem ~= '' then
            if vim.fn.index({'+', '-', '*', '/'}, elem) >= 0 then
                tree_insert(tree_table, elem, tree_level)
            else
                tree_insert(tree_table, tonumber(elem), tree_level)
            end
        end
    end
    if tree_level ~= 0 then return end
    return tree_table[1]
end

local function lisp_eval(arg)
    if type(arg) == 'number' then return arg end
    local func = func_map[arg[1]]
    table.remove(arg, 1)
    return func(lib.map(lisp_eval, arg))
end


--------------------------------------- TEST ---------------------------------------


local test_str = '(* (+ (- (* 12 3.4) (/ -5 6.7)) 8 2) (/ -9 10) -2)'

print(lisp_eval(lisp_parser(test_str)))
-- `(12 * 3.4 - -5 / 6.7 + 8.0 + 2) * -9 / 10 * -2`
-- = -46.391641791045
