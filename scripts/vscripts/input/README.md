> Last Updated 2024-01-23

## Index
1. [gesture.lua](#gesturelua)
2. [haptics.lua](#hapticslua)
3. [input.lua](#inputlua)

---

# gesture.lua

> v1.1.1

Provides a system for tracking simple hand poses and gestures. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "gesture"
```


### Usage 


Gestures are added with a unique name and a [0-1] curl range for each finger, or nil if the finger shouldn't be taken into consideration. 



```lua
Gesture:AddGesture("AllFingersNoThumb", 1, 1, 1, 1, 0)
```


Built-in gestures can be removed to lower a small amount of processing cost, however this might produce undesirable results for other mods using the same gesture script if you plan to use a system like Scalable Init. 



```lua
Gesture:RemoveGestures({"OpenHand", "ClosedFist"})
```


Recommended usage for tracking gestures is to register a callback function with a given set of conditions: 



```lua
Gesture:RegisterCallback("start", 1, "ThumbsUp", nil, function(gesture)
    ---@cast gesture GESTURE_CALLBACK
    print(("Player made %s gesture at %d"):format(gesture.name, gesture.time))
end)
```


Generic gesture functions exist for all other times: 



```lua
local g = Gesture:GetGesture(Player.PrimaryHand)
if g.name == "ThumbsUp" then
    print("Player did thumbs up")
end

local g = Gesture:GetGestureRaw(Player.PrimaryHand)
if g.index > 0.5 then
    print("Player has index more than half extended")
end
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Gesture:AddGesture(name, index, middle, ring, pinky, thumb)`</td><td> Add a new gesture to watch for.  If a finger position is nil then the finger isn't taken into consideration. </td></tr><tr><td>

`Gesture:RemoveGesture(name)`</td><td> Remove an existing gesture.  Any callbacks registered with the gesture will be unregistered. </td></tr><tr><td>

`Gesture:RemoveGestures(names)`</td><td> Remove a list of gestures. </td></tr><tr><td>

`Gesture:GetGesture(hand)`</td><td> Gets the current gesture name of a given hand.  E.g.       local g = Gesture:GetGesture(Player.PrimaryHand)      if g.name == "ThumbsUp" then          do_something()      end </td></tr><tr><td>

`Gesture:GetGestureRaw(hand)`</td><td> Gets the current [0-1] finger curl values of a given hand. </td></tr><tr><td>

`Gesture:RegisterCallback(kind, hand, gesture, duration, callback, context)`</td><td> Register a callback for a specific gesture start/stop. </td></tr><tr><td>

`Gesture:UnregisterCallback(callback)`</td><td> Unregister a callback function. </td></tr><tr><td>

`Gesture:Start(on)`</td><td> Starts the gesture system. </td></tr><tr><td>

`Gesture:Stop()`</td><td> Stops the gesture system. </td></tr></table>



---

# haptics.lua

> v1.0.0

Haptic sequences allow for more complex vibrations than the one-shot pulses that the base API provides. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "input.haptics"
```


This script was adapted from PeterSHollander's haptics.lua https://github.com/PeterSHollander/glorious_gloves/blob/master/scripts/vscripts/device/haptics.lua 

### Usage 


A HapticSequence is created with a total duration, vibration strength, and pulse interval. The following sequence lasts for 1 second and vibrates every 10th of a second at half strength. This theoretically pulses 10 times in total. 



```lua
local hapticSeq = HapticSequence(1, 0.5, 0.1)
```


After creating the sequence we can fire it at any point. If the sequence is fired again before finishing it will cancel the currently running sequence and start again. 



```lua
hapticSeq:Fire()
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`HapticSequenceClass:Fire(hand)`</td><td> Start the haptic sequence on a given hand. </td></tr><tr><td>

`HapticSequence(duration, pulseStrength, pulseInterval)`</td><td> Create a new haptic sequence. </td></tr></table>



---

# input.lua

> v1.1.3

Simplifies the tracking of button presses/releases. This system will automatically start when the player spawns unless told not to before the player spawns. 



```lua
Input.AutoStart = false
```


If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "input"
```


### Usage 


The system can be told to track all buttons or individual buttons for those who are performant conscious: 



```lua
Input:TrackAllButtons()
Input:TrackButtons({7, 17})
```


Common usage is to register a callback function which will fire whenever the passed conditions are met. `press`/`release` can be individually registered, followed by which hand to check (or -1 for both), the digital button to check, number of presses (if `press` kind), and the function to call. 



```lua
Input:RegisterCallback("press", 1, 7, 1, function(data)
    ---@cast data INPUT_PRESS_CALLBACK
    print(("Button %s pressed at %.2f on %s"):format(
        Input:GetButtonDescription(data.button),
        data.press_time,
        Input:GetHandName(data.hand)
    ))
end)
```




```lua
Input:RegisterCallback("release", -1, 17, nil, function(data)
    ---@cast data INPUT_RELEASE_CALLBACK
    if data.held_time >= 5 then
        print(("Button %s charged for %d seconds on %s"):format(
            Input:GetButtonDescription(data.button),
            data.held_time, 
            Input:GetHandName(data.hand)
        ))
    end
end)
```


Other general use functions exist for checking presses and are extended to the hand class for ease of use: 



```lua
if Player.PrimaryHand:Pressed(3) then end
if Player.PrimaryHand:Released(3) then end
if Player.PrimaryHand:Button(3) then end
if Player.PrimaryHand:ButtonTime(3) >= 5 then end
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Input:TrackButton(button)`</td><td> Set a button to be tracked. </td></tr><tr><td>

`Input:TrackButtons(buttons)`</td><td> Set an array of buttons to be tracked. </td></tr><tr><td>

`Input:StopTrackingAllButtons()`</td><td> Stop all buttons from being tracked. </td></tr><tr><td>

`Input:TrackAllButtons()`</td><td> Set all buttons to be tracked. </td></tr><tr><td>

`Input:StopTrackingButton(button)`</td><td> Stop tracking a button. </td></tr><tr><td>

`Input:StopTrackingButtons(buttons)`</td><td> Stop tracking an array of buttons. </td></tr><tr><td>

`Input:Pressed(hand, button, lock)`</td><td> Get if a button has just been pressed for a given hand. Optionally lock the button press so it can't be detected by other scripts until it is released. </td></tr><tr><td>

`Input:Released(hand, button, lock)`</td><td> Get if a button has just been released for a given hand. Optionally lock the button release so it can't be detected by other scripts until it is pressed. </td></tr><tr><td>

`Input:Button(hand, button)`</td><td> Get if a button is currently being held down for a given hand. </td></tr><tr><td>

`Input:ButtonTime(hand, button)`</td><td> Get the amount of seconds a button has been held for a given hand. </td></tr><tr><td>

`Input:GetButtonDescription(button)`</td><td> Get the description of a given button. Useful for debugging or hint display. </td></tr><tr><td>

`Input:GetHandName(hand, use_operant)`</td><td> Get the name of a hand. </td></tr><tr><td>

`Input:RegisterCallback(kind, hand, button, presses, callback)`</td><td> Register a callback for a specific button press/release.  | '"press"' # Button is pressed. | '"release"' # Button is released. | `-1` # Both hands. | `0`  # Left Hand. | `1`  # Right Hand. | `2`  # Primary Hand. | `3`  # Secondary Hand.</td></tr><tr><td>

`Input:UnregisterCallback(callback)`</td><td> Unregisters a specific callback from all buttons and hands. </td></tr><tr><td>

`CPropVRHand:Pressed(button, lock)`</td><td> Get if a button has just been pressed for this hand. Optionally lock the button press so it can't be detected by other scripts until it is released. </td></tr><tr><td>

`CPropVRHand:Released(button, lock)`</td><td> Get if a button has just been released for this hand. Optionally lock the button release so it can't be detected by other scripts until it is pressed. </td></tr><tr><td>

`CPropVRHand:Button(button)`</td><td> Get if a button is currently being held down for a this hand. </td></tr><tr><td>

`CPropVRHand:ButtonTime(button)`</td><td> Get the amount of seconds a button has been held for this hand. </td></tr><tr><td>

`Input:Start(on)`</td><td> Starts the input system. </td></tr><tr><td>

`Input:Stop()`</td><td> Stops the input system. </td></tr></table>



