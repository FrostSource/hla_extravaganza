--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    An inventory is a table where each key has an integer value assigned to it.
    When a value hits 0 the key is removed from the table.

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

    --

    To save an inventory you should save/load the items member instead of the inventory object:

    Storage:SaveTable("inv.items", inv.items)
    inv.items = Storage:LoadTable("inv.items", {})
]]
---@class Inventory
local InventoryClass =
{
    ---@type any[]
    items = {},
}
InventoryClass.__index = InventoryClass

---Add a number of values to a key.
---@param key any
---@param value? integer # Default is 1.
---@return number # The value of the key after adding.
function InventoryClass:Add(key, value)
    value = value or 1
    local current = self.items[key]
    if current then
        self.items[key] = current + value
        return self.items[key]
    else
        self.items[key] = value
        return value
    end
end

---Remove a number of values from a key.
---@param key any
---@param value? integer # Default is 1.
---@return number # The value of the key after removal.
function InventoryClass:Remove(key, value)
    value = value or 1
    local current = self.items[key]
    if current then
        self.items[key] = current - value
        if current - value <= 0 then
            self.items[key] = nil
            return 0
        end
        return self.items[key]
    else
        return 0
    end
end

---Get the value associated with a key. This is *not* the same as `inv.items[key]`.
---@param key any
---@return integer
function InventoryClass:Get(key)
    local val = self.items[key]
    if val then
        return val
    end
    return 0
end

---Get the key with the highest value and its value.
---@return any # The key with the highest value.
---@return integer # The value associated with the key.
function InventoryClass:Highest()
    local best_key, best_value = nil, 0
    for key, value in pairs(self.items) do
        if value > best_value then
            best_key = key
            best_value = value
        end
    end
    return best_key, best_value
end

---Get the key with the lowest value and its value.
---@return any # The key with the lowest value.
---@return integer # The value associated with the key.
function InventoryClass:Lowest()
    local best_key, best_value = nil, nil
    for key, value in pairs(self.items) do
        best_value = best_value or value
        if value < best_value then
            best_key = key
            best_value = value
        end
    end
    return best_key, (best_value or 0)
end

---Get if the inventory contains a key with a value greater than 0.
---@param key any
---@return boolean
function InventoryClass:Contains(key)
    if self.items[key] then
        return true
    end
    return false
end

---Get if the inventory is empty.
---@return boolean
function InventoryClass:IsEmpty()
    for _, _ in pairs(self.items) do
        return false
    end
    return true
end


---Create a new `Inventory` object.
---First value is at the top.
---@param starting_inventory table<any,integer>
---@return Inventory
function Inventory(starting_inventory)
    return setmetatable({
        items = starting_inventory or {}
    },
    InventoryClass)
end