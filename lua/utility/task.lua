---@class Task Async/await implemented by libuv thread.
---@field action function
---@field callbacks function[]
local Task = {}

Task.__index = Task

---Constructor.
---@param action function
---@param callback? function
---@return Task
function Task.new(action, callback)
    local o = {
        action = action,
        callbacks = { callback }
    }
    setmetatable(o, Task)
    return o
end

---Append callback function.
---@param callback function Callback function.
function Task:append_cb(callback)
    table.insert(self.callbacks, callback)
end

---Start the task.
---@return boolean ok True if the thread starts successfully.
function Task:start()
    return vim.loop.new_work(self.action, vim.schedule_wrap(function (result)
        for _, f in ipairs(self.callbacks) do
            if type(f) == "function" then
                f(result)
            end
        end
    end)):queue()
end

---Await the task.
---@return any
function Task:await()
    local result
    local _co = coroutine.running()
    if not _co then
        error("Task must await in an async block.")
    end
    self:append_cb(function(r)
        result = r
        coroutine.resume(_co)
    end)
    if self:start() then
        coroutine.yield()
        return result
    end
end


return Task
