--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza
]]

---------------------
-- Global functions
---------------------

---Get the file name of the current script without folders or extension. E.g. `util.util`
---@param sep? string # Separator character, default is '.'
---@return string
function GetScriptFile(sep)
    sep = sep or "."
    local sys_sep = package.config:sub(1,1)
    local src = debug.getinfo(2,'S').source
    src = src:match('^.+vscripts[/\\](.+).lua$')
    local split = Util.SplitString(src, sys_sep)
    src = table.concat(split, sep)
    return src
end

---Get if the given `handle` value is an entity, regardless of if it's still alive.
---@param handle EntityHandle|any
---@param checkValidity? boolean # Optionally check validity with IsValidEntity.
---@return boolean
function IsEntity(handle, checkValidity)
    return (type(handle) == "table" and handle.__self) and (not checkValidity or IsValidEntity(handle))
end

---Add an output to a given entity `handle`.
---@param handle EntityHandle # The entity to add the `output` to.
---@param output string # The output name to add.
---@param target EntityHandle|string # The entity the output should target, either handle or targetname.
---@param input string # The input name on `target`.
---@param parameter? string # The parameter override for `input`.
---@param delay? number # Delay for the output in seconds.
---@param activator? EntityHandle # Activator for the output.
---@param caller? EntityHandle # Caller for the output.
---@param fireOnce? boolean # If the output should only fire once.
function AddOutput(handle, output, target, input, parameter, delay, activator, caller, fireOnce)
    if IsEntity(target) then target = target:GetName() end
    parameter = parameter or ""
    delay = delay or 0
    local output_str = output..">"..target..">"..input..">"..parameter..">"..delay..">"..(fireOnce and 1 or -1)
    DoEntFireByInstanceHandle(handle, "AddOutput", output_str, 0, activator or nil, caller or nil)
end
CBaseEntity.AddOutput = AddOutput

---Loads the given module, returns any value returned by the given module(true when nil).
---Then runs the given callback function.
---If the module fails to load then the callback is not executed and no error is thrown.
---@param modname string
---@param callback fun(mod_result: unknown)
---@return unknown
---@diagnostic disable-next-line: lowercase-global
function ifrequire(modname, callback)
    local success, result = pcall(require, modname)
    if success then
        callback(result)
        return result
    end
    return nil
end

---Execute a script file. Included in the current scope by default.
---@param scriptFileName string
---@param scope? ScriptScope
---@return boolean
function IncludeScript(scriptFileName, scope)
    return DoIncludeScript(scriptFileName, scope or getfenv(2))
end

require 'debug.core'
require 'util.util'
require 'util.enums'
require 'util.entities'
require 'math.core'

Expose = Util.SanitizeFunctionForHammer

require 'storage'
require 'input'
require 'player'