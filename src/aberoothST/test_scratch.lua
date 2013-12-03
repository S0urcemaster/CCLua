require "aberoothST/loadLibs"

loadLibs()

local capi = commonAPI
local tapi = turtleAPI

tapi.coords.v = tapi.dir2deg.north

-- move forward

local axis = tapi.deg2axis[tapi.coords.v]

tapi.coords[axis] = tapi.coords[axis] + tapi.deg2sign[tapi.coords.v]

print(tapi.coords.z)
assert(tapi.coords.z == -1)
