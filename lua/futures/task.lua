local util = require("futures.util")
local uv_callback_index = {
    fs_opendir = 2,
}

---@class Task Async/await implemented with coroutine and libuv.
---@field action function
---@field is_async boolean|integer `action` is asynchronous or not, default `false`.
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
---  - `hash_table`: "is_async", "args", "callback"
---  - `list_like_table` | `not nil`: varargs
---@return Task
function Task.new(action, option)
    local task = {
        action = action,
        is_async = false,
        callbacks = {},
        status = "Created",
        varargs = {},
    }
    local opt_type = type(option)
    if opt_type == "table" then
        if vim.tbl_islist(option) then
            task.varargs = option
        else
            task.is_async = option.is_async or false
            task.varargs = option.args or {}
            task.callback = option.callback
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
    return Task.new(vim.loop[uv_action], {
        is_async = uv_callback_index[uv_action] or true,
        args = { ... }
    })
end

---Append callback function.
---@param callback function Callback function.
function Task:append_cb(callback)
    if self.status ~= "Created" then return end
    table.insert(self.callbacks, callback)
end

---Start the task.
---@return boolean ok True if the thread starts successfully.
function Task:start()
    if self.status ~= "Created" then return false end
    local cb = vim.schedule_wrap(function(...)
        self.status = "RanToCompletion"
        if self.callback then
            self.callback(...)
        end
        for _, f in ipairs(self.callbacks) do
            if type(f) == "function" then
                f(...)
            end
        end
    end)
    self.status = "Running"
    if self.is_async then
        local args = vim.deepcopy(self.varargs)
        if type(self.is_async) == "number" then
            if self.is_async > 0 and self.is_async <= #args then
                table.insert(args, self.is_async + 0, cb)
            else
                error("Invalid `is_async`.")
            end
        else
            table.insert(args, cb)
        end
        self.action(unpack(args))
        return true
    end
    self.handle = vim.loop.new_work(self.action, cb)
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
        self:append_cb(function(...)
            self.result = { ... }
            util.try_resume(_co)
        end)
        if self:start() then
            coroutine.yield()
            if vim.tbl_islist(self.result) then
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
---@param delay integer Delay in milliseconds.
---@return Task task
function Task.delay(delay)
    return Task.new(vim.defer_fn, { is_async = 1, args = { delay } })
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
