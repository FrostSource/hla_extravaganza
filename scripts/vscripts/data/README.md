> Last Updated 2022-11-07

---

# inventory.lua (v1.2.2)

An inventory is a table where each key has an integer value assigned to it. When a value hits 0 the key is removed from the table. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "data.inventory"
```


### Usage 




```lua
-- Create an inventory with 2 initial keys.
local inv = Inventory({
    gun = 1,
    metal = 4
})

-- Remove 1 from metal
-- Prints "3"
print(inv:Remove("metal"))

-- Add 3 to gun
-- Prints "4"
print(inv:Add("gun", 3))

-- Get the highest value key
-- Prints "gun  4"
print(inv:Highest())

-- To loop over the items, reference queue.items directly
for key, value in pairs(inv.items) do
    print(key, value)
end

-- Or use the `pairs` helper function:
for key, value in inv:pairs() do
    print(key, value)
end
```


### Notes 


This class supports `storage` with `Storage.SaveInventory()`: 



```lua
Storage:SaveInventory('inv', inv)
inv = Storage:LoadInventory('inv')
```


Inventories are also natively saved using `Storage.Save()` or if encountered in a table being saved. 

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`InventoryClass:Remove(key, value)`</td><td> Remove a number of values from a key. </td></tr><tr><td>

`InventoryClass:Get(key)`</td><td> Get the value associated with a key. This is *not* the same as `inv.items[key]`. </td></tr><tr><td>

`InventoryClass:Highest()`</td><td> Get the key with the highest value and its value. </td></tr><tr><td>

`InventoryClass:Lowest()`</td><td> Get the key with the lowest value and its value. </td></tr><tr><td>

`InventoryClass:Contains(key)`</td><td> Get if the inventory contains a key with a value greater than 0. </td></tr><tr><td>

`InventoryClass:Length()`</td><td> Return the number of items in the inventory. </td></tr><tr><td>

`InventoryClass:IsEmpty()`</td><td> Get if the inventory is empty. </td></tr><tr><td>

`InventoryClass:pairs()`</td><td> Helper method for looping. </td></tr><tr><td>

`InventoryClass:__tostring()`</td><td></td></tr><tr><td>

`Inventory(starting_inventory)`</td><td> Create a new `Inventory` object. </td></tr></table>



---

# queue.lua (v1.3.2)

Adds queue behaviour for tables with #queue.items being the front of the queue. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "data.queue"
```


### Usage 




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


### Notes 


This class supports `storage` with `Storage.SaveQueue()`: 



```lua
Storage:SaveQueue('queue', queue)
queue = Storage:LoadQueue('queue')
```


Queues are also natively saved using `Storage.Save()` or if encountered in a table being saved. 

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`QueueClass:Dequeue(count)`</td><td>Get a number of values in reverse order of the queue.</td></tr><tr><td>

`QueueClass:Front(count)`</td><td> Peek at a number of items at the front of the queue without removing them. </td></tr><tr><td>

`QueueClass:Back(count)`</td><td> Peek at a number of items at the back of the queue without removing them. </td></tr><tr><td>

`QueueClass:Remove(value)`</td><td> Remove a value from the queue regardless of its position. </td></tr><tr><td>

`QueueClass:MoveToBack(value)`</td><td> Move an existing value to the front of the queue. Only the first occurance will be moved. </td></tr><tr><td>

`QueueClass:MoveToFront(value)`</td><td> Move an existing value to the bottom of the stack. Only the first occurance will be moved. </td></tr><tr><td>

`QueueClass:Contains(value)`</td><td> Get if this queue contains a value. </td></tr><tr><td>

`QueueClass:Length()`</td><td> Return the number of items in the queue. </td></tr><tr><td>

`QueueClass:IsEmpty()`</td><td> Get if the stack is empty. </td></tr><tr><td>

`QueueClass:pairs()`</td><td> Helper method for looping. </td></tr><tr><td>

`QueueClass:__tostring()`</td><td></td></tr><tr><td>

`Queue(...)`</td><td> Create a new `Queue` object. Last value is at the front of the queue.  E.g.      local queue = Queue(         "Back",         "Middle",         "Front"     ) </td></tr></table>



---

# stack.lua (v1.2.2)

Adds stack behaviour for tables with index 1 as the top of the stack. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "data.stack"
```


### Usage 




```lua
-- Create a stack with 3 initial values.
-- 1 is the top of the stack.
local stack = Stack(1, 2, 3)

-- Prints "1"
print(stack:Pop())

-- Pop multiple values
local a,b = stack:Pop(2)

-- Prints "2   3"
print(a,b)

-- Push any values
stack:Push('a','b','c')

-- To loop over the items, reference stack.items directly:
for index, value in ipairs(stack.items) do
    print(index, value)
end

-- Or use the `pairs` helper function:
for index, value in stack:pairs() do
    print(index, value)
end
```


### Notes 


This class supports `storage` with `Storage.SaveStack()`: 



```lua
Storage:SaveStack('stack', stack)
stack = Storage:LoadStack('stack')
```


Stacks are also natively saved using `Storage.Save()` or if encountered in a table being saved. 

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`StackClass:Pop(count)`</td><td> Pop a number of items from the stack. </td></tr><tr><td>

`StackClass:Top(count)`</td><td> Peek at a number of items at the top of the stack without removing them. </td></tr><tr><td>

`StackClass:Bottom(count)`</td><td> Peek at a number of items at the bottom of the stack without removing them. </td></tr><tr><td>

`StackClass:Remove(value)`</td><td> Remove a value from the stack regardless of its position. </td></tr><tr><td>

`StackClass:MoveToTop(value)`</td><td> Move an existing value to the top of the stack. Only the first occurance will be moved. </td></tr><tr><td>

`StackClass:MoveToBottom(value)`</td><td> Move an existing value to the bottom of the stack. Only the first occurance will be moved. </td></tr><tr><td>

`StackClass:Contains(value)`</td><td> Get if this stack contains a value. </td></tr><tr><td>

`StackClass:Length()`</td><td> Return the number of items in the stack. </td></tr><tr><td>

`StackClass:IsEmpty()`</td><td> Get if the stack is empty. </td></tr><tr><td>

`StackClass:pairs()`</td><td> Helper method for looping. </td></tr><tr><td>

`StackClass:__tostring()`</td><td></td></tr><tr><td>

`Stack(...)`</td><td> Create a new `Stack` object. First value is at the top.  E.g.      local stack = Stack(         "Top",         "Middle",         "Bottom"     ) </td></tr></table>



