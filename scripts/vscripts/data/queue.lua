--[[
    v1.3.2
    https://github.com/FrostSource/hla_extravaganza

    Adds queue behaviour for tables with #queue.items being the front of the queue.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "data.queue"
    ```

    ======================================== Usage ==========================================

    ```lua
    -- Create a queue with 3 initial values.
    -- 3 is the front of the queue.
    local queue = Queue(1, 2, 3)

    -- Prints "3"
    print(queue:Dequeue())

    -- Get multiple values
    local a,b = queue:Dequeue(2)

    -- Prints "2   1"
    print(a,b)

    -- Queue any values
    stack:Enqueue('a','b','c')

    -- To loop over the items, reference queue.items directly:
    for index, value in ipairs(queue.items) do
        print(index, value)
    end

    -- Or use the `pairs` helper function:
    for index, value in queue:pairs() do
        print(index, value)
    end
    ```

    =========================================== Notes =============================================

    This class supports `storage` with `Storage.SaveQueue()`:

    ```lua
    Storage:SaveQueue('queue', queue)
    queue = Storage:LoadQueue('queue')
    ```
    
    Queues are also natively saved using `Storage.Save()` or if encountered in a table being saved.
]]

---@class Queue
local QueueClass =
{
    ---@type any[]
    items = {}
}
QueueClass.__index = QueueClass

if pcall(require, "storage") then
    Storage.RegisterType("Queue", QueueClass)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `queue`.
    ---
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param queue Queue # The stack to save.
    ---@return boolean # If the save was successful.
    ---@luadoc-ignore
    function QueueClass.__save(handle, name, queue)
        return Storage.SaveTableCustom(handle, name, queue, "Queue")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `stack`.
    ---
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return Queue|nil
    ---@luadoc-ignore
    function QueueClass.__load(handle, name)
        local queue = Storage.LoadTableCustom(handle, name, "Queue")
        if queue == nil then return nil end
        return setmetatable(queue, QueueClass)
    end

    Storage.SaveQueue = QueueClass.__save
    CBaseEntity.SaveQueue = Storage.SaveQueue

    ---
    ---Load a Queue.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name the Queue was saved as.
    ---@param default? T # Optional default value.
    ---@return Queue|T
    ---@luadoc-ignore
    Storage.LoadQueue = function(handle, name, default)
        local queue = QueueClass.__load(handle, name)
        if queue == nil then
            return default
        end
        return queue
    end
    CBaseEntity.LoadQueue = Storage.LoadQueue
end



---
---Add values to the queue in the order they appear.
---
---@param ... any
function QueueClass:Enqueue(...)
    for _, value in ipairs({...}) do
        table.insert(self.items, 1, value)
    end
end

---Get a number of values in reverse order of the queue.
---@param count? number # Default is 1
---@return ...
function QueueClass:Dequeue(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = table.remove(self.items, i)
    end
    return unpack(tbl)
end

---
---Peek at a number of items at the front of the queue without removing them.
---
---@param count? number # Default is 1
---@return any
function QueueClass:Front(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Peek at a number of items at the back of the queue without removing them.
---
---@param count? number # Default is 1
---@return any
function QueueClass:Back(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---
---Remove a value from the queue regardless of its position.
---
---@param value any
function QueueClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---
---Move an existing value to the front of the queue.
---Only the first occurance will be moved.
---
---@param value any # The value to move.
---@return boolean # True if value was found and moved.
function QueueClass:MoveToBack(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            table.insert(self.items, 1, value)
            return true
        end
    end
    return false
end

---
---Move an existing value to the bottom of the stack.
---Only the first occurance will be moved.
---
---@param value any # The value to move.
---@return boolean # True if value was found and moved.
function QueueClass:MoveToFront(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            table.insert(self.items, value)
            return true
        end
    end
    return false
end

---
---Get if this queue contains a value.
---
---@param value any
---@return boolean
function QueueClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end

---
---Return the number of items in the queue.
---
---@return integer
function QueueClass:Length()
    return #self.items
end

---
---Get if the stack is empty.
---
function QueueClass:IsEmpty()
    return #self.items == 0
end

---
---Helper method for looping.
---
---@return fun(table: any[], i: integer):integer, any
---@return any[]
---@return number i
function QueueClass:pairs()
    return ipairs(self.items)
end

function QueueClass:__tostring()
    return "Queue ("..#self.items.." items)"
end


---
---Create a new `Queue` object.
---Last value is at the front of the queue.
---
---E.g.
---
---    local queue = Queue(
---        "Back",
---        "Middle",
---        "Front"
---    )
---
---@param ... any
---@return Queue
function Queue(...)
    return setmetatable({
        items = {...}
    },
    QueueClass)
end
