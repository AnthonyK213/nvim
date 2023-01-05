local lib = require("utility.lib")
local util = require("futures.util")
local uv_callback_index = {
    fs_opendir = 2,
}

---@class futures.Task Represents an asynchronous operation.
---@field action function Function that represents the code to execute in the task.
---@field protected varargs table Arguments for `action`.
---@field protected is_async boolean|integer `action` is asynchronous or not, default `false`.
---@field callback? function Callback invoked when the task runs to complete.
---@field protected callbacks function[]
---@field no_callbacks boolean Mark the task that its `callbacks` will not be executed.
---@field protected handle? userdata Task handle.
---@field result table Result of the task, stored in a packed table.
---@field status 0|-1|-2 Task status, 0: Created; -1: Running; -2: RanToCompletion
local Task = {}

Task.__index = Task

---Constructor.
---@param action function Function that represents the code to execute in the task.
---@param ... any Arguments.
---  - `hash_table`: "is_async", "args", "callback"
---  - `list_like_table` | `not nil`: varargs
---@return futures.Task
function Task.new(action, ...)
    local task = {
        action = action,
        is_async = false,
        callbacks = {},
        no_callbacks = false,
        status = 0,
        varargs = lib.tbl_pack(...),
    }
    setmetatable(task, Task)
    return task
end

---If set `true`, regard `action` as an asynchronous function;
---if set an integer `n`, regard it as an asynchronous function with the nth
---argument to be the callback function.
---@param is_async boolean|integer
---@return futures.Task
function Task:set_async(is_async)
    self.is_async = is_async
    return self
end

---Create a task from a libuv async function.
---@param uv_action string Asynchronous function name from libuv.
---@param ... any Function arguments.
---@return futures.Task
function Task.from_uv(uv_action, ...)
    if not vim.loop[uv_action] then
        error("Libuv has no function `" .. uv_action .. "`.")
    end
    return Task.new(vim.loop[uv_action], ...)
        :set_async(uv_callback_index[uv_action] or true)
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
        local args = lib.tbl_pack(lib.tbl_unpack(self.varargs))
        if type(self.is_async) == "number" then
            if self.is_async > 0 and self.is_async <= args.n then
                lib.tbl_insert(args, self.is_async + 0, cb)
            else
                error("Invalid `is_async`.")
            end
        else
            args[args.n + 1] = cb
            args.n = args.n + 1
        end
        self.handle = self.action(lib.tbl_unpack(args))
        return true
    end
    self.handle = vim.loop.new_work(self.action, cb)
    return self.handle:queue(lib.tbl_unpack(self.varargs))
end

---Wrap a task into a callback function which will start automatically.
---@return function
function Task:to_callback()
    return function(...)
        if self.varargs.n == 0 then
            self.varargs = lib.tbl_pack(...)
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

---Await the task.
---@return any
function Task:await()
    local _co = coroutine.running()
    if not _co or coroutine.status(_co) == "dead" then
        error("Task must await in an active async block.")
    end
    if self.status == 0 then
        self.callback = function(...)
            self.result = lib.tbl_pack(...)
            util.try_resume(_co)
        end
        if self:start() then
            coroutine.yield()
            return lib.tbl_unpack(self.result)
        end
    end
end

---Blocking wait for the task.
---@param timeout? integer Timeout.
function Task:wait(timeout)
    if self.status == 0 then
        self.callback = function(...)
            self.result = lib.tbl_pack(...)
        end
        if self:start() then
            vim.wait(timeout or 1e8, function()
                return self.status == -2
            end)
            return lib.tbl_unpack(self.result)
        end
    end
end

---Creates a task that will complete after a time delay (ms).
---@param delay integer Delay in milliseconds.
---@return futures.Task task
function Task.delay(delay)
    return Task.new(vim.defer_fn, delay):set_async(1)
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
