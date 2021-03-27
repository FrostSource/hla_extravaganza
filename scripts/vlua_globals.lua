---@diagnostic disable: lowercase-global


DMG_GENERIC                 =	0
DMG_CRUSH                   =	1
DMG_BULLET                  =	2
DMG_SLASH                   =	4
DMG_BURN                    =   8
DMG_VEHICLE                 =	16
DMG_FALL                    =	32
DMG_BLAST                   =	64
DMG_CLUB                    =	128
DMG_SHOCK                   =	256
DMG_SONIC                   =	512
DMG_ENERGYBEAM              =	1024
DMG_PREVENT_PHYSICS_FORCE   =	2048
DMG_NEVERGIB                =	4096
DMG_ALWAYSGIB               =	8192
DMG_DROWN                   =	16384
DMG_PARALYZE                =	32768
DMG_NERVEGAS                =	65536
DMG_POISON                  =	131072
DMG_RADIATION               =	262144
DMG_DROWNRECOVER            =	524288
DMG_ACID                    =	1048576
DMG_SLOWBURN                =	2097152
DMG_REMOVENORAGDOLL         =	4194304
DMG_PHYSGUN                 =	8388608
DMG_PLASMA                  =	16777216
DMG_AIRBOAT                 =	33554432
DMG_DISSOLVE                =	67108864
DMG_BLAST_SURFACE           =	134217728
DMG_DIRECT                  =   268435456
---Shotgun damage. Gibs headcrabs.
DMG_BUCKSHOT                =   536870912

----------
--- Global
--- Global functions. These can be called without any class.
----------

---Math

---Returns the number of degrees difference between two yaw angles
---@param ang1 float
---@param ang2 float
---@return float
function AngleDiff(ang1, ang2) end
---Generate a vector given a QAngles
---@param angle QAngle
---@return Vector
function AnglesToVector(angle) end
---(vector,float) constructs a quaternion representing a rotation by angle around the specified vector axis.
---Bug: The Quaternion class is non-functional
---@param axis Vector
---@param angle float
---@return Quaternion
function AxisAngleToQuaternion(axis, angle) end
---Compute the closest point relative to a vector on the OBB of an entity.
---@param entity handle
---@param position Vector
---@return Vector
function CalcClosestPointOnEntityOBB(entity, position) end
---Compute the distance between two entity OBB. A negative return value indicates an input error. A return value of zero indicates that the OBBs are overlapping.
---@param entity1 handle
---@param entity2 handle
---@return float
function CalcDistanceBetweenEntityOBB(entity1, entity2) end
---Calculate the cross product between two vectors (also available as a Vector class method).
---@param v1 Vector
---@param v2 Vector
---@return Vector
function CrossVectors(v1, v2) end
---Get the closest point from P to the (infinite) line through vLineA and vLineB and calculate the shortest distance from P to the line.
---@param P Vector
---@param vLineA Vector
---@param vLineB Vector
---@return float
function CalcDistanceToLineSegment2D(P, vLineA, vLineB) end
---Smooth curve decreasing slower as it approaches zero.
---@param decayTo float
---@param decayTime float
---@param dt float
---@return float
function ExponentialDecay(decayTo, decayTime, dt) end
---Linear interpolation of vector values over [0,1].
---@param v1 Vector
---@param v2 Vector
---@param t float
---@return Vector
function LerpVector(v1, v2, t) end
---Get a random float within a range.
---@param min float
---@param max float
---@return float
function RandomFloat(min, max) end
---Get a random int within a range.
---@param min integer
---@param max integer
---@return integer
function RandomInt(min, max) end
---Rotate a QAngle by another QAngle.
---@param angle1 QAngle
---@param angle2 QAngle
---@return QAngle
function RotateOrientation(angle1, angle2) end
---Rotate a Vector around a point.
---@param rotationOrigin Vector
---@param rotationAngle QAngle
---@param vectorToRotate Vector
---@return Vector
function RotatePosition(rotationOrigin, rotationAngle, vectorToRotate) end
---Rotates a quaternion by the specified angle around the specified vector axis.
---Bug: The Quaternion class is non-functional
---@param quat Quaternion
---@param axis Vector
---@param angle float
---@return Quaternion
function RotateQuaternionByAxisAngle(quat, axis, angle) end
---Find the delta between two QAngles.
---@param src QAngle
---@param dest QAngle
---@return QAngle
function RotationDelta(src, dest) end
---Converts delta QAngle to an angular velocity Vector.
---@param angle1 QAngle
---@param angle2 QAngle
---@return Vector
function RotationDeltaAsAngularVelocity(angle1, angle2) end
---Very basic interpolation of quaternions q0 to q1 over time 't' on [0,1].
---Bug: The Quaternion class is non-functional
---@param q0 Quaternion
---@param q1 Quaternion
---@param t float
---@return Quaternion
function SplineQuaternions(q0, q1, t) end
---Very basic interpolation of vectors v0 to v1 over time t on [0,1].
---@param v0 Vector
---@param v1 Vector
---@param t float
---@return Vector
function SplineVectors(v0, v1, t) end
---Get QAngles for a Vector
---@param input Vector
---@return QAngle
function VectorToAngles(input) end

