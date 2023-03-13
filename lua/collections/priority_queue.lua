local function _max(a, b) return a > b end
local function _min(a, b) return a < b end
local function _swap(list, i, j) list[i], list[j] = list[j], list[i] end
local Iterator = require("collections.iter")

---@param comparer? "max"|"min"|fun(a: any, b: any):boolean
---@return fun(a: any, b: any):boolean
local function _get_comparer(comparer)
    if not comparer or "max" == comparer then
        return _max
    elseif "min" == comparer then
        return _min
    elseif not vim.is_callable(comparer) then
        error("Invalid comparer")
    else
        return comparer
    end
end

---@class collections.PriorityQueue
---@field private _data any[]
---@field private _size integer
---@field private _comparer fun(a: any, b: any):boolean
---@operator call:collections.PriorityQueue
local PriorityQueue = {}

---@private
PriorityQueue.__index = PriorityQueue
setmetatable(PriorityQueue, { __call = function(o, ...) return o.new(...) end })

---Initializes a new instance of the `PriorityQueue` with the specified custom
---priority comparer.
---@param comparer? "max"|"min"|fun(a: any, b: any):boolean Custom comparer dictating the ordering of elements. Uses "max" if the argument is `nil`.
---@return collections.PriorityQueue
function PriorityQueue.new(comparer)
    local pq = {
        _data = {},
        _size = 0,
        _comparer = _get_comparer(comparer),
    }
    setmetatable(pq, PriorityQueue)
    return pq
end

---Initializes a new instance of the `PriorityQueue` with the specified elements
---and custom priority comparer.
---@param iterable collections.Iterable
---@param comparer? "max"|"min"|fun(a: any, b: any):boolean Custom comparer dictating the ordering of elements. Uses "max" if the argument is `nil`.
---@return collections.PriorityQueue
function PriorityQueue.from(iterable, comparer)
    local data = {}
    local length = 0
    for i, v in Iterator(iterable):consume() do
        data[i] = v
        length = length + 1
    end
    comparer = _get_comparer(comparer)
    local pq = {
        _data = data,
        _size = length,
        _comparer = comparer,
    }
    setmetatable(pq, PriorityQueue)
    for i = bit.rshift(length, 1), 1, -1 do
        pq:_heapify(i)
    end
    return pq
end

---@private
function PriorityQueue:_parent(i)
    return bit.rshift(i, 1)
end

---@private
function PriorityQueue:_left(i)
    return bit.lshift(i, 1)
end

---@private
function PriorityQueue:_right(i)
    return bit.lshift(i, 1) + 1
end

---@private
function PriorityQueue:_heapify(i)
    local l = self:_left(i)
    local r = self:_right(i)
    local w = l <= self._size and self._comparer(self._data[l], self._data[i]) and l or i
    if r <= self._size and self._comparer(self._data[r], self._data[w]) then
        w = r
    end
    if w ~= i then
        _swap(self._data, i, w)
        self:_heapify(w)
    end
end

---Gets the priority comparer used by the `PriorityQueue`.
---@return fun(a: any, b: any):boolean
function PriorityQueue:get_comparer()
    return self._comparer
end

---Gets the number of elements contained in the `PriorityQueue`.
---@return integer
function PriorityQueue:count()
    return self._size
end

---Removes all items from the `PriorityQueue`.
function PriorityQueue:clear()
    self._size = 0
end

---Removes and returns the minimal element from the `PriorityQueue` - that is,
---the element with the lowest priority value.
function PriorityQueue:dequeue()
    if self._size < 1 then
        error("Heap underflow")
    end
    local peek = self._data[1]
    self._data[1] = self._data[self._size]
    self._size = self._size - 1
    self:_heapify(1)
    return peek
end

---Adds the specified element to the `PriorityQueue`.
---@param item any
function PriorityQueue:enqueue(item)
    self._size = self._size + 1
    local i = self._size
    self._data[i] = item
    local p = self:_parent(i)
    while i > 1 and self._comparer(self._data[i], self._data[p]) do
        _swap(self._data, i, p)
        i = p
        p = self:_parent(i)
    end
end

---Adds the specified element to the `PriorityQueue`, and immediately removes
---the minimal element, returning the result.
---@param item any
---@return any
function PriorityQueue:enqueue_dequeue(item)
    self:enqueue(item)
    return self:dequeue()
end

---Enqueues a sequence of elements pairs to the `PriorityQueue`.
---@param iterable collections.Iterable
function PriorityQueue:enqueue_range(iterable)
    for _, v in Iterator(iterable):consume() do
        self:enqueue(v)
    end
end

---Returns the minimal element from the `PriorityQueue` without removing it.
---@return any
function PriorityQueue:peek()
    if self._size > 0 then
        return self._data[1]
    end
end

---Returns a string that represents the current object.
---@return string
function PriorityQueue:__tostring()
    return string.format("PriorityQueue<%p>", self)
end

return PriorityQueue
