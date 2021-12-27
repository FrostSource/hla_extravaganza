--[[
    v1.0.1

    Debug utility functions.

    Load this file at game start using the following line:

        require "util.debug"

]]
Debug = {}

function Debug.PrintAllEntities()
    local e = Entities:First()
    print(string.format("\n%-40s %-40s %-40s","Classname:", "Name:", "Model Name:"))
    print(string.format("%-40s %-40s %-40s","----------", "-----", "-----------"))
    while e ~= nil do
        print(string.format("%-40s %-40s %-40s", e:GetClassname(), e:GetName(), e:GetModelName()))
        e = Entities:Next(e)
    end
    print()
end
