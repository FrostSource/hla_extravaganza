--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Adds stack behaviour for tables with index 1 is the top of the stack.

    -- Create a stack with 3 initial values.
    -- 1 is the top of the stack.
    local stack = Stack(1, 2, 3)

    -- Prints "1"
    print(stack:Pop())

    -- Pop multiple values
    local a,b = stack:Pop(2)

    --- Prints "2   3"
    print(a,b)

    -- To loop over the items, reference stack.items directly:
    for key, value in ipairs(stack.items) do
        print(key, value)
    end

    --

    To save a stack you should save/load the items member instead of the stack object:

    Storage:SaveTable("stack.items", stack.items)
    stack.items = Storage:LoadTable("stack.items", {})
]]
---@class Stack
local StackClass =
{
    ---@type any[]
    items = {}
}
StackClass.__index = StackClass

---Push values to the stack.
---@param ... any
function StackClass:Push(...)
    for _, value in ipairs({...}) do
        table.insert(self.items, 1, value)
    end
end

---Pop a number of items from the stack.
---@param count? number # Default is 1
---@return any
function StackClass:Pop(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = table.remove(self.items, 1)
    end
    return unpack(tbl)
end

---Peek at a number of items at the top of the stack without removing them.
---@param count? number # Default is 1
---@return any
function StackClass:Peek(count)
    count = min(count or 1, #self.items)
    local tbl = {}
    for i = 1, count do
        tbl[#tbl+1] = self.items[i]
    end
    return unpack(tbl)
end

---Remove a value from the stack regardless of its position.
---@param value any
function StackClass:Remove(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            return
        end
    end
end

---Move an existing value to the top of the stack.
---Only the first occurance will be moved.
---@param value any # The value to move.
---@return boolean # True if value was found and moved.
function StackClass:MoveToTop(value)
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
function StackClass:MoveToBottom(value)
    for index, val in ipairs(self.items) do
        if value == val then
            table.remove(self.items, index)
            table.insert(self.items, value)
            return true
        end
    end
    return false
end

---Return the number of items in the stack.
---@return integer
function StackClass:Length()
    return #self.items
end

---Get if the stack is empty.
function StackClass:IsEmpty()
    return #self.items == 0
end

---Get if this stack contains a value.
---@param value any
---@return boolean
function StackClass:Contains(value)
    return vlua.find(self.items, value) ~= nil
end


---Creates a new `Stack` object.
---First value is at the top.
---@param ... any
---@return Stack
function Stack(...)
    return setmetatable({
        items = {...}
    },
    StackClass)
end
