---@class collections.HashSet
---@field data any
local HashSet = {}

---@private
HashSet.__index = HashSet

---Constructor.
---@param field any
---@return collections.HashSet
function HashSet.new(field)
    local o = {
        data = {},
    }
    setmetatable(o, HashSet)
    return o
end

function HashSet:add(item)

end

function HashSet:clear()

end

function HashSet:contains(item)

end

function HashSet:count()

end

function HashSet:except_with(iterable)

end

function HashSet:iter()

end

function HashSet:intersect_with(iterable)

end

function HashSet:is_proper_subset_of(iterable)

end

function HashSet:is_proper_superset_of(iterable)

end

function HashSet:is_subset_of(iterable)

end

function HashSet:is_superset_of(iterable)

end

function HashSet:set_equals()

end

function HashSet:overlaps(iterable)

end

function HashSet:remove(item)

end

function HashSet:remove_where(match)

end

function HashSet:symmetric_except_with(iterable)

end

function HashSet:union_with(iterable)

end

function HashSet:__tostring()

end

return HashSet
