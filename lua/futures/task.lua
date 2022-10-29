local util = require("futures.util")

---@class Task Async/await implemented with coroutine and libuv.
---@field action function
---@field callback? function
---@field callbacks function[]
---@field handle? userdata
---@field result any
---@field status "Created"|"Running"|"RanToCompletion"
---@field varargs any[]
local Task = {}

Task.__index = Task

---Constructor.
---@param action function
---@param option? any Optional argument.
---  - `function`: callback
---  - `hash_table`: "callback", "args"
---  - `list_like_table` | `not nil`: varargs
---@return Task
function Task.new(action, option)
    local task = {
        action = action,
        callbacks = {},
        status = "Created",
        varargs = {},
    }
    local opt_type = type(option)
    if opt_type == "function" then
        task.callback = option
    elseif opt_type == "table" then
        if vim.tbl_islist(option) then
            task.varargs = option
        else
            task.callback = option.callback
            task.varargs = option.args or {}
        end
    elseif opt_type ~= "nil" then
        table.insert(task.varargs, option)
    end
    setmetatable(task, Task)
    return task
end

---Create a task from a libuv async function, the last argument of the libuv
---function must be the {callback}, maybe an argument {index} could be added
---later on.
---@param uv_action string Asynchronous function name from libuv.
---@param ... any Function arguments.
---@return Task
function Task.from_uv(uv_action, ...)
    local _co = coroutine.running()
    if not _co or coroutine.status(_co) == "dead" then
        error("A libuv task should be created in an active async block.")
    end
    if not vim.loop[uv_action] then
        error("Libuv has no function `" .. uv_action .. "`.")
    end
    local varargs = { ... }
    local task
    task = Task.new(function(callback)
        table.insert(varargs, callback)
        vim.loop[uv_action](unpack(varargs))
    end, function(...)
        task.result = { ... }
        task.status = "RanToCompletion"
        util.try_resume(_co)
    end)
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
        self.action(vim.schedule_wrap(self.callback))
        return true
    end
    -- Otherwise, regard the `action` as a sync function and execute it
    -- in a new thread.
    self.handle = vim.loop.new_work(self.action, vim.schedule_wrap(function(r)
        for _, f in ipairs(self.callbacks) do
            if type(f) == "function" then
                f(r)
            end
        end
    end))
    return self.handle:queue(unpack(self.varargs))
end

---Await the task.
---@return any
function Task:await()
    local _co = coroutine.running()
    if not _co or coroutine.status(_co) == "dead" then
        error("Task must await in an active async block.")
    end
    if self.status == "Created" then
        self:append_cb(function(r)
            self.result = r
            self.status = "RanToCompletion"
            util.try_resume(_co)
        end)
        if self:start() then
            self.status = "Running"
            coroutine.yield()
            if self.callback and vim.tbl_islist(self.result) then
                if vim.tbl_isempty(self.result) then
                    return nil
                end
                return unpack(self.result)
            end
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
        task = Task.new(function(callback)
            vim.defer_fn(callback, delay)
        end, function(_)
            task.status = "RanToCompletion"
            util.try_resume(_co)
        end)
    else
        task = Task.new(function(callback)
            vim.defer_fn(callback, delay)
        end, function(_)
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

---Continue with a action `next`.
---If `next` is a `function`, the task will start instantly with the new callback
--- `next`; If `next` is a `Task`, task `next` will start after this task ends
--- (task will not start automatically).
---@param next function|Task
function Task:continue_with(next)
    local next_type = type(next)
    if next_type == "function" then
        self:append_cb(next)
        self:start()
    else
        self:append_cb(function(...)
            if vim.tbl_isempty(next.varargs) then
                next.varargs = { ... }
            end
            next:start()
        end)
    end
end

---Reset the task.
function Task:reset()
    self.status = "Created"
    self.callbacks = {}
    self.result = nil
    self.handle = nil
end

return Task
