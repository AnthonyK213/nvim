local util = require("futures.util")
local uv_callback_index = {
    fs_opendir = 2,
}

---@class futures.Task
---@field action function
---@field is_async boolean|integer `action` is asynchronous or not, default `false`.
---@field callback? function
---@field callbacks function[]
---@field no_callbacks boolean
---@field handle? userdata
---@field result any
---@field status 0|-1|-2 0: Created; -1: Running; -2: RanToCompletion
---@field varargs any[]
local Task = {}

Task.__index = Task

---Constructor.
---@param action function
---@param option? any Optional argument.
---  - `hash_table`: "is_async", "args", "callback"
---  - `list_like_table` | `not nil`: varargs
---@return futures.Task
function Task.new(action, option)
    local task = {
        action = action,
        is_async = false,
        callbacks = {},
        no_callbacks = false,
        status = 0,
        varargs = {},
    }
    local opt_type = type(option)
    if opt_type == "table" then
        if vim.tbl_islist(option) then
            task.varargs = option
        else
            task.is_async = option.is_async or false
            task.varargs = option.args or {}
            task.callbacks = type(option.callback) == "function" or { option.callback } or {}
        end
    elseif opt_type ~= "nil" then
        table.insert(task.varargs, option)
    end
    setmetatable(task, Task)
    return task
end

---Create a task from a libuv async function.
---@param uv_action string Asynchronous function name from libuv.
---@param ... any Function arguments.
---@return futures.Task
function Task.from_uv(uv_action, ...)
    if not vim.loop[uv_action] then
        error("Libuv has no function `" .. uv_action .. "`.")
    end
    return Task.new(vim.loop[uv_action], {
        is_async = uv_callback_index[uv_action] or true,
        args = { ... }
    })
end

---Start the task.
---@return boolean ok True if the thread starts successfully.
function Task:start()
    if self.status ~= 0 then return false end
    local cb = vim.schedule_wrap(function(...)
        self.status = -2
        if not self.no_callbacks then
            for _, f in ipairs(self.callbacks) do
                if type(f) == "function" then
                    f(...)
                end
            end
        end
        if type(self.callback) == "function" then
            self.callback(...)
        end
    end)
    self.status = -1
    if self.is_async then
        -- Avoid modifying the structure of table `self.varargs`.
        local args = { unpack(self.varargs) }
        if type(self.is_async) == "number" then
            if self.is_async > 0 and self.is_async <= #args then
                table.insert(args, self.is_async + 0, cb)
            else
                error("Invalid `is_async`.")
            end
        else
            table.insert(args, cb)
        end
        self.handle = self.action(unpack(args))
        return true
    end
    self.handle = vim.loop.new_work(self.action, cb)
    return self.handle:queue(unpack(self.varargs))
end

---Wrap a task into a callback function which will start automatically.
---@return function
function Task:to_callback()
    return function(...)
        if vim.tbl_isempty(self.varargs) then
            self.varargs = { ... }
        end
        self:start()
    end
end

---Continue with a callback function `next`.
---The task will not start automatically.
---@param next function
---@return futures.Task self
function Task:continue_with(next)
    if self.status == 0 then
        table.insert(self.callbacks, next)
    end
    return self
end

---@private
---@return any
function Task:return_result()
    if vim.tbl_islist(self.result) then
        if vim.tbl_isempty(self.result) then
            return nil
        end
        return unpack(self.result)
    end
    return self.result
end

---Await the task.
---@return any
function Task:await()
    local _co = coroutine.running()
    if not _co or coroutine.status(_co) == "dead" then
        error("Task must await in an active async block.")
    end
    if self.status == 0 then
        self.callback = function(...)
            self.result = { ... }
            util.try_resume(_co)
        end
        if self:start() then
            coroutine.yield()
            return self:return_result()
        end
    end
end

---Blocking wait for the task.
function Task:wait()
    if self.status == 0 then
        self.callback = function(...)
            self.result = { ... }
        end
        if self:start() then
            vim.wait(1e8, function()
                return self.status == -2
            end)
            return self:return_result()
        end
    end
end

---Creates a task that will complete after a time delay (ms).
---@param delay integer Delay in milliseconds.
---@return futures.Task task
function Task.delay(delay)
    return Task.new(vim.defer_fn, { is_async = 1, args = { delay } })
end

---Reset the task.
function Task:reset()
    self.status = 0
    self.callback = nil
    self.callbacks = {}
    self.no_callbacks = false
    self.result = nil
    self.handle = nil
end

return Task
