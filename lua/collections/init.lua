local files = {
    "deque",
    "hash_set",
    "iter",
    "linked_list",
    "list",
    "stack",
    "util",
}

---@class collections
---@field reload fun():collections
local collections = {
    Deque = require("collections.deque"),
    HashSet = require("collections.hash_set"),
    Iterator = require("collections.iter"),
    LinkedList = require("collections.linked_list").LinkedList,
    LinkedListNode = require("collections.linked_list").LinkedListNode,
    List = require("collections.list"),
    Stack = require("collections.stack"),
}

setmetatable(collections, {
    __index = {
        _VERSION = "0.1.0",
        _DESCRIPTION = [[Contains interfaces and classes that define various ]]
        .. [[collections of objects, such as lists, queues and hashsets.]],
        reload = function()
            for _, f in ipairs(files) do
                if package.loaded["collections." .. f] then
                    package.loaded["collections." .. f] = nil
                end
            end
            return require("utility.test").r("collections")
        end
    }
})

return collections
