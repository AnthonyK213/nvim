---@class Task Async/await implemented with coroutine and libuv.
---@field action function
---@field callback? function
---@field callbacks function[]
---@field result any
---@field status "Created"|"Running"|"RanToCompletion"
---@field varargs any[]
local Task = {}

Task.__index = Task

---Constructor.
---@param action function
---@param callback? function
---@return Task
function Task.new(action, callback, ...)
    local task = {
        action = action,
        callback = callback,
        callbacks = {},
        status = "Created",
        varargs = {...},
    }
    setmetatable(task, Task)
    return task
end

---Append callback function.
---@param callback function Callback function.
function Task:append_cb(callback)
    table.insert(self.callbacks, callback)
end

---Start the task.
---@return boolean ok True if the thread starts successfully.
function Task:start()
    -- If the task has a callback function, regard the `action`
    -- as an async function with a callback.
    if self.callback then
        self.action(self.callback)
        return true
    end
    -- Otherwise, regard the `action` as a sync function and execute it
    -- in a new thread.
    return vim.loop.new_work(self.action, vim.schedule_wrap(function (r)
        for _, f in ipairs(self.callbacks) do
            if type(f) == "function" then
                f(r)
            end
        end
    end)):queue(unpack(self.varargs))
end

---Await the task.
---@return any
function Task:await()
    local _co = coroutine.running()
    if not _co or coroutine.status(_co) == "dead" then
        error("Task must await in an alive async block.")
    end
    if self.status == "Created" then
        self:append_cb(function(r)
            self.result = r
            self.status = "RanToCompletion"
            coroutine.resume(_co)
        end)
        if self:start() then
            self.status = "Running"
            coroutine.yield()
            return self.result
        end
    end
end

---Creates a task that will complete after a time delay (ms).
---@param delay integer
---@return Task task
function Task.delay(delay)
    local _co = coroutine.running()
    local task
    if _co and coroutine.status(_co) ~= "dead" then
        task = Task.new(function (callback)
            vim.defer_fn(callback, delay)
        end,
        function (_)
            task.status = "RanToCompletion"
            coroutine.resume(_co)
        end)
    else
        task = Task.new(function (callback)
            vim.defer_fn(callback, delay)
        end,
        function (_)
            task.status = "RanToCompletion"
            for _, f in ipairs(task.callbacks) do
                if type(f) == "function" then
                    f()
                end
            end
        end)
    end
    return task
end

---Continue with a action then start the task.
---@param callback function
function Task:continue_with(callback)
    self:append_cb(callback)
    self:start()
end

---Reset the task.
function Task:reset()
    self.status = "Created"
    self.callbacks = {}
    self.result = nil
end


return Task
