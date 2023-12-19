---@class collections.Iterator
---@field private _next fun():integer?, any
---@operator call(any[]|collections.Iterable):collections.Iterator
local Iterator = {}

---@private
Iterator.__index = Iterator

setmetatable(Iterator, { __call = function(o, iterable) return o.get(iterable) end })

---Get iterator of a iteralble collection.
---@param iterable any[]|collections.Iterable An iteralble collection.
---@return collections.Iterator
function Iterator.get(iterable)
  local iter = {}
  if vim.tbl_islist(iterable) then
    local index = 0
    iter._next = function()
      index = index + 1
      if index <= #iterable then
        return index, iterable[index]
      end
    end
  elseif type(iterable.iter) == "function" then
    iter._next = iterable:iter()
  else
    error("Failed to get the iterator")
  end
  setmetatable(iter, Iterator)
  return iter
end

---Consume the iterator.
---@return fun():integer?, any
function Iterator:consume()
  return self._next
end

---Get the next element of the iterator.
---@return any
function Iterator:next()
  return select(2, self._next())
end

---Applies a specified function to the corresponding elements of two sequences,
---producing a sequence of the results.
---@param iterator collections.Iterator
---@param selector? fun(a: any, b: any):any
---@return collections.Iterator
function Iterator:zip(iterator, selector)
  local index = 0
  local iter = {
    _next = function()
      index = index + 1
      local i, v1 = self._next()
      local j, v2 = iterator:consume()()
      if not (i and j) then return end
      return index, selector and selector(v1, v2) or { v1, v2 }
    end
  }
  setmetatable(iter, Iterator)
  return iter
end

return Iterator