---utilsinit.lua
---Functions automatically included from the utilsinit.lua core library.

---Absolute value.
---@param val float
---@return float
function abs(val) end
---Clamp the value between the min and max.
---@param val float
---@param min float
---@param max float
---@return float
function Clamp(val, min, max) end
---Convert degrees to radians.
---@param deg float
---@return float
function Deg2Rad(deg) end
---Convert radians to degrees.
---@param rad float
---@return float
function Deg2Rad(rad) end
---Linear interpolation of float values over [0,1].
---@param t float
---@param a float
---@param b float
---@return float
function Lerp(t, a, b) end
---Returns the largest value of the inputs.
---@param x float
---@param y float
---@return float
function max(x, y) end
---Returns the smallest value of the inputs.
---@param x float
---@param y float
---@return float
function min(x, y) end
---Merges two tables into a third, overwriting any matching keys.
---@param t1 table
---@param t2 table
---@return table
function Merge(t1, t2) end
---Remap a value in the range [a,b] to [c,d].
---@param input float
---@param a float
---@param b float
---@param c float
---@param d float
---@return float
function RemapVal(input, a, b, c, d) end
---Remap a value in the range [a,b] to [c,d], clamping the output to the range.
---@param input float
---@param a float
---@param b float
---@param c float
---@param d float
---@return float
function RemapValClamped(input, a, b, c, d) end
---Distance between two vectors squared (faster than calculating the plain distance).
---@param v1 Vector
---@param v2 Vector
---@return float
function VectorDistanceSq(v1, v2) end
---Distance between two vectors.
---@param v1 Vector
---@param v2 Vector
---@return float
function VectorDistance(v1, v2) end
---Linear interpolation of vector values over [0,1]. The native function LerpVectors performs the same task.
---@param t float
---@param v1 Vector
---@param v2 Vector
---@return Vector
function VectorLerp(t, v1, v2) end
---Check if the vector is a zero vector.
---@param vec Vector
---@return boolean
function VectorIsZero(vec) end

---Printing & Drawing

