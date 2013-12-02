require "aberoothST/loadLibs"


loadLibs()

dofile("C:/Users/adm9/Documents/GitHub/CCLua/src/aberoothST/geom.lua")

local capi = commonAPI

-- line2dBres
p1 = make2dPoint(0, 0)

p2 = make2dPoint(2, 5)

points = line2dBres(p1, p2)

print(capi.tableToString(points))

-- line3dBres
p1 = make3dPoint(-1, -1, -1)

p2 = make3dPoint(2, 5, 7)

points = line3dBres(p1, p2)

print(capi.tableToString(points))

-- square2dOutline
p1 = make2dPoint(0, 0)

p2 = make2dPoint(4, 5)

points = square2dOutline(p1, p2)

print(capi.tableToString(points))


-- 
