--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Adds queue behaviour for tables with #queue.items being the front of the queue.

    -- Create a queue with 3 initial values.
    -- 3 is the front of the queue.
    local queue = Queue(1, 2, 3)

    -- Prints "3"
    print(queue:Dequeue())

    -- Get multiple values
    local a,b = queue:Dequeue(2)

    --- Prints "2   1"
    print(a,b)

    -- To loop over the items, reference queue.items directly:
    for key, value in ipairs(queue.items) do
        print(key, value)
    end

    --

    To save a queue you should save/load the items member instead of the queue object:

    Storage:SaveTable("queue.items", queue.items)
    queue.items = Storage:LoadTable("queue.items", {})
]]
---@class Queue
local QueueClass =
{
    ---@type any[]
    items = {}
}
QueueClass.__index = QueueClass

---Add values to the queue in the order they appear.
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

---Return the number of items in the queue.
---@return integer
function QueueClass:Length()
    return #self.items
end

---Peek at a number of items at the end of the queue without removing them.
---@param count? number # Default is 1
---@return any
function QueueClass:Peek(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = #self.items, #self.items-count+1, -1 do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---Remove a value from the queue regardless of its position.
---@param value any
function QueueClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---Move an existing value to the front of the queue.
---Only the first occurance will be moved.
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

---Move an existing value to the bottom of the stack.
---Only the first occurance will be moved.
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

---Get if this queue contains a value.
---@param value any
---@return boolean
function QueueClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end


---Creates a new `Queue` object.
---Last value is at the front of the queue.
---@param ... any
---@return Queue
function Queue(...)
    return setmetatable({
        items = {...}
    },
    QueueClass)
end