---Appends a string to a log file on the server
---Warning: Deprecated
---@param string_1 string
---@param string_2 string
function AppendToLogFile(string_1, string_2) end
---Draw a debug overlay box
---@param origin Vector
---@param mins Vector
---@param maxs Vector
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param duration float
function DebugDrawBox(origin, mins, maxs, r, g, b, a, duration) end
---Draw box oriented to a Vector direction
---@param origin Vector
---@param mins Vector
---@param maxs Vector
---@param orientation Vector
---@param rgb Vector
---@param a float
---@param duration float
function DebugDrawBoxDirection(origin, mins, maxs, orientation, rgb, a, duration) end
---Draw a debug circle
---@param origin Vector
---@param rgb Vector
---@param a float
---@param radius float
---@param noDepthTest bool
---@param duration float
function DebugDrawCircle(origin, rgb, a, radius, noDepthTest, duration) end
---Try to clear all the debug overlay info
function DebugDrawClear() end
---Draw a debug overlay line
---@param origin Vector
---@param target Vector
---@param r integer
---@param g integer
---@param b integer
---@param noDepthTest boolean
---@param duration float
function DebugDrawLine(origin, target, r, g, b, noDepthTest, duration) end
---Draw a debug line using color vec.
---@param origin Vector
---@param target Vector
---@param rgb Vector
---@param noDepthTest boolean
---@param duration float
function DebugDrawLine_vCol(start, end, vRgb, ztest, duration) end
---Draw text with a line offset.
---@param x float
---@param y float
---@param lineOffset integer
---@param text string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param duration float
function DebugDrawScreenTextLine(x, y, lineOffset, text, r, g, b, a, duration) end
---Draw a debug sphere.
---@param center Vector
---@param vRgb Vector
---@param a float
---@param rad float
---@param ztest boolean
---@param duration float
function DebugDrawSphere(center, vRgb, a, rad, ztest, duration) end
---Draw text in 3d.
---@param origin any
---@param text any
---@param bViewCheck any
---@param duration any
function DebugDrawText(origin, text, bViewCheck, duration) end
---Draw pretty debug text.
---@param x float
---@param y float
---@param lineOffset integer
---@param text string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param duration float
---@param font string
---@param size integer
---@param bBold boolean
function DebugScreenTextPretty(x, y, lineOffset, text, r, g, b, a, duration, font, size, bBold) end
---Print a message to the console.
---@param message string
function Msg(message) end
---Print a console message with a linked console command
---@param string_1 string
---@param string_2 string
function PrintLinkedConsoleMessage(string_1, string_2) end
---Have Entity say message, and teamOnly or not
---@param entity handle
---@param message string
---@param teamOnly boolean
function Say(entity, message, teamOnly) end
---Print a hud message on all clients
---@param string_1 string
function ShowMessage(string_1) end
---Displays a message for a specific player
---@param playerId integer
---@param message string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
function UTIL_MessageText(playerId, message, r, g, b, a) end
---Sends a message to a specific player in the message box with a context table
---@param playerId integer
---@param message string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param context table
function UTIL_MessageText_WithContext(playerId, message, r, g, b, a, context) end
---Sends a message to everyone in the message box
---@param messsage string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
function UTIL_MessageTextAll(messsage, r, g, b, a) end
---Sends a message to everyone in the message box with a context table
---@param messsage string
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param context table
function UTIL_MessageTextAll(messsage, r, g, b, a, context) end
---Resets the message text for the player
---@param playerId integer
function UTIL_ResetMessageText(playerId) end
---Resets the message text for all players
function UTIL_ResetMessageTextAll() end
---Print a warning
---@param msg string
function Warning(msg) end







































QAngle = {
    x = 0,
    y = 0,
    z = 0,

    ---Creates a new QAngle.
    ---@param pitch float
    ---@param yaw float
    ---@param roll float
    constructor = function(pitch, yaw, roll)end,
    ---Overloaded +. Adds angles together.
    ---Note: Use RotateOrientation() instead to properly rotate angles.
    ---@param a QAngle
    ---@param b QAngle
    ---@return QAngle
    __add = function(a, b)end,
    ---Overloaded ==. Tests for Equality
    ---@param a QAngle
    ---@param b QAngle
    ---@return QAngle
    __eq = function(a, b)end,
    ---Overloaded .. Converts the QAngle to a human readable string.
    ---@return string
    __tostring = function()end,
    ---Returns the forward vector.
    ---@return Vector
    Forward = function()end,
    ---Returns the left vector.
    ---@return Vector
    Left = function()end,
    ---Returns the up vector.
    ---@return Vector
    Up = function()end,
}







---Generate a string guaranteed to be unique across the life of the script VM, with an optional root string. Useful for adding data to table's when not sure what keys are already in use in that table.
---@param root string
function UniqueString(root) end