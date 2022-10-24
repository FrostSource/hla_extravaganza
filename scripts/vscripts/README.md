<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

```lua
Gesture:AddGesture(string <i>name</i>, number|nil <i>index</i>, number|nil <i>middle</i>, number|nil <i>ring</i>, number|nil <i>pinky</i>, number|nil <i>thumb</i>)
```
</td><td>
Add a new gesture to watch for. 
If a finger position is nil then the finger isn't taken into consideration.</td></tr>
<tr><td> Gesture:RemoveGesture(string <i>name</i>)</td><td>
Remove an existing gesture. 
Any callbacks registered with the gesture will be unregistered.</td></tr>
<tr><td> Gesture:RemoveGestures(GestureNames[] <i>names</i>)</td><td>
Remove a list of gestures.</td></tr>
<tr><td>GestureNames Gesture:GetGesture(CPropVRHand|0|1 <i>hand</i>)</td><td>
Gets the current gesture name of a given hand. 
E.g. 
local g = Gesture:GetGesture(Player.PrimaryHand) if g.name == "ThumbsUp" then do_something() end</td></tr>
<tr><td>GestureTable Gesture:GetGestureRaw(CPropVRHand|0|1 <i>hand</i>)</td><td>
Gets the current gesture values of a given hand.</td></tr>
<tr><td> Gesture:RegisterCallback("start"|"stop" <i>kind</i>, CPropVRHand|-1|0|1 <i>hand</i>, GestureNames <i>gesture</i>, number <i>duration</i>, function <i>callback</i>,  <i>context</i>, any <i>context?</i>)</td><td>
Register a callback for a specific gesture start/stop.</td></tr>
<tr><td> Gesture:UnregisterCallback(function <i>callback</i>)</td><td>
Unregister a callback function.</td></tr>
<tr><td> Gesture:CurrentGestureRaw()</td><td></td></tr>
<tr><td> Gesture:Start(EntityHandle? <i>on</i>)</td><td>
Starts the gesture system.</td></tr>
<tr><td> Gesture:Stop()</td><td>
Stops the gesture system.</td></tr></table>