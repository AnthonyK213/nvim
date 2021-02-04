local func_map = {
    ['+']=function(arg_1, arg_2) return arg_1 + arg_2 end,
    ['-']=function(arg_1, arg_2) return arg_1 - arg_2 end,
    ['*']=function(arg_1, arg_2) return arg_1 * arg_2 end,
    ['/']=function(arg_1, arg_2) return arg_1 / arg_2 end,
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
    return func_map[arg[1]](lisp_eval(arg[2]), lisp_eval(arg[3]))
end


--------------------------------------- TEST ---------------------------------------


local test_str = '(+ (- (* 12 3.4) (/ -5 6.7)) 8.0)'

print(lisp_eval(lisp_parser(test_str)))
-- `12 * 3.4 - -5 / 6.7 + 8.0`
-- 49.546268656716

--vim.cmd('echo v:lua.lisp_parser("(+ (+ 5 -6) 24)")')
